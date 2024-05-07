import 'package:flutter/material.dart';
import 'package:kayo_package/kayo_package.dart';

extension BaseWidgetExtension on Widget? {
  ///设置widget的显示、隐藏、隐藏占位
  Widget setVisible({Key? key, required Visible? visible}) {
    if (null != this) {
      return VisibleView(
        key: key,
        visible: visible ?? Visible.visible,
        child: this,
      );
    }
    return SizedBox();
  }

  ///设置widget的显示、隐藏、隐藏占位
  Widget setVisible2({Key? key, required bool? visible}) {
    if (null != this) {
      return Visibility(
        child: this!,
        visible: visible ?? true,
      );
    }
    return SizedBox();
  }

  ///给widget增加点击事件
  @Deprecated('调用')
  Widget setOnClick(
      {Key? key,
      required GestureTapCallback? onTap,
      double? radius,
      bool? materialBtn = true,
      EdgeInsets? margin,
      EdgeInsets? padding,
      double? elevation,
      Color? bgColor,
      Color? shadowColor,
      Alignment? alignment}) {
    if (null != this) {
      return Clickable(
        key: key,
        child: this,
        materialBtn: materialBtn,
        alignment: alignment,
        margin: margin,
        elevation: elevation,
        bgColor: bgColor,
        shadowColor: shadowColor,
        padding: padding,
        radius: radius,
        onTap: onTap,
      );
    }
    return SizedBox();
  }

  Widget inkWell({
    Key? key,
    Widget? child,
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    GestureTapDownCallback? onTapDown,
    GestureTapCancelCallback? onTapCancel,
    ValueChanged<bool>? onHighlightChanged,
    ValueChanged<bool>? onHover,
    MouseCursor? mouseCursor,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    MaterialStateProperty<Color?>? overlayColor,
    Color? splashColor,
    InteractiveInkFeatureFactory? splashFactory,
    double? radius,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    bool? enableFeedback = true,
    bool excludeFromSemantics = false,
    FocusNode? focusNode,
    bool canRequestFocus = true,
    ValueChanged<bool>? onFocusChange,
    bool autofocus = false,
  }) {
    return InkWell(
      child: this,
      key: key,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onTapDown: onTapDown,
      onTapCancel: onTapCancel,
      onHighlightChanged: onHighlightChanged,
      onHover: onHover,
      mouseCursor: mouseCursor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      overlayColor: overlayColor,
      splashColor: splashColor,
      splashFactory: splashFactory,
      radius: radius,
      borderRadius: borderRadius,
      customBorder: customBorder,
      enableFeedback: enableFeedback ?? true,
      excludeFromSemantics: excludeFromSemantics,
      focusNode: focusNode,
      canRequestFocus: canRequestFocus,
      onFocusChange: onFocusChange,
      autofocus: autofocus,
    );
  }

  ///添加padding
  Widget setPadding({Key? key, required EdgeInsets padding}) {
    if (null != this) {
      return Padding(
        key: key,
        padding: padding,
        child: this,
      );
    }
    return SizedBox();
  }

  ///设置Align
  Widget setAlign(
      {Key? key,
      required AlignmentGeometry alignment,
      double? widthFactor,
      double? heightFactor}) {
    if (null != this) {
      return Align(
        key: key,
        alignment: alignment,
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: this,
      );
    }
    return SizedBox();
  }

  ///外面包一层container
  Widget addContainer(
      {Key? key,
      EdgeInsets? padding,
      EdgeInsets? margin,
      Alignment? alignment,
      Color? color,
      double? height,
      double? width,
      bool? enable = true,
      Decoration? decoration}) {
    if (enable != true) {
      return this!;
    }
    if (null != this) {
      return null != padding ||
              null != margin ||
              null != alignment ||
              null != color ||
              null != decoration
          ? Container(
              key: key,
              height: height,
              width: width,
              padding: padding,
              margin: margin,
              alignment: alignment,
              child: this,
              color: null == decoration ? color : null,
              decoration: decoration,
            )
          : this!;
    }
    return SizedBox();
  }

  ///外面包一层FittedBox
  ///自动调整单widget大小，以实现单行显示
  Widget addFittedBox({
    Key? key,
  }) {
    if (null != this) {
      return LayoutBuilder(builder: (_, constraints) {
        return FittedBox(
          child: ConstrainedBox(
            constraints: constraints.copyWith(
              minWidth: constraints.maxWidth,
              maxWidth: double.infinity,
            ),
            child: this!,
          ),
        );
      });
    }
    return SizedBox();
  }

  ///外面包一层SafeArea
  Widget addSafeArea(
      {Key? key,
      bool? left,
      bool? top,
      bool? right,
      bool? bottom,
      EdgeInsets? minimum,
      bool? maintainBottomViewPadding}) {
    if (null != this) {
      return SafeArea(
          key: key,
          child: this!,
          left: left ?? true,
          top: top ?? true,
          right: right ?? true,
          bottom: bottom ?? true,
          minimum: minimum ?? EdgeInsets.zero,
          maintainBottomViewPadding: maintainBottomViewPadding ?? false);
    }
    return SizedBox();
  }

  ///外面包一层Expanded
  Widget addExpanded({int? flex = 1, Key? key}) {
    if (null != this) {
      if (null == flex) {
        return this!;
      }
      return Expanded(
        key: key,
        child: this!,
        flex: flex,
      );
    }
    return SizedBox();
  }

  ///外面包一层Flexible
  Widget addFlexible({int? flex, Key? key, FlexFit? fit}) {
    if (null != this) {
      return Flexible(
        key: key,
        fit: fit ?? FlexFit.loose,
        child: this!,
        flex: flex ?? 1,
      );
    }
    return SizedBox();
  }

  ///AbsorbPointer是一种禁止用户输入的控件
  ///AbsorbPointer本身可以接收点击事件，消耗掉事件，而IgnorePointer无法接收点击事件
  ///外面包一层AbsorbPointer
  Widget addAbsorbPointer(
      {Key? key, bool? absorbing = true, bool? ignoringSemantics}) {
    if (null != this) {
      return absorbing != true
          ? this!
          : AbsorbPointer(
              key: key,
              absorbing: absorbing!,
              child: this,
              ignoringSemantics: ignoringSemantics);
    }
    return SizedBox();
  }

  ///外面包一层IgnorePointer
  ///AbsorbPointer本身可以接收点击事件，消耗掉事件，而IgnorePointer无法接收点击事件
  Widget addIgnorePointer(
      {Key? key, bool? ignoring = true, bool? ignoringSemantics}) {
    if (null != this) {
      return ignoring != true
          ? this!
          : IgnorePointer(
              key: key,
              ignoring: ignoring!,
              child: this,
              ignoringSemantics: ignoringSemantics);
    }
    return SizedBox();
  }

  ///设置Align
  Widget addBgImg(
      {Key? key,
      String? src,
      BoxFit fit = BoxFit.fitWidth,
      bool wrapContainer = true,
      bool darkNoBg = true,
      double width = double.infinity}) {
    if (null == this) {
      return Container();
    }
    if (!BaseSysUtils.empty(src)) {
      if (wrapContainer) {
        return Container(
          child: this,
          decoration: KayoPackage.share.isDark() && darkNoBg
              ? null
              : BoxDecoration(
                  image: DecorationImage(
                  image: AssetImage(src!),
                  fit: fit,
                )),
        );
      }

      return Stack(
        children: [
          ImageView(
            src: src,
            fit: fit,
            width: width,
          ).dark(darkNoBg:darkNoBg),
          this!
        ],
      );
    }
    return this!;
  }
}
