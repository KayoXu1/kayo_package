import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kayo_package/kayo_package.dart';
import '../kayo_package_utils.dart';
import 'base_build_context_extension.dart';

extension ImageViewExtension on ImageView? {
  Widget dark() {
    if (KayoPackage.share.navigatorKey.currentContext.isDark){
      return Container();
    }
    return this!;
  }

}
