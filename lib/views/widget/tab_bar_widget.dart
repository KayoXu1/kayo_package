import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kayo_package/kayo_package.dart';
import 'package:kayo_package/utils/base_color_utils.dart';

///支持顶部和顶部的TabBar控件
///配合AutomaticKeepAliveClientMixin可以keep住
class TabBarWidget extends StatefulWidget {
  ///底部模式type
  static const int BOTTOM_TAB = 1;

  static const int BOTTOM_TAB_CAN_NULL = 5;

  ///顶部模式type
  static const int TOP_TAB = 2;
  static const int TOP_TAB_NO_TITLE = 4;

  ///
  static const int HIDE_TAB = 3;

  final int? type;

  final List<Widget>? tabItems;

  final List<Widget>? tabViews;

  final Color? backgroundColor;

  final Color? indicatorColor;

  final Widget? title;

  final Widget? drawer;

  final PreferredSizeWidget? appBar;

  final Widget? floatingActionButton;

  final TarWidgetControl? tarWidgetControl;

  final PageController? topPageControl;

  final ValueChanged<int>? onPageChanged;

  final ValueChanged<int>? onTabChanged;

  final int? initialIndex;

  final bool? animate;
  final bool? scrollable;
  final bool? showBack;
  final bool? centerTitle;
  final bool? darkStatusText;
  final double? elevation;
  final String? titleStr;
  final List<Widget>? actions;
  final bool? showLine;
  final Color? bgColor;
  final Function()? backClick;
  final bool? resizeToAvoidBottomInset;

  TabBarWidget({
    Key? key,
    this.type,
    this.tabItems,
    this.tabViews,
    this.backgroundColor,
    this.indicatorColor,
    this.title,
    this.drawer,
    this.appBar,
    this.floatingActionButton,
    this.tarWidgetControl,
    this.topPageControl,
    this.onPageChanged,
    this.onTabChanged,
    this.initialIndex = 0,
    this.animate = true,
    this.scrollable = true,
    this.showBack = false,
    this.centerTitle = false,
    this.elevation,
    this.titleStr,
    this.actions,
    this.backClick,
    this.darkStatusText = true,
    this.showLine = true,
    this.bgColor = const Color(0xffffffff),
    this.resizeToAvoidBottomInset = true,
  }) : super(key: key);

  @override
  TabBarWidgetState createState() => new TabBarWidgetState();
}

