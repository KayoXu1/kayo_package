import 'dart:convert';

import 'package:kayo_package/kayo_package.dart';

extension BaseListExtension on List? {
  bool get isList => null != this || (this is List);

  List get dealNotList => isList == true ? this! : [];

  String toStringWith(
      {String splitUnit = '、', String? def, bool? removeEmpty}) {
    if (removeEmpty ?? true) {
      this?.removeWhere((e) => BaseSysUtils.empty(e));
    }
    String str = this.dealNotList.toString();
    return str
        .substring(1, str.length - 1)
        .replaceAll(', ', splitUnit)
        .defaultStr(data: def ?? KayoPackage.share.nullText);
  }

  String? toJson2({bool removeNull = true}) {
    if (null != this) {
      var jsonStr = '';
      if (!(this is String)) {
        jsonStr = jsonEncode(this);
      } else {
        jsonStr = this! as String;
      }
      var jd = json.decode(jsonStr);
      if (jd is Map) {
        removeMapNull(jd);
      } else if (jd is List) {
        for (var j in jd) {
          if (j is Map) {
            removeMapNull(j);
          }
        }
      }
      return json.encode(jd);
    }
    return null;
  }
}
