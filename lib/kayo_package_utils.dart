import 'package:flutter/material.dart';
import 'package:kayo_package/kayo_package.dart';
import 'package:kayo_package/views/widget/alert/datetime_picker_new/flutter_cupertino_datetime_picker.dart';

///
///  kayo_package
///  kayo_package_utils.dart
///
///  Created by kayoxu on 2021/5/25 at 4:40 下午
///  Copyright © 2021 kayoxu. All rights reserved.
///

class KayoPackage {
  factory KayoPackage._init() {
    if (_singleton == null) {
      _singleton = KayoPackage._();
    }
    return _singleton!;
  }

  KayoPackage._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static KayoPackage get share => KayoPackage._init();
  static KayoPackage? _singleton;

  String nullText = '无';
  String loadingText = '加载中, 请稍等...';
  bool? ignoreSSL = false;
  Locale? locale = Locale('zh');
  String? imageSourcePrefix = '';
  int reLoginCode = BaseCode.RESULT_ERROR_SIGN_ERROR_401;
  bool enableDark = false;
  Function(BuildContext context)? onTapToolbarBack;
  Function(BuildContext context, String page, Map<String, dynamic>? resultArgs,
      dynamic resultData)? onNotifyPop;

  bool isDark() {
    return KayoPackage.share.navigatorKey.currentContext.isDark;
  }

  ThemeData get theme =>
      Theme.of(KayoPackage.share.navigatorKey.currentContext!);

  BuildContext get context => KayoPackage.share.navigatorKey.currentContext!;

  init({
    String? nullText,
    String? loadingText,
    String? formatDefault,
    String? imageSourcePrefix,
    DateTimePickerLocale? dateTimePickerLocale,
    String? dataPickerLocale,
    Locale? locale,
    bool? ignoreSSL,
    bool? enableDark,
    int? reLoginCode,
    Color? colorPrimary,
    Color? colorPrimaryLight,
    Color? colorPrimaryDark,
    Color? colorAccent,
    Color? colorAccentLite,
    Color? colorAccentLiteLite,
    Function(BuildContext context)? onTapToolbarBack,
    Function(BuildContext context, String page,
            Map<String, dynamic>? resultArgs, dynamic resultData)?
        onNotifyPop,
  }) {
    this.locale = locale ?? this.locale;
    BaseColorUtils.colorPrimary = colorPrimary ?? BaseColorUtils.colorPrimary;
    BaseColorUtils.colorPrimaryLight =
        colorPrimary ?? BaseColorUtils.colorPrimaryLight;
    BaseColorUtils.colorPrimaryDark =
        colorPrimary ?? BaseColorUtils.colorPrimaryDark;
    BaseColorUtils.colorAccent = colorPrimary ?? BaseColorUtils.colorAccent;
    BaseColorUtils.colorAccentLite =
        colorPrimary ?? BaseColorUtils.colorAccentLite;
    BaseColorUtils.colorAccentLiteLite =
        colorPrimary ?? BaseColorUtils.colorAccentLiteLite;
    this.reLoginCode = reLoginCode ?? this.reLoginCode;
    this.enableDark = enableDark ?? this.enableDark;

    this.imageSourcePrefix = imageSourcePrefix ?? this.imageSourcePrefix ?? '';
    this.ignoreSSL = ignoreSSL ?? this.ignoreSSL ?? false;
    if (null != locale) {
      if (locale.languageCode == 'zh') {
        this.nullText = '无';
        this.loadingText = '加载中, 请稍等...';
        BaseTimeUtils.formatDefault = 'yyyy-MM-dd HH:mm';
        DateTimePicker.defaultDateTimePickerLocale = DateTimePickerLocale.zh_cn;
        DataPicker.defaultDataPickerLocale = DataPickerLocale.zh_cn;
      } else {
        this.nullText = 'null';
        this.loadingText = 'loading...';
        BaseTimeUtils.formatDefault = 'MM-dd-yyyy HH:mm';
        DateTimePicker.defaultDateTimePickerLocale = DateTimePickerLocale.en_us;
        DataPicker.defaultDataPickerLocale = DataPickerLocale.en_us;
      }
    }
    this.nullText = nullText ?? this.nullText;
    this.loadingText = loadingText ?? this.loadingText;
    BaseTimeUtils.formatDefault = formatDefault ?? BaseTimeUtils.formatDefault;
    DateTimePicker.defaultDateTimePickerLocale =
        dateTimePickerLocale ?? DateTimePicker.defaultDateTimePickerLocale;
    DataPicker.defaultDataPickerLocale =
        dataPickerLocale ?? DataPicker.defaultDataPickerLocale;

    this.onTapToolbarBack = onTapToolbarBack ?? this.onTapToolbarBack;
    this.onNotifyPop = onNotifyPop ?? this.onNotifyPop;
  }

  setBuddhist(bool buddhist) {
    BaseTimeUtils.calendarType =
        buddhist == true ? CalendarType.Buddhist : CalendarType.normal;
  }

  setDateFormat(String? format) {
    BaseTimeUtils.formatDefault = format ?? BaseTimeUtils.formatDefault;
  }
}
