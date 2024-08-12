import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kayo_package/kayo_package.dart';

extension ImageViewExtension on ImageView? {
  Widget dark({bool darkNoBg = true}) {
    if (KayoPackage.share.navigatorKey.currentContext.isDark && darkNoBg) {
      return Container();
    }
    return this!;
  }
}
