import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:collection';
import 'package:kayo_package/http/bean/base_result_data.dart';

import 'package:kayo_package/kayo_package.dart';

import 'dart:convert' show json, utf8;

import 'base_code.dart';

///  tfblue_flutter_module
///  common.http
///
///  Created by kayoxu on 2021-08-05 14:41.
///  Copyright © 2021 kayoxu. All rights reserved.
///

abstract class BaseHttpManager {
  final tag = 'BaseHttpManager';

  Map<String, int> _httpPageMap = new HashMap();
  int _pageSize = 20;

  final CONTENT_TYPE_JSON = "application/json";
  final CONTENT_TYPE_FORM = "application/x-www-form-urlencoded";
  Map optionParams = {
    "timeoutMs": 15000,
    "token": null,
    "authorizationCode": null,
  };

  Dio? dio;

  ///加载中文字
  String textLoading();

  ///登录已失效，请重新登录
  String textLoginExpired();

  ///网络开小差了
  String textNetworkError();

  ///请求失败
  String textRequestError();

  ///模型转Json
  String toJson(data);

  ///json转模型
  Future<T?> getBean<T>(dynamic data);

  ///string转map
  Map<String, dynamic>? getMap(dynamic string);

  ///打印日志
  logInfo({String? tag, String? msg});

  releaseShowLog() {
    return false;
  }

  ///保存缓存数据
  Future<void> setSharedData(String sharedUrl, json);

  ///读取缓存数据
  Future<String?> getSharedString(String sharedUrl);

  ///获取基础的Header
  Future<Map<String, dynamic>> getBaseHeader();

