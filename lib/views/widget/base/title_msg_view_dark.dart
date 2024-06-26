import 'package:flutter/material.dart';
import 'package:kayo_package/utils/base_color_utils.dart';
import 'package:kayo_package/extension/base_widget_extension.dart';
import 'package:kayo_package/kayo_package.dart';
import 'package:kayo_package/views/widget/base/text_view_dark.dart';

import 'clickable.dart';
import 'text_view.dart';

///  flutter_demo
///
///
///  Created by kayoxu on 2019/1/23.
///  Copyright © 2019 kayoxu. All rights reserved.

class TitleMsgViewDark extends StatelessWidget {
  ///left
  final String? title;
  final Widget? preTitle;
  final Function()? onTap;
  final bool? showLine;

  ///left权重
  final int? titleFlex;

  ///left如果是长文本需要设置位true
  final bool? longTitle;
  final int? titleMaxLines;
  final TextStyle? textStyleTitle;
  final TextStyle? textStyleMsg;

  ///right
  final String? msg;
  final Widget? subMsg;

  ///right权重
  final int? msgFlex;
  final double? miniHeight;

  ///right如果是长文本需要设置位true
  final bool? longMsg;
  final int? msgMaxLines;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool? showRightArrow;

  ///中间的间隔
  final Widget? spacer;
  final CrossAxisAlignment? crossAxisAlignment;
  final Color? bgColor;

  const TitleMsgViewDark({
    Key? key,
    required this.title,
    this.titleFlex,
    this.onTap,
    this.titleMaxLines = 1,
    this.longTitle,
    this.preTitle,
    this.msg,
    this.msgFlex,
    this.msgMaxLines = 2,
    this.longMsg = true,
    this.subMsg,
    this.margin,
    this.padding,
    this.miniHeight,
    this.spacer,
    this.textStyleTitle,
    this.textStyleMsg,
    this.crossAxisAlignment,
    this.showLine,
    this.showRightArrow = true,
    this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var children2 = [
      longTitle == true || titleFlex != null
          ? _buildTitleView(context).addExpanded(flex: titleFlex ?? 1)
          : _buildTitleView(context),
      spacer ??
          SizedBox(
            width: 10,
            height: 0,
          ),
      longMsg == true || msgFlex != null
          ? _buildMsgView(context).addExpanded(flex: msgFlex ?? 1)
          : _buildMsgView(context)
    ];

    if (null != preTitle) children2.insert(0, preTitle!);
    if (null != subMsg) children2.add(subMsg!);
    if (true == showRightArrow && null != onTap) {
      children2.add(Center(
        child: Icon(
          Icons.chevron_right,
          color: Colors.grey[600],
          size: 20,
        ),
      ));
    }

    var tp = (50 - 14) / 2;

    return Container(
      margin: margin,
      padding:
          padding ?? EdgeInsets.only(top: tp, bottom: tp, left: 16, right: 16),
      decoration: BoxDecoration(
        color: bgColor ?? BaseColorUtils.darkWhite(context: context),
        border: Border(
          bottom: Divider.createBorderSide(context, width: 0.6),
        ),
      ),
      constraints: BoxConstraints(
        minHeight: miniHeight ?? 50.0,
      ),
      child: Row(
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: children2,
      ),
    ).inkWell(onTap: onTap);
  }

  TextViewDark _buildTitleView(BuildContext context) {
    return TextViewDark(
      title ?? '',
      maxLine: titleMaxLines ?? 1,
      textStyle: textStyleTitle ?? context.theme.textTheme.bodyMedium,
      margin: EdgeInsets.only(right: 0),
    );
  }

  TextViewDark _buildMsgView(BuildContext context) {
    return TextViewDark(
      msg ?? '',
      textAlign: TextAlign.right,
      maxLine: msgMaxLines ?? 1,
      textStyle: textStyleMsg ?? context.theme.textTheme.bodySmall,
    );
  }
}
