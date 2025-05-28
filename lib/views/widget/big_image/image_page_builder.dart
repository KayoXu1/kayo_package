///
/// [Author] Alex (https://github.com/Alex525)
/// [Date] 2020/4/6 15:07
///
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:kayo_package/kayo_package.dart';
import 'package:kayo_package/views/widget/big_image/image_data.dart';

import 'asset_picker_viewer_builder_delegate.dart';

class ImagePageBuilder extends StatefulWidget {
  const ImagePageBuilder({
    Key? key,
    required this.asset,
    required this.delegate,
    this.previewThumbSize,
  }) : super(key: key);

  /// Asset currently displayed.
  /// 展示的资源
  final ImageData asset;

  final AssetPickerViewerBuilderDelegate<ImageData> delegate;

  final List<int>? previewThumbSize;

  @override
  _ImagePageBuilderState createState() => _ImagePageBuilderState();
}

class _ImagePageBuilderState extends State<ImagePageBuilder> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.delegate.switchDisplayingDetail,
      child: ExtendedImage(
        image: !PlatformUtils.isWeb
            ? _buildExtendedNetworkImageProvider()
            : _buildExtendedNetworkImageProvider2(),
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        onDoubleTap: widget.delegate.updateAnimation,
        initGestureConfigHandler: (ExtendedImageState state) {
          return GestureConfig(
            initialScale: 1.0,
            minScale: 1.0,
            maxScale: 3.0,
            animationMinScale: 0.6,
            animationMaxScale: 4.0,
            cacheGesture: false,
            inPageView: true,
          );
        },
        loadStateChanged: (ExtendedImageState state) {
          return widget.delegate.previewWidgetLoadStateChanged(
            context,
            state,
            hasLoaded: state.extendedImageLoadState == LoadState.completed,
          );
        },
      ),
    );
  }

  ImageProvider _buildExtendedNetworkImageProvider() {
    if (!BaseSysUtils.empty(widget.asset.url)) {
      return ExtendedNetworkImageProvider(widget.asset.url ?? '');
    } else if (!BaseSysUtils.empty(widget.asset.path)) {
      return ExtendedFileImageProvider(File(widget.asset.path!));
    } else if (null != widget.asset.file) {
      return ExtendedFileImageProvider(widget.asset.file!);
    } else {
      return ExtendedNetworkImageProvider(widget.asset.url ?? '');
    }
  }

  ImageProvider _buildExtendedNetworkImageProvider2() {
    if (!BaseSysUtils.empty(widget.asset.url)) {
      return ExtendedNetworkImageProvider(widget.asset.url ?? '');
    } else {
      return ExtendedNetworkImageProvider(widget.asset.url ?? '');
    }
  }
}
