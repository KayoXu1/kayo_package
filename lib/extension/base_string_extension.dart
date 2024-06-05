import 'package:flutter/material.dart';
import 'package:kayo_package/kayo_package.dart';

extension BaseStringExtension on String? {
  int toInt({int value = 0}) {
    try {
      if (_isNotEmpty(this)) {
        value = int.tryParse('$this') ?? value;
      }
      return value;
    } catch (e) {
      print(e);
      return value;
    }
  }

  double toDouble({double value = 0.0}) {
    try {
      if (_isNotEmpty(this)) {
        value = double.tryParse(this!) ?? value;
      }
      return value;
    } catch (e) {
      print(e);
      return value;
    }
  }

  String fixDouble({String unit = ''}) {
    var data = '${this ?? '0'}$unit';
    if (data.endsWith('.0$unit')) {
      data = data.replaceAll('.0$unit', '$unit');
    } else if (data.endsWith('.00$unit')) {
      data = data.replaceAll('.00$unit', '$unit');
    } else if (data.endsWith('.000$unit')) {
      data = data.replaceAll('.000$unit', '$unit');
    } else if (data.endsWith('.0000$unit')) {
      data = data.replaceAll('.0000$unit', '$unit');
    }
    return data;
  }

  Color toColor(
      {Color defaultColor = const Color(0xff333333), double opacity = 1}) {
    try {
      if (_isNotEmpty(this)) {
        if ((this!.length == 3) ||
            (this!.length == 4 && this!.startsWith('#')) ||
            (this!.length == 5 && this!.startsWith('#'))) {
          // #000
          var cs = this!.replaceAll('#f', '').replaceAll('#F', '');
          var c = '';
          for (var i in cs.characters) {
            c = '$c$i$i';
          }
          c = c.replaceAll('#', '');
          return Color(
              int.parse(c.substring(0, c.length), radix: 16) + 0xFF000000)
              .withOpacity(opacity);
        } else if (this!.length == 6 &&
            int.tryParse(this!.substring(0, 6), radix: 16) != null) {
          //        000000
          return Color(int.parse(this!.substring(0, 6), radix: 16) + 0xFF000000)
              .withOpacity(opacity);
        } else if (this!.length == 7 &&
            int.tryParse(this!.substring(1, 7), radix: 16) != null) {
          //        #000000
          return Color(int.parse(this!.substring(1, 7), radix: 16) + 0xFF000000)
              .withOpacity(opacity);
        } else if (this!.length == 8 &&
            int.tryParse(this!.substring(0, 8), radix: 16) != null) {
          //        ff000000
          return Color(int.parse(this!.substring(0, 8), radix: 16))
              .withOpacity(opacity);
        } else if (this!.length == 9 &&
            int.tryParse(this!.substring(1, 9), radix: 16) != null) {
          //        #ff000000
          return Color(int.parse(this!.substring(1, 9), radix: 16))
              .withOpacity(opacity);
        } else {
          return defaultColor.withOpacity(opacity);
        }
      } else {
        return defaultColor;
      }
    } catch (e) {
      print(e);
      return defaultColor.withOpacity(opacity);
    }
  }

  String toTimeStr({String? format, String? defaultTime}) {
    try {
      if (_isNotEmpty(this)) {
        if (BaseSysUtils.isNumber(this!)) {
          var t = BaseSysUtils.str2Int(this!);
          if (this!.length == 10) {
            return BaseTimeUtils.timestampToTimeStr(t * 1000, format: format);
          } else if (this!.length == 13) {
            return BaseTimeUtils.timestampToTimeStr(t, format: format);
          } else {
            return BaseTimeUtils.timestampToTimeStr((t - 60 * 60 * 0) * 1000,
                format: format);
          }
        } else {
          return this!;
        }
      }
      return defaultTime ?? KayoPackage.share.nullText;
    } catch (e) {
      print(e);
      return this ?? (defaultTime ?? KayoPackage.share.nullText);
    }
  }

  String firstChar({String? defaultValue = ''}) {
    if (_isNotEmpty(this)) {
      return this!.toUpperCase().substring(0, 1);
    } else {
      return defaultValue ?? '';
    }
  }

  DateTime? toDate({String? format, String? defaultTime}) {
    try {
      if (_isNotEmpty(this)) {
        if (BaseSysUtils.isNumber(this!)) {
          var t = BaseSysUtils.str2Int(this!);
          if (this!.length == 10) {
            return DateTime.fromMillisecondsSinceEpoch(t * 1000);
          } else if (this!.length == 13) {
            return DateTime.fromMillisecondsSinceEpoch(t);
          } else {
            return null;
          }
        } else {
          return BaseTimeUtils.timeStrToDateTime(this, format: defaultTime);
        }
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  int toTimestamp({bool second = true, String? format}) {
    format = format ?? BaseTimeUtils.formatDefault;
    if (_isNotEmpty(this)) {
      var timestamp = BaseTimeUtils.timeStrToTimestamp(this!, format: format);
      return second == true ? timestamp ~/ 1000 : timestamp;
    } else {
      return (this ?? 0) as int;
    }
  }

  String safeCardNo() {
    if (_isNotEmpty(this)) {
      var d = this ?? '';
      if (d.length == 18) {
        d = d.substring(0, 4) +
            '**********' +
            d.substring(d.length - 4, d.length);
      }
      return d;
    } else {
      return '';
    }
  }

  String replaceExceptFirst(Pattern from, String replace) {
    if ((this ?? '').contains(from)) {
      List<String> arr = (this ?? '').split(from);
      String value = '';
      arr.forEach((f) {
        value += '$f${value.contains(from) ? replace : from}';
      });
      return value;
    } else {
      return this ?? '';
    }
  }

  List<int> toListInt({String split = ","}) {
    var split1 = (this ?? '').split(split);
    List<int> arr = [];
    for (var d in split1) {
      var element = d.toInt(value: -1);
      if (-1 != element) {
        arr.add(element);
      }
    }
    return arr;
  }

  List<String> toListStr({String split = ","}) {
    var split1 = (this ?? '').split(split);
    List<String> arr = [];
    for (var d in split1) {
      if (!BaseSysUtils.empty(d)) {
        arr.add(d);
      }
    }
    return arr;
  }
}

bool _isNotEmpty(String? t) => null != t && t.isNotEmpty;
