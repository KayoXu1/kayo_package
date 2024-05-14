import 'package:flutter/material.dart';
import 'package:kayo_package/kayo_package.dart';
import 'package:map_launcher/map_launcher.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import 'gps_utils.dart';

///
///  kayo_package
///  map_utils.dart
///
///  Created by kayoxu on 2021/9/6 at 4:50 下午
///  Copyright © 2021 kayoxu. All rights reserved.
///
class MapUtils {
  static void showMapNavi(
      BuildContext? context, double latitude, double longitude,
      {String title = '目的地'}) async {
    List<Widget> list = [];

    ///苹果地图url
    var appleMapUrl = _appleMap(latitude, longitude);

    ///谷歌地图url
    var googleMapUrl = _googleMapUrl(latitude, longitude);

    ///百度地图url
    var baiduMapUrl = _baiduMapUrl(latitude, longitude);

    ///高德地图url
    var aMapUrl = _aMapUrl(latitude, longitude);

    ///腾讯地图url
    var tencentMapUrl = _tencentMapUrl(latitude, longitude);

    ///如果有苹果地图则加入
    if (await canLaunchUrl(appleMapUrl) == true && Platform.isIOS ||
        await MapLauncher.isMapAvailable(MapType.apple) == true) {
      var a = AlertSheet.sheetAction(
          text: _appMapTitle(),
          color: BaseColorUtils.colorAccent,
          showLine: true,
          callback: () async {
            Navigator.of(context!).pop();
            // launchUrl(appleMapUrl);
            MapLauncher.showDirections(
                mapType: MapType.apple,
                destination: Coords(latitude, longitude),
                destinationTitle: title);
          });

      list.add(a);
    }

    ///如果有谷歌地图则加入
    if (await canLaunchUrl(googleMapUrl) == true ||
        await MapLauncher.isMapAvailable(MapType.google) == true) {
      var a = AlertSheet.sheetAction(
          text: _googleMapTitle(),
          color: BaseColorUtils.colorAccent,
          showLine: true,
          callback: () async {
            Navigator.of(context!).pop();
            // launchUrl(googleMapUrl);
            MapLauncher.showDirections(
                mapType: MapType.google,
                destination: Coords(latitude, longitude),
                destinationTitle: title);
          });

      list.add(a);
    }

    ///如果有百度地图则加入
    if (await canLaunchUrl(baiduMapUrl) == true ||
        await MapLauncher.isMapAvailable(MapType.baidu) == true) {
      var a = AlertSheet.sheetAction(
          text: _baimapTitle(),
          color: BaseColorUtils.colorAccent,
          showLine: true,
          callback: () async {
            Navigator.of(context!).pop();
            // launchUrl(baiduMapUrl);
            MapLauncher.showDirections(
                mapType: MapType.baidu,
                destination: Coords(latitude, longitude),
                destinationTitle: title);
          });

      list.add(a);
    }

    ///如果有高德地图则加入
    if (await canLaunchUrl(aMapUrl) == true ||
        await MapLauncher.isMapAvailable(MapType.amap) == true) {
      var a = AlertSheet.sheetAction(
          text: _amapTitle(),
          color: BaseColorUtils.colorAccent,
          showLine: true,
          callback: () async {
            Navigator.of(context!).pop();
            // launchUrl(aMapUrl);
            MapLauncher.showDirections(
                mapType: MapType.amap,
                destination: Coords(latitude, longitude),
                destinationTitle: title);
          });

      list.add(a);
    }

    ///如果有腾讯地图则加入
    if (await canLaunchUrl(tencentMapUrl) == true ||
        await MapLauncher.isMapAvailable(MapType.tencent) == true) {
      var a = AlertSheet.sheetAction(
          text: _qqmapTitle(),
          color: BaseColorUtils.colorAccent,
          showLine: true,
          callback: () async {
            Navigator.of(context!).pop();
            // launchUrl(tencentMapUrl);
            MapLauncher.showDirections(
                mapType: MapType.tencent,
                destination: Coords(latitude, longitude),
                destinationTitle: title);
          });

      list.add(a);
    }

    AlertSheet.sheet(context,
        title: _selectNav(),
        showCancel: true,
        cancelText: _cancelTitle(),
        cancelColor: BaseColorUtils.colorBlackLite,
        children: list);
  }

  static bool _notCn() => KayoPackage.share.locale!.languageCode != 'zh';

  static String _selectNav() => _notCn() ? 'Select navigation map' : '选择导航';

  static String _cancelTitle() => _notCn() ? 'Cancel' : '取消';

  static String _qqmapTitle() => _notCn() ? 'QQ Map' : '腾讯地图';

  static String _amapTitle() => _notCn() ? 'Gaode Map' : '高德地图';

  static String _baimapTitle() => _notCn() ? 'Baidu Map' : '百度地图';

  static String _appMapTitle() => _notCn() ? 'Apple Map' : '苹果地图';

  static String _googleMapTitle() => _notCn() ? 'Google Map' : '谷歌地图';

  ///苹果地图URL
  static Uri _appleMap(latitude, longitude) {
    List<num> list = GpsUtils.bd09_To_Gcj02(latitude, longitude);
    latitude = list[0];
    longitude = list[1];
    var url = 'http://maps.apple.com/?&daddr=$latitude,$longitude';
    return Uri.parse(url);
  }

  ///谷歌地图URL
  static Uri _googleMapUrl(latitude, longitude) {
    List<num> list = GpsUtils.bd09_To_Gcj02(latitude, longitude);
    latitude = list[0];
    longitude = list[1];
    var url = 'google.navigation:q=$latitude,$longitude';
    return Uri.parse(url);
  }

  ///百度地图URL
  static Uri _baiduMapUrl(latitude, longitude) {
    var url =
        'baidumap://map/direction?destination=$latitude,$longitude&coord_type=bd09ll&mode=driving';
    return Uri.parse(url);
  }

  ///高德地图URL
  static Uri _aMapUrl(latitude, longitude) {
    List<num> list = GpsUtils.bd09_To_Gcj02(latitude, longitude);
    latitude = list[0];
    longitude = list[1];
    var url =
        '${Platform.isAndroid ? 'android' : 'ios'}amap://navi?sourceApplication=amap&lat=$latitude&lon=$longitude&dev=0&style=2';
    return Uri.parse(url);
  }

  ///腾讯地图URL
  static Uri _tencentMapUrl(latitude, longitude) {
    List<num> list = GpsUtils.bd09_To_Gcj02(latitude, longitude);
    latitude = list[0];
    longitude = list[1];
    var url =
        'qqmap://map/routeplan?type=drive&fromcoord=CurrentLocation&tocoord=$latitude,$longitude&referer=IXHBZ-QIZE4-ZQ6UP-DJYEO-HC2K2-EZBXJ';
    return Uri.parse(url);
  }
}
