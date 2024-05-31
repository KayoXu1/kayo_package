import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kayo_package/kayo_package.dart';
import 'package:kayo_package/views/widget/alert/datetime_picker/date_format.dart';
import 'package:kayo_package/views/widget/alert/datetime_picker_new/flutter_cupertino_datetime_picker.dart';

///
///  flutter_cupertino_datetime_picker
///  date_time_picker.dart
///
///  Created by kayoxu on 3/31/21 at 2:46 PM
///  Copyright © 2021 kayoxu. All rights reserved.
///

typedef OnDateTimePick(DateTime startDateTime, DateTime endDateTime);

///
///
/// DateTimePicker.show(context, dateFormat: 'yyyy-MM-dd HH:mm:ss',
// onDateTimePick: (startDate, endDate) {
// print('DateTimePicker $startDate $endDate');
// });
///
///

class DateTimePicker {
  static DateTimePickerLocale defaultDateTimePickerLocale =
      DateTimePickerLocale.zh_cn;

  static show(BuildContext? context,
      {bool? showEnd,
      DateTimePickerLocale? locale,
      // bool? showWeek,
      String? title,
      DateTime? maxStartDate,
      DateTime? minStartDate,
      DateTime? nowStartDate,
      DateTime? maxEndDate,
      DateTime? minEndDate,
      DateTime? nowEndDate,
      String? dateFormat,
      // String? dateFormat = 'yyyy年-MM月-dd日 HH时:mm分:ss秒',
      OnDateTimePick? onDateTimePick,
      OnDateTimePick? onDateTimeChange,
      Function()? onCancel,
      String? startTitle,
      String? endTitle}) {
    locale = locale ?? defaultDateTimePickerLocale;
    dateFormat =
        (dateFormat ?? BaseTimeUtils.formatDefault).replaceAll('hh', 'HH');

    double heightTitle = 46;
    double heightTitleTime = 46;
    double heightTitleWeek = 46;
    double heightTime = 110;
    double wHeight = BaseSysUtils.getHeight(context) / 2 - 1;
    var height = heightTitle +
        (heightTitleTime * ((showEnd ?? true) ? 1 : 0) +
                heightTime +
                heightTitleWeek * ((true) ? 0 : 0)) *
            ((showEnd ?? true) ? 2 : 1);

    if (height >= wHeight) {
      var d = height - wHeight;
      heightTime = heightTime - (d / ((showEnd ?? true) ? 2 : 1));
      height = heightTitle +
          (heightTitleTime * ((showEnd ?? true) ? 1 : 0) +
                  heightTime +
                  heightTitleWeek * ((true) ? 0 : 0)) *
              ((showEnd ?? true) ? 2 : 1);
    }

    nowStartDate = nowStartDate ?? DateTime.now();
    nowEndDate = nowEndDate ?? DateTime.now();
    nowStartDate = DateTime(nowStartDate.year, nowStartDate.month,
        nowStartDate.day, nowStartDate.hour, nowStartDate.minute, 0);
    nowEndDate = DateTime(nowEndDate.year, nowEndDate.month, nowEndDate.day,
        nowEndDate.hour, nowEndDate.minute, 59);

    showModalBottomSheet(
      context: context ?? KayoPackage.share.context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            color: Colors.white.darkNull,
          ),
          child: SafeArea(
              child: Container(
            height: height,
            // height: w.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _inkWell(
                        height: heightTitle,
                        color: BaseColorUtils.colorBlackLiteLite.darkNull,
                        title: DatePickerI18n.getLocaleCancel(locale!),
                        onTap: () {
                          Navigator.pop(context);
                          onCancel?.call();
                        }),
                    Container(
                      height: heightTitle,
                      alignment: Alignment.center,
                      child: Text(
                        title ??
                            (locale == DateTimePickerLocale.zh_cn
                                ? ('选择时间${(showEnd ?? true) ? '段' : ''}')
                                : ''),
                        style: TextStyle(
                            color: Color(0xff333333).darkNull,
                            fontSize: 17,
                            // height: heightTitle,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    _inkWell(
                        height: heightTitle,
                        title: DatePickerI18n.getLocaleDone(locale),
                        onTap: () {
                          var startDateTime = (nowStartDate ?? DateTime.now());
                          var endDateTime = nowEndDate ?? DateTime.now();

                          if (nowStartDate?.isAfter(endDateTime) == true &&
                              showEnd == true) {
                            // FlutterToast
                            Fluttertoast.showToast(
                                msg: locale != DateTimePickerLocale.zh_cn
                                    ? 'The end time cannot be earlier than the start time'
                                    : '结束时间不能早于开始时间');
                            return;
                          }

                          Navigator.pop(context);

                          startDateTime = DateTime(
                              startDateTime.year,
                              startDateTime.month,
                              startDateTime.day,
                              startDateTime.hour,
                              startDateTime.minute,
                              0);

                          endDateTime = DateTime(
                              endDateTime.year,
                              endDateTime.month,
                              endDateTime.day,
                              endDateTime.hour,
                              endDateTime.minute,
                              59);
                          onDateTimePick?.call(startDateTime, endDateTime);
                        }),
                  ],
                ),
                showEnd != true
                    ? SizedBox(
                        height: 0,
                        width: 0,
                      )
                    : _titleTime(
                        heightTitleTime,
                        startTitle ??
                            (locale == DateTimePickerLocale.zh_cn
                                ? '开始时间'
                                : 'Start Time')),
                Container(
                  height: heightTime,
                  child: DateTimePickerWidget(
                    minDateTime: minStartDate ?? DateTime(1970),
                    maxDateTime:
                        maxStartDate ?? DateTime(2049, 12, 31, 23, 59, 59),
                    initDateTime: nowStartDate,
                    dateFormat: dateFormat!,
                    pickerTheme: DateTimePickerTheme(
                        showTitle: false,
                        backgroundColor: BaseColorUtils.transparent,
                        itemTextStyle: TextStyle(
                            color: Color(0xFF333333).dark, fontSize: 16.0)),
                    onChange: (dateTime, selectedIndex) {
                      nowStartDate = dateTime;
                      onDateTimeChange?.call(nowStartDate!, nowEndDate!);
                    },
                  ),
                ),
                showEnd != true
                    ? SizedBox(
                        height: 0,
                        width: 0,
                      )
                    : _titleTime(
                        heightTitleTime,
                        endTitle ??
                            (locale == DateTimePickerLocale.zh_cn
                                ? '结束时间'
                                : 'End Time')),
                showEnd != true
                    ? SizedBox(
                        height: 0,
                        width: 0,
                      )
                    : Container(
                        height: heightTime,
                        child: DateTimePickerWidget(
                          minDateTime: minEndDate ?? DateTime(1970),
                          maxDateTime:
                              maxEndDate ?? DateTime(2049, 12, 31, 23, 59, 59),
                          initDateTime: nowEndDate,
                          dateFormat: dateFormat,
                          pickerTheme: DateTimePickerTheme(
                              showTitle: false,
                              backgroundColor: BaseColorUtils.transparent,
                              itemTextStyle: TextStyle(
                                  color: Color(0xFF333333).dark,
                                  fontSize: 16.0)),
                          onChange: (dateTime, selectedIndex) {
                            nowEndDate = dateTime;
                            onDateTimeChange?.call(nowStartDate!, nowEndDate!);
                          },
                        ),
                      ),
              ],
            ),
          )),
        );
      },
    );
  }

  static Container _titleTime(double heightTitleTime, String? title) {
    return Container(
      height: heightTitleTime,
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(left: 20),
      // width: 120,
      child: Text(
        title ?? '',
        style: TextStyle(
            color: Color(0xff666666).darkNull,
            fontSize: 14,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  static InkWell _inkWell(
      {double? height, String? title, Function()? onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height ?? 40,
        alignment: Alignment.center,
        width: 75,
        child: Text(
          title ?? '',
          style: TextStyle(
              color: color ?? BaseColorUtils.colorAccent.darkNull,
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