  _httpPost(
      String url, Map<String, dynamic>? params, Map<String, dynamic>? header,
      {bool autoShowDialog = true,
      bool autoHideDialog = true,
      String? method,
      String? contentType,
      ValueChanged<BaseResultData>? onSuccess,
      ValueChanged<String>? onError,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    return netFetch(
        url, params, header, Options(method: method ?? 'POST'), contentType,
        autoHideDialog: autoHideDialog,
        autoShowDialog: autoShowDialog,
        method: method,
        onSuccess: onSuccess,
        onError: onError);
  }

  ///  不牵涉分页的时候不用传loadMore，传入loadMore需要传入 page，limit
  doHttpPost<T>(String url, Map? params,
      {Map<String, dynamic>? header,
      bool autoShowDialog = true,
      bool autoHideDialog = true,
      ValueChanged<T?>? onSuccess,
      ValueChanged<T?>? onCache,
      ValueChanged<String>? onError,
      String? method,
      bool? loadMore,
      String? subKey,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    if (!url.contains('http')) {
      return;
    }
    if (autoShowDialog) LoadingUtils.show(data: textLoading());

    var paramsTemp = Map<String, dynamic>.from(params ?? {});
    header = header ?? Map<String, dynamic>();
    header.addAll(await getBaseHeader());

    var sharedUrl = getSharedUrl(url);
    var hasPage = paramsTemp.containsKey("page");
    var hasSize = paramsTemp.containsKey("size");
    var hasLimit = paramsTemp.containsKey("limit");

    if (null != loadMore) {
      if (!hasPage) {
        if (!_httpPageMap.containsKey(sharedUrl)) {
          _httpPageMap[sharedUrl] = 1;
        }

        if (!loadMore) {
          _httpPageMap[sharedUrl] = 1;
        } else {
          _httpPageMap[sharedUrl] = (_httpPageMap[sharedUrl] ?? 0) + 1;
        }

        paramsTemp["page"] = _httpPageMap[sharedUrl];
      }
      if (!hasSize && !hasLimit) {
        _pageSize = 20;
        paramsTemp["size"] = _pageSize;
        paramsTemp["limit"] = _pageSize;
      }
      if (hasSize == true) {
        _pageSize = paramsTemp["size"];
      }
      if (hasLimit == true) {
        _pageSize = paramsTemp["limit"];
      }
    }

    if (null == loadMore || loadMore != true && null != onCache) {
      var loadCache = await getSharedString(sharedUrl);
      if (!BaseSysUtils.empty(loadCache)) {
        try {
          T? bean = await getBean<T>(loadCache);
          if (null != onCache) {
            onCache(bean);
          }
        } catch (e) {
          print(e);
        }
      }
    }

    _httpPost(
      url,
      paramsTemp,
      header,
      method: method,
      autoHideDialog: autoHideDialog,
      autoShowDialog: autoShowDialog,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onSuccess: (resultData) async {
        BaseResultData<T> data =
            BaseResultData(resultData.msg, resultData.code);

        if (resultData.code == BaseCode.RESULT_OK) {
          data.data = await getBean<T>(resultData.data);
        }

        String? errorData = '';

        if (/*resultData != null &&*/
            /*resultData.data != null &&*/ resultData.code ==
                BaseCode.RESULT_OK) {
          if (null != onSuccess) {
            onSuccess(data.data);
          }

          try {
            if (loadMore != true && null != onCache) {
              await setSharedData(sharedUrl, toJson(data.data));
            }
          } catch (e) {
            print(e);
          }
        } else {
          errorData = '${resultData.msg ?? resultData.data} ';
          if (BaseSysUtils.empty(errorData)) errorData = textRequestError();
          if (null != onError) onError(errorData);

          if (null != loadMore) {
            if (!hasPage) {
              if (!_httpPageMap.containsKey(sharedUrl)) {
                _httpPageMap[sharedUrl] = 1;
              }
              if (!loadMore) {
                _httpPageMap[sharedUrl] = 1;
              } else {
                _httpPageMap[sharedUrl] = (_httpPageMap[sharedUrl] ?? 1) - 1;
                if (_httpPageMap[sharedUrl]! < 1) {
                  _httpPageMap[sharedUrl] = 1;
                }
              }
            }
          }
        }
        if (autoHideDialog) LoadingUtils.dismiss();
      },
      onError: (e) {
        onError?.call(e.toString());
      },
    );
  }

  httpGet(url, params, {String? contentType}) {
    return netFetch(url, params, null, Options(method: 'GET'), contentType);
  }

  httpUpload(url, params,
      {Options? options, String? method, String? contentType}) {
    return netFetch(
        url,
        params,
        null,
        null != options ? options : Options(method: method ?? 'POST'),
        contentType);
  }

  ///发起网络请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ header] 外加头
  ///[ option] 配置
  netFetch(String? url, dynamic params, Map<String, dynamic>? header,
      Options? option, String? contentType,
      {bool autoShowDialog = true,
      bool autoHideDialog = true,
      String? method,
      ValueChanged<BaseResultData>? onSuccess,
      ValueChanged<String>? onError,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    url = '$url'.replaceAll('\n', '');

    if (BaseSysUtils.equals((method ?? '').toUpperCase(), 'GET')) {
      if (null != params && params is Map) {
        var m = Map<String, dynamic>.from(params);
        var keys = m.keys;
        int i = 0;
        for (String k in keys) {
          var m2 = m[k];
          if (m2 is List) {
            var d = '';
            var index = 0;
            for (var mm in m2) {
              if (index == 0) {
                d = '$k[]=$mm';
              } else {
                d = '$d&$k[]=$mm';
              }
              index++;
            }

            if (i == 0) {
              url = '$url?$d';
            } else {
              url = '$url&$d';
            }
          } else {
            if (i == 0) {
              url = '$url?$k=${m[k]}';
            } else {
              url = '$url&$k=${m[k]}';
            }
          }
          i++;
        }
      }
    }
    //没有网络
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      var msg = textNetworkError();
      _onError(onError, msg);
      return BaseResultData(msg, BaseCode.RESULT_ERROR_NETWORK_ERROR).sendMsg();
    }

    if (option != null) {
      option.headers = header;
    } else {
      option = Options(method: method ?? 'POST');
      option.headers = header;
    }
    if (!BaseSysUtils.empty(contentType)) {
      option.headers?['Content-Type	'] = contentType;
    }
    if (PlatformUtils.isWeb) {
      option.headers?['Access-Control-Allow-Origin'] = '*';
    }

    ///超时
    option.sendTimeout = Duration(seconds: 60 * 5);
    option.receiveTimeout = Duration(seconds: 60 * 12);

    Response? response;
    var errorHeader = '';
    if (BaseSysUtils.isDebug) {
      errorHeader = '$url\n';
    }

    if (null == dio) {
      dio = Dio();
    }

    try {
      response = await dio!.request(url!,
          data: params,
          options: option,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress);
    } on DioError catch (e) {
      Response? errorResponse;

      if (e.response != null) {
        errorResponse = e.response;
      } else {
        errorResponse =
            Response(statusCode: 666, requestOptions: RequestOptions(path: ''));
      }
      if (e.type == DioErrorType.connectionTimeout) {
        errorResponse?.statusCode = BaseCode.RESULT_ERROR_NETWORK_TIMEOUT;
      }

      if (BaseSysUtils.isDebug || releaseShowLog()) {
        logInfo(tag: tag, msg: '请求异常url: ' + url!);
        logInfo(tag: tag, msg: '请求异常请求头: ' + option.headers.toString());
        logInfo(
            tag: tag,
            msg: '请求异常参数: ' + /* params is Map ? toJson(params) :*/
                '$params');

        logInfo(
            tag: tag,
            msg: '请求异常: ' + e.toString() + " ___ " + e.response.toString());
      }

      //todo sbg
      if (errorResponse?.statusCode == KayoPackage.share.reLoginCode) {
        var msg = textLoginExpired();
        _onError(onError, msg);
        return BaseResultData(msg, 6).sendMsg();
      }

      String msg =
          (BaseSysUtils.isDebug ? errorHeader : '') + (e.message ?? '');
      var code = errorResponse?.statusCode ?? BaseCode.RESULT_ERROR_OTHER_ERROR;
      Map<String, dynamic>? map = Map<String, dynamic>();
      try {
        map = getMap(e.response.toString());
      } catch (e) {
        print(e);
        _onError(onError, e.toString());
        return BaseResultData(msg, code).sendMsg();
      }
      if (map?.containsKey('error') == true) {
        msg = map?['error'] ?? msg;
      } else if (map?.containsKey('message') == true &&
          map?['message'] is String) {
        msg = map?['message'] ?? msg;
      }
      if (map?.containsKey('code') == true) {
        code = map?['code'] ?? code;
      }
      _onError(onError, msg);
      return BaseResultData(msg, code).sendMsg();
    }

    if (BaseSysUtils.isDebug || releaseShowLog()) {
      logInfo(tag: tag, msg: '请求url: ' + url);
      logInfo(tag: tag, msg: '请求头: ' + option.headers.toString());
      if (params != null) {
        logInfo(tag: tag, msg: '请求参数: ' + params.toString());
      }

      var string = response.toString();
      logInfo(tag: tag, msg: '返回数据: ' + string);

      if (optionParams["authorizationCode"] != null) {
        logInfo(
            tag: tag,
            msg: 'authorizationCode: ' + optionParams["authorizationCode"]);
      }
    }

    try {
      var jsonStr = response.data;
      if (jsonStr is String) {
        jsonStr = await json.decode(response.data);
      }
      //todo sbg

      var jsonMap = Map<String, dynamic>();

      if (jsonStr == null) {
        jsonMap = {'code': 200, 'data': ''};
      } else if (jsonStr is List &&
          !(jsonStr.toString().contains('code') &&
              jsonStr.toString().contains('message'))) {
        jsonMap = {'code': 200, 'data': jsonStr};
      } else if (jsonStr is Map) {
        if (!jsonStr.containsKey('code') ||
            (!jsonStr.containsKey('timestamp') &&
                !jsonStr.containsKey('sign') &&
                !jsonStr.containsKey('message'))) {
          jsonMap = {'code': 200, 'data': jsonStr};
        } else {
          jsonMap = Map<String, dynamic>.from(jsonStr);
        }
      }

      if ((jsonMap.containsKey('page') && jsonMap.containsKey('code') ||
              (params is Map &&
                  params.containsKey('fullData') &&
                  params['fullData'] == true)) &&
          BaseCode.RESULT_OK == jsonMap['code']) {
        jsonMap = {'code': 200, 'data': jsonStr};
      }

      var resultData = BaseResultData.fromJson(jsonMap);
      if (/*null != resultData*/ true) {
        if (BaseCode.RESULT_OK != resultData.code) {
          var msg = resultData.msg ?? resultData.message;
          _onError(onError, msg ?? '');
          return BaseResultData(msg, resultData.code).sendMsg();
        }

        onSuccess?.call(resultData);
        if (autoHideDialog) LoadingUtils.dismiss();
        return resultData;
      }
    } catch (e) {
      logInfo(tag: tag, msg: e.toString());

      var message = errorHeader + e.toString();

      _onError(onError, message);
      return BaseResultData(
              message, BaseCode.RESULT_ERROR_NETWORK_JSON_EXCEPTION)
          .sendMsg();
    }
  }

  void _onError(ValueChanged<String>? onError, String message) {
    onError?.call(message);
    LoadingUtils.dismiss();
  }

  String getSharedUrl(String? url) {
    return (url ?? "")
        .replaceAll("/", "_")
        .replaceAll(":", "_")
        .replaceAll("?", "_")
        .replaceAll(".", "_");
  }
}