class TabBarWidgetState extends State<TabBarWidget>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  PageController? _pageController;

  VoidCallback? _tabControllerChangeCallBack;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      initialIndex: widget.initialIndex ?? 0,
      length: widget.tabItems?.length ?? 0,
    );

    _pageController = PageController(initialPage: widget.initialIndex ?? 0);

    _tabControllerChangeCallBack = () {
      if (true != _tabController?.indexIsChanging) {
        int _index = _tabController?.index ?? 0;
        this.widget.onPageChanged?.call(_index);
        if ((_pageController?.hasClients == true) &&
            _index != (_pageController?.page ?? 0)) {
          _pageController?.animateToPage(_index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOutQuint);
        }
      }
    };
    if (this.widget.type != TabBarWidget.BOTTOM_TAB_CAN_NULL) {
      _tabController?.addListener(_tabControllerChangeCallBack!);
    }
  }

  ///整个页面dispose时，记得把控制器也dispose掉，释放内存
  @override
  void dispose() {
//    _tabController.removeListener(_tabControllerChangeCallBack);
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animate == true) {
      _tabController?.animateTo(widget.initialIndex ?? 0);
    } else {
      _tabController?.index = widget.initialIndex ?? 0;
    }

    if (this.widget.type == TabBarWidget.TOP_TAB) {
      ///顶部tab bar
      return new Scaffold(
        floatingActionButton: widget.floatingActionButton,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        persistentFooterButtons: widget.tarWidgetControl == null
            ? null
            : widget.tarWidgetControl?.footerButton,
        appBar: AppBar(
          elevation: widget.elevation ?? 0.5,
          actions: widget.actions,
          backgroundColor: BaseColorUtils.colorWindowWhite.dark,
          centerTitle: widget.centerTitle,
          leading: widget.showBack == true
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                  ),
                  iconSize: 22,
                  color: Color(
                      widget.darkStatusText == true ? 0xff50525c : 0xffffffff).dark,
                  onPressed: widget.backClick ??
                      (null != KayoPackage.share.onTapToolbarBack
                          ? () {
                              KayoPackage.share.onTapToolbarBack?.call(context);
                            }
                          : () async {
                              if (Navigator.canPop(context)) {
                                return Navigator.of(context).pop();
                              } else {
                                return await SystemNavigator.pop();
                              }
                            }), // null disables the button
                )
              : null,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: widget.darkStatusText == true
                  ? Brightness.light
                  : Brightness.dark),
          title: widget.title ??
              Text(
                widget.titleStr ?? '',
                style: TextStyle(
                    color: (widget.darkStatusText == true
                        ? BaseColorUtils.colorBlack
                        : BaseColorUtils.white).dark),
                textAlign: TextAlign.center,
              ),
          bottom: new TabBar(
            controller: _tabController,
            tabs: widget.tabItems ?? [],
            indicatorColor: widget.indicatorColor.dark,
            indicator: null,
            onTap: widget.onTabChanged,
          ),
        ),
        body: new PageView(
          controller: widget.topPageControl ?? _pageController,
          children: widget.tabViews ?? [],
          onPageChanged: (index) {
            if (widget.animate == true) {
              _tabController?.animateTo(index);
            } else {
              _tabController?.index = index;
            }
//            widget.onPageChanged?.call(index);
          },
        ),
      );
    } else if (this.widget.type == TabBarWidget.TOP_TAB_NO_TITLE) {
      ///顶部tab bar
      return new Scaffold(
        floatingActionButton: widget.floatingActionButton,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        persistentFooterButtons: widget.tarWidgetControl == null
            ? null
            : widget.tarWidgetControl?.footerButton,
        appBar: AppBar(
          elevation: widget.elevation ?? 0.5,
          actions: widget.actions,
          backgroundColor: BaseColorUtils.colorWindowWhite.dark,
          centerTitle: widget.centerTitle,
          automaticallyImplyLeading: false,
          leading: widget.showBack == true
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                  ),
                  iconSize: 22,
                  color: Color(
                      widget.darkStatusText == true ? 0xff50525c : 0xffffffff).dark,
                  onPressed: widget.backClick ??
                      (null != KayoPackage.share.onTapToolbarBack
                          ? () {
                              KayoPackage.share.onTapToolbarBack?.call(context);
                            }
                          : () async {
                              if (Navigator.canPop(context)) {
                                return Navigator.of(context).pop();
                              } else {
                                return await SystemNavigator.pop();
                              }
                            }), // null disables the button
                )
              : null,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: widget.darkStatusText == true
                  ? Brightness.light
                  : Brightness.dark),
          title: TabBar(
            controller: _tabController,
            tabs: widget.tabItems ?? [],
            indicatorColor: widget.indicatorColor.dark,
            labelStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            unselectedLabelStyle:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            labelColor: BaseColorUtils.colorAccent.dark,
            unselectedLabelColor: Color(0xff333333).dark,
            indicator: null,
            onTap: widget.onTabChanged,
          ),
        ),
        body: new PageView(
          controller: widget.topPageControl ?? _pageController,
          children: widget.tabViews ?? [],
          onPageChanged: (index) {
            if (widget.animate == true) {
              _tabController?.animateTo(index);
            } else {
              _tabController?.index = index;
            }
//            widget.onPageChanged?.call(index);
          },
        ),
      );
    } else if (this.widget.type == TabBarWidget.BOTTOM_TAB) {
      ///底部tab bar
      return new Scaffold(
          backgroundColor: BaseColorUtils.colorWindow.dark,
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          drawer: widget.drawer,
          appBar: widget.appBar,
          body: TabBarView(
              //TabBarView呈现内容，因此放到Scaffold的body中
              physics: widget.scrollable == true
                  ? null
                  : NeverScrollableScrollPhysics(),
              controller: _tabController, //配置控制器
              children: widget.tabViews ?? []),
          bottomNavigationBar: Material(
            //为了适配主题风格，包一层Material实现风格套用
            color: (widget.bgColor ?? BaseColorUtils.colorWindow).dark, //底部导航栏主题颜色
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
//                  color: const Color(0xFFF0F0F0),
                  color: const Color(0xFFFFFFFF).dark,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: (widget.showLine == true
                          ? const Color(0xFFf1f1f1)
                          : widget.bgColor ?? BaseColorUtils.white).dark,
                      blurRadius: 0.1,
                      spreadRadius: 0,
                      offset: Offset(-0.2, -0.2), //-1,-1
                    ),
                  ],
                ),
                child: TabBar(
//                  unselectedLabelStyle: TextStyle(fontSize: 14),
//                  labelStyle: TextStyle(fontSize: 14),
                  controller: _tabController,
//                  indicatorColor: const Color(0xFFF0F0F0),
                  indicatorColor: const Color(0xFFFFFFFF).dark,
                  //tab标签的下划线颜色
                  // labelColor: const Color(0xFF000000),
                  indicatorWeight: .5,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: const Color(0xFF8E8E8E).dark,
                  isScrollable: false,
                  tabs: widget.tabItems ?? [],
                ),
              ),
            ),
          ));
    } else if (this.widget.type == TabBarWidget.BOTTOM_TAB_CAN_NULL) {
      ///顶部tab bar
      return new Scaffold(
          floatingActionButton: widget.floatingActionButton,
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          persistentFooterButtons: widget.tarWidgetControl == null
              ? null
              : widget.tarWidgetControl?.footerButton,
          body: Column(
            children: [
              Expanded(
                  child: new PageView(
                controller: widget.topPageControl ?? _pageController,
                children: widget.tabViews ?? [],
                physics: NeverScrollableScrollPhysics(),
              )),
              Container(
                padding: EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  border:
                      Border(top: BorderSide(color: Colors.grey.dark, width: .1)),
                  color:  widget.backgroundColor.dark,
                ),
                child: SafeArea(
                    top: false,
                    child: TabBar(
                        controller: _tabController,
                        tabs: widget.tabItems ?? [],
                        physics: NeverScrollableScrollPhysics(),
                        indicatorColor:context.isDark?BaseColorUtils.transparent: widget.indicatorColor
                            .dark,
                         indicator: null,
                        dividerColor:  BaseColorUtils.colorWhite.dark,
                        onTap: (index) {
                          var view = widget.tabViews?[index];
                          if (!(view is Container)) {
                            if ((_pageController?.hasClients == true) &&
                                index != _pageController?.page) {
                              _pageController?.animateToPage(index,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOutQuint);
                              widget.onPageChanged?.call(index);
                            }
                          }
                          widget.onTabChanged?.call(index);
                        })),
              ) // SafeArea(
              //     child: )
            ],
          ));
    } else {
      ///隐藏Tab
      return BaseSysUtils.empty(widget.tabViews)
          ? WidgetNotFound()
          : Scaffold(
              backgroundColor: BaseColorUtils.colorWindow.dark,
              resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
              drawer: widget.drawer,
              appBar: widget.appBar,
              body: widget.tabViews?[0]);
    }
  }
}

class TarWidgetControl {
  List<Widget> footerButton = [];
}
