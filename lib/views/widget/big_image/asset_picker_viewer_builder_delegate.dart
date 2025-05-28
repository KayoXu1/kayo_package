///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-10-31 00:15
///
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kayo_package/kayo_package.dart';
import 'package:kayo_package/views/widget/big_image/image_data.dart';

import 'asset_picker_viewer.dart';
import 'custom_scroll_physics.dart';
import 'fade_image_builder.dart';
import 'image_page_builder.dart';

abstract class AssetPickerViewerBuilderDelegate<Asset> {
  AssetPickerViewerBuilderDelegate({
    required this.previewAssets,
    required this.darkText,
    required this.currentIndex,
    this.noImageSrc,
    this.shouldReversePreview = false,
  });

  /// Assets provided to preview.
  /// 提供预览的资源
  final List<Asset> previewAssets;

  final String? noImageSrc;

  /// Theme for the viewer.
  /// 主题
  final bool? darkText;

  /// Whether the preview sequence is reversed.
  /// 预览时顺序是否为反向
  ///
  /// Usually this will be true when users are previewing on Apple OS and
  /// clicked one item of the asset grid.
  /// 通常用户使用苹果系统时，点击网格内容进行预览，是反向进行预览。
  final bool shouldReversePreview;

  /// [StreamController] for viewing page index update.
  /// 用于更新当前正在浏览的资源页码的流控制器
  ///
  /// The main purpose is to narrow down build parts when index is changing,
  /// prevent widely [setState] and causing other widgets rebuild.
  /// 使用 [StreamController] 的主要目的是缩小页码变化时构建组件的范围，
  /// 防止滥用 [setState] 导致其他部件重新构建。
  final StreamController<int> pageStreamController =
  StreamController<int>.broadcast();

  /// The [ScrollController] for the previewing assets list.
  /// 正在预览的资源的 [ScrollController]
  final ScrollController previewingListController = ScrollController();

  /// Whether detail widgets displayed.
  /// 详情部件是否显示
  final ValueNotifier<bool> isDisplayingDetail = ValueNotifier<bool>(true);

  /// The [State] for a viewer.
  /// 预览器的状态实例
  late final ImageViewerState<Asset> viewerState;

  /// The [TickerProvider] for animations.
  /// 用于动画的 [TickerProvider]
  late final TickerProvider vsync;

  /// [AnimationController] for double tap animation.
  /// 双击缩放的动画控制器
  late final AnimationController doubleTapAnimationController;

  /// [CurvedAnimation] for double tap.
  /// 双击缩放的动画曲线
  late final Animation<double> doubleTapCurveAnimation;

  /// [Animation] for double tap.
  /// 双击缩放的动画
  Animation<double>? doubleTapAnimation;

  /// Callback for double tap.
  /// 双击缩放的回调
  late VoidCallback doubleTapListener;

  /// [PageController] for assets preview [PageView].
  /// 查看图片资源的页面控制器
  late final ExtendedPageController pageController = ExtendedPageController(
    initialPage: currentIndex,
  );

  /// Current previewing index in assets.
  /// 当前查看的索引
  int currentIndex;

  /// Getter for the current asset.
  /// 当前资源的Getter
  Asset get currentAsset => previewAssets.elementAt(currentIndex);

  /// Height for bottom preview widget.
  /// 底栏预览部件的高度
  double get bottomPreviewHeight => 90.0;

  /// Height for bottom bar widget.
  /// 底栏部件的高度
  double get bottomBarHeight => 50.0;

  double get bottomDetailHeight => bottomPreviewHeight + bottomBarHeight;

  /// Whether the current platform is Apple OS.
  /// 当前平台是否为苹果系列系统
  bool get isAppleOS => Platform.isIOS || Platform.isMacOS;

