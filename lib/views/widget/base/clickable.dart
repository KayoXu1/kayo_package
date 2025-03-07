import 'package:flutter/material.dart';
import 'package:kayo_package/extension/color_extension.dart';
import 'package:kayo_package/utils/base_color_utils.dart';
import 'package:kayo_package/views/widget/base/shadow_view.dart';

///  kayo_plugin
///  views.widget.base
///
///  Created by kayoxu on 2019/2/13 6:24 PM.
///  Copyright © 2019 kayoxu. All rights reserved.

class Clickable extends StatelessWidget {
  final Widget? child;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapDownCallback? onTapDown;
  final GestureTapCancelCallback? onTapCancel;
  final ValueChanged<bool>? onHighlightChanged;
  final Color? highlightColor;
  final Color? splashColor;
  final InteractiveInkFeatureFactory? splashFactory;
  final double? radius;

  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final bool? enableFeedback;

  final bool? excludeFromSemantics;

  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? bgColor;
  final double? elevation;
  final Color? shadowColor;
  final Decoration? decoration;
  final BoxConstraints? constraints;
  final Alignment? alignment;

  final Color? selectColor;
  final bool? selected;
  final bool? materialBtn;
  final double? height;
  final double? width;

  Clickable(
      {Key? key,
      required this.child,
      this.onTap,
      this.onDoubleTap,
      this.onLongPress,
      this.onTapDown,
      this.onTapCancel,
      this.onHighlightChanged,
      this.highlightColor,
      this.splashColor,
      this.constraints,
      this.splashFactory,
      this.radius = 0,
      this.borderRadius,
      this.customBorder,
      this.enableFeedback = true,
      this.excludeFromSemantics = false,
      this.margin,
      this.padding,
      this.bgColor = BaseColorUtils.transparent,
      this.elevation = 0,
      this.shadowColor = BaseColorUtils.colorGreyLite,
      this.decoration,
      this.alignment,
      this.selectColor,
      this.selected,
      this.materialBtn = true,
      this.height,
      this.width})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    var elevation1 = elevation ?? 0;
    var shadowColor1 = shadowColor ?? BaseColorUtils.colorGreyLite;
    var radius1 = radius ?? 0;

    return Container(
      decoration: decoration,
      height: height,
      width: width,
      margin: margin,
      alignment: alignment,
      child: (null == onTap &&
              null == onDoubleTap &&
              null == onLongPress &&
              null == onTapDown &&
              null == onTapCancel)
          ? ShadowView(
              elevation: elevation1,
              shadowColor: shadowColor1.darkNull,
              bgColor: bgColor.darkNull,
              borderRadius: BorderRadius.circular(radius1),
              child: Container(
                child: child,
                constraints: constraints,
                padding: padding,
              ),
            )
          : ShadowView(
              elevation: elevation1,
              shadowColor: shadowColor1.darkNull,
              bgColor: (((selected ?? false) && null != selectColor)
                  ? selectColor
                  : bgColor).darkNull,
              // inkWell: true,
              borderRadius: BorderRadius.circular(radius1),
              child: Container(
                child: InkWell(
                  child: Container(
                    child: child,
                    constraints: constraints,
                    padding: padding,
                  ),

                  onTap: onTap,
                  onDoubleTap: onDoubleTap,
                  onLongPress: onLongPress,
                  onTapDown: onTapDown,
                  onTapCancel: onTapCancel,
                  onHighlightChanged: onHighlightChanged,
                  highlightColor: materialBtn == true
                      ? (null != highlightColor
                          ? highlightColor
                          : BaseColorUtils.colorGreyLiteLite.withOpacity(.1))
                      : Colors.transparent,
                  splashColor: null != splashColor
                      ? splashColor
                      : BaseColorUtils.colorGreyLiteLite.withOpacity(.3),
                  splashFactory: splashFactory,
                  radius: materialBtn == true ? null : 0,
//                borderRadius:borderRadius,
                  borderRadius: null != borderRadius
                      ? borderRadius
                      : BorderRadius.all(Radius.circular(radius1)),
                  customBorder: customBorder,
                  enableFeedback: enableFeedback??true,
                  excludeFromSemantics: excludeFromSemantics ?? false,
                ),
              ),
            ),
    );
  }
}
