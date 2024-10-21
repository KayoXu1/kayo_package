import 'package:flutter/material.dart';
import 'package:kayo_package/utils/base_color_utils.dart';
import 'package:kayo_package/extension/base_widget_extension.dart';

import 'clickable.dart';
import 'text_view.dart';

///  flutter_demo
///
///
///  Created by kayoxu on 2019/1/23.
///  Copyright © 2019 kayoxu. All rights reserved.

class TitleMsgView extends StatelessWidget {
  ///left
  final String? title;
  final double? titleSize;
  final Color? titleColor;
  final Color? bgColor;
  final FontWeight? titleFontWeight;
  final Widget? preTitle;
  final Function()? onTapMsg;

  ///left权重
  final int? titleFlex;

  ///left如果是长文本需要设置位true
  final bool? longTitle;
  final int? titleMaxLines;

  ///right
  final String? msg;
  final double? msgSize;
  final Color? msgColor;
  final FontWeight? msgFontWeight;
  final Widget? subMsg;

  ///right权重
  final int? msgFlex;

  ///right如果是长文本需要设置位true
  final bool? longMsg;
  final int? msgMaxLines;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  ///中间的间隔
  final Widget? spacer;
  final CrossAxisAlignment? crossAxisAlignment;

  const TitleMsgView({
    Key? key,
    required this.title,
    this.titleSize,
    this.titleColor,
    this.titleFontWeight,
    this.titleFlex,
    this.titleMaxLines = 1,
    this.longTitle,
    this.preTitle,
    this.msg,
    this.msgSize,
    this.msgColor,
    this.msgFontWeight,
    this.msgFlex,
    this.msgMaxLines = 2,
    this.longMsg = true,
    this.subMsg,
    this.margin,
    this.padding,
    this.spacer,
    this.bgColor,
    this.crossAxisAlignment,
    this.onTapMsg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var children2 = [
      longTitle == true || titleFlex != null
          ? _buildTitleView().addExpanded(flex: titleFlex ?? 1)
          : _buildTitleView(),
      spacer ??
          SizedBox(
            width: 10,
            height: 0,
          ),
      longMsg == true || msgFlex != null
          ? _buildMsgView(onTap: onTapMsg).addExpanded(flex: msgFlex ?? 1)
          : _buildMsgView(onTap: onTapMsg)
    ];

    if (null != preTitle) children2.insert(0, preTitle!);
    if (null != subMsg) children2.add(subMsg!);

    return Container(
      margin: margin,
      padding: padding,
      color: bgColor ?? BaseColorUtils.white,
      child: Row(
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: children2,
      ),
    );
  }

  TextView _buildTitleView() {
    return TextView(
      title ?? '',
      fontWeight: titleFontWeight,
      maxLine: titleMaxLines ?? 1,
      size: titleSize ?? 14,
      color: titleColor ?? BaseColorUtils.colorBlack,
      margin: EdgeInsets.only(right: 0),
    );
  }

  TextView _buildMsgView({Function()? onTap}) {
    return TextView(
      msg ?? '',
      fontWeight: msgFontWeight,
      size: msgSize ?? 14,
      textAlign: TextAlign.right,
      onTap: onTap,
      maxLine: msgMaxLines ?? 1,
      color: msgColor ?? BaseColorUtils.colorBlackLiteLite,
    );
  }
}