  /// Call when viewer is calling [initState].
  /// 当预览器调用 [initState] 时注册 [State] 和 [TickerProvider]。
  void initStateAndTicker(ImageViewerState<Asset> s,
      TickerProvider v,) {
    viewerState = s;
    vsync = v;
    doubleTapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: v,
    );
    doubleTapCurveAnimation = CurvedAnimation(
      parent: doubleTapAnimationController,
      curve: Curves.easeInOut,
    );
  }

  /// Keep a dispose method to sync with [State].
  /// 保留一个 dispose 方法与 [State] 同步。
  void dispose() {
    pageController.dispose();
    pageStreamController.close();
    previewingListController.dispose();
    isDisplayingDetail.dispose();
    doubleTapAnimationController
      ..stop()
      ..reset()
      ..dispose();
  }

  /// Execute scale animation when double tap.
  /// 双击时执行缩放动画
  void updateAnimation(ExtendedImageGestureState state) {
    final double begin = state.gestureDetails!.totalScale!;
    final double end = state.gestureDetails!.totalScale! == 1.0 ? 3.0 : 1.0;
    final Offset pointerDownPosition = state.pointerDownPosition!;

    doubleTapAnimation?.removeListener(doubleTapListener);
    doubleTapAnimationController
      ..stop()
      ..reset();
    doubleTapListener = () {
      state.handleDoubleTap(
        scale: doubleTapAnimation!.value,
        doubleTapPosition: pointerDownPosition,
      );
    };
    doubleTapAnimation = Tween<double>(
      begin: begin,
      end: end,
    ).animate(doubleTapCurveAnimation)
      ..addListener(doubleTapListener);
    doubleTapAnimationController.forward();
  }

  /// Method to switch [isDisplayingDetail].
  /// 切换显示详情状态的方法
  void switchDisplayingDetail({bool? value}) {
    isDisplayingDetail.value = value ?? !isDisplayingDetail.value;
  }

  /// Split page builder according to type of asset.
  /// 根据资源类型使用不同的构建页
  Widget assetPageBuilder(BuildContext context, int index);

  /// Common image load state changed callback with [Widget].
  /// 图片加载状态的部件回调
  Widget previewWidgetLoadStateChanged(BuildContext context,
      ExtendedImageState state, {
        bool hasLoaded = false,
      }) {
    Widget loader;
    switch (state.extendedImageLoadState) {
      case LoadState.completed:
        loader = state.completedWidget;
        if (!hasLoaded) {
          loader = FadeImageBuilder(child: loader);
        }
        break;
      case LoadState.failed:
        loader = failedItemBuilder(context);
        break;
      default:
        loader = Container(
          alignment: Alignment.center,
          child: SpinKitThreeBounce(
            color: Colors.white,
            size: 30,
          ),
        ); //const SizedBox.shrink();
        break;
    }
    return loader;
  }

  /// The item widget when [ImageData.thumbData] load failed.
  /// 资源缩略数据加载失败时使用的部件
  Widget failedItemBuilder(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: ImageView(
          width: 200,
          src: noImageSrc ?? noImageSrc,
        ));
  }

  /// Yes, the build method.
  /// 没错，是它是它就是它，我们亲爱的 build 方法~
  Widget build(BuildContext context);
}

class DefaultAssetPickerViewerBuilderDelegate
    extends AssetPickerViewerBuilderDelegate<ImageData> {
  DefaultAssetPickerViewerBuilderDelegate({
    required int currentIndex,
    required List<ImageData> previewAssets,
    required bool darkText,
    String? noImageSrc,
    bool shouldReversePreview = false,
  }) : super(
    currentIndex: currentIndex,
    previewAssets: previewAssets,
    noImageSrc: noImageSrc,
    darkText: darkText,
    shouldReversePreview: shouldReversePreview,
  );

  @override
  Widget assetPageBuilder(BuildContext context, int index) {
    final ImageData asset = previewAssets.elementAt(index);
    Widget _builder;

    _builder = ImagePageBuilder(
      asset: asset,
      delegate: this,
    );

    return _builder;
  }

  /// AppBar widget.
  /// 顶栏部件
  Widget appBar(BuildContext context) {

    return ValueListenableBuilder<bool>(
      valueListenable: isDisplayingDetail,
      builder: (_, bool value, Widget? child) =>
          AnimatedPositionedDirectional(
            duration: kThemeAnimationDuration,
            curve: Curves.easeInOut,
            top: value
                ? 0.0
                : -(MediaQuery
                .of(context)
                .padding
                .top + kToolbarHeight),
            start: 0.0,
            end: 0.0,
            height: MediaQuery
                .of(context)
                .padding
                .top + kToolbarHeight,
            child: child!,
          ),
      child: Container(
        padding:
        EdgeInsetsDirectional.only(top: MediaQuery
            .of(context)
            .padding
            .top),
        color: darkText == true
            ? BaseColorUtils.colorWhite
            : BaseColorUtils.colorBlack,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: darkText == true
                        ? BaseColorUtils.colorBlack
                        : BaseColorUtils.colorWhite,
                  ),
                  onPressed: Navigator
                      .of(context)
                      .maybePop,
                ),
                const Spacer(),
                StreamBuilder<int>(
                  initialData: currentIndex,
                  stream: pageStreamController.stream,
                  builder: (_, AsyncSnapshot<int> snapshot) =>
                      Center(
                        child: TextView(
                          '${snapshot.data! + 1}/${previewAssets.length}',
                          size: 20,
                          color: darkText == true
                              ? BaseColorUtils.colorBlack
                              : BaseColorUtils.colorWhite,
                          margin: EdgeInsets.only(right: 50),
                        ),
                      ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: darkText == true
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        child: Material(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ExtendedImageGesturePageView.builder(
                  physics: previewAssets.length == 1
                      ? const CustomClampingScrollPhysics()
                      : const CustomBouncingScrollPhysics(),
                  controller: pageController,
                  itemCount: previewAssets.length,
                  itemBuilder: assetPageBuilder,
                  reverse: shouldReversePreview,
                  onPageChanged: (int index) {
                    currentIndex = index;
                    pageStreamController.add(index);
                  },
                  scrollDirection: Axis.horizontal,
                ),
              ),
              ...<Widget>[
                appBar(context),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
