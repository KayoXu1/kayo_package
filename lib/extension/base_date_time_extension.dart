import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kayo_package/kayo_package.dart';

extension BaseDateTimeExtension on DateTime? {
  String toTimeStr({String? format, String? defaultTime, bool tz = false, bool isUtc = false}) {
    try {
      if (null != this) {
        var seconds = this!.millisecondsSinceEpoch;
        if (tz) {
          if (isUtc) {
            seconds = seconds + (DateTime.now().timeZoneOffset.inSeconds * 1000);
          } else {
            seconds = seconds + (DateTime.now().timeZoneOffset.inMilliseconds);
          }
           var replaceAll = BaseTimeUtils.timestampToTimeStr(
              seconds, format: format).replaceAll(" ", "T");
          return "${replaceAll}Z";
        } else {
          return BaseTimeUtils.timestampToTimeStr(seconds, format: format);
        }
      }
      return defaultTime ?? KayoPackage.share.nullText;
    } catch (e) {
      print(e);
      return defaultTime ?? KayoPackage.share.nullText;
    }
  }
}
