import 'package:flutter/material.dart';
import 'package:kayo_package/kayo_package.dart';
import 'package:kayo_package/utils/base_color_utils.dart';

///  kayo_plugin
///  views.widget
///
///  Created by kayoxu on 2019/2/1 11:26 AM.
///  Copyright © 2019 kayoxu. All rights reserved.

class TextView extends StatelessWidget {
  TextView(this.text,
      {this.color = BaseColorUtils.colorGrey,
      this.borderColor,
      this.fontFamily,
      this.borderWidth = 1,
      this.size = 14,
      this.height,
      this.width,
      this.padding,
      this.margin,
      this.textAlign = TextAlign.left,
      this.fontWeight,
      this.borderRadius,
      this.bgColor,
      this.radius = 0,
      this.maxLine,
      this.left,
      this.gradient,
      this.border,
      this.alignment,
      this.mainAxisSize,
      this.rightIcon,
      this.rightIconHeight = 10,
      this.rightIconWidth = 8,
      this.rightIconMargin = const EdgeInsets.only(left: 3),
      this.onTap,
      this.overflow,
      this.rightIconColor,
      this.textDarkOnlyOpacity,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.darkTransColor = true});

  final MainAxisAlignment mainAxisAlignment;
  final bool? darkTransColor;
  final bool? textDarkOnlyOpacity;
  final Color? color;
  final Color? borderColor;
  final String? text;
  final String? fontFamily;
  final double size;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final TextAlign textAlign;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;

  final Color? bgColor;
  final double radius;
  final double borderWidth;

  final int? maxLine;

  final Widget? left;
  final Gradient? gradient;
  final bool? border;
  final Alignment? alignment;
  final MainAxisSize? mainAxisSize;
  final String? rightIcon;
  final double rightIconHeight;
  final double rightIconWidth;
  final EdgeInsets rightIconMargin;
  final Function()? onTap;
  final Color? rightIconColor;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    var tv = Text(
      text ?? '',
      maxLines: maxLine,
      overflow: overflow ?? TextOverflow.ellipsis,
      softWrap: true,
      textAlign: textAlign,
      style: TextStyle(
        color: color.toDark(textDarkOnlyOpacity: textDarkOnlyOpacity),
        fontSize: size,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
        decoration: TextDecoration.none,
        /*background:Paint()..color = Colors.yellowAccent*/
      ),
    );

    var v = null == left
        ? tv
        : Row(
            mainAxisSize: mainAxisSize ?? MainAxisSize.max,
            mainAxisAlignment: mainAxisAlignment,
            children: <Widget>[left!, tv],
          );

    var child2 = null == rightIcon
        ? v
        : Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              v,
              ImageView(
                height: rightIconHeight,
                width: rightIconWidth,
                margin: rightIconMargin,
                src: rightIcon,
                color: rightIconColor.dark,
              )
            ],
          );

    var c = null == alignment &&
            null == width &&
            null == height &&
            null == bgColor &&
            null == borderRadius &&
            null == borderColor &&
            null == margin &&
            null == padding &&
            null == border
        ? child2
        : Container(
            alignment: alignment,
            width: width,
            height: height,
            decoration: ((null != bgColor || true == border)
                ? BoxDecoration(
                    color: bgColor.toDark(darkTransColor: darkTransColor),
                    borderRadius: borderRadius ?? BorderRadius.circular(radius),
                    border: border != true
                        ? null
                        : Border.all(
                            width: borderWidth,
                            color: (borderColor ?? color).dark!),
                    gradient: gradient,
                  )
                : null),
            padding: padding,
            margin: null == onTap ? margin : null,
            child: child2,
          );

    return null == onTap
        ? c
        : Clickable(
            radius: radius,
            margin: null == onTap ? null : margin,
            onTap: onTap,
            bgColor: BaseColorUtils.transparent,
            child: c,
          );
  }
}
