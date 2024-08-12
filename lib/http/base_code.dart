import 'package:event_bus/event_bus.dart';

import 'base_http_error_event.dart';

///  tfblue_flutter_module
///  common.http
///
///  Created by kayoxu on 2019-06-10 17:20.
///  Copyright © 2019 kayoxu. All rights reserved.
class BaseCode {
  ///网络错误
  static const RESULT_ERROR_NETWORK_ERROR = -1;

  ///网络超时
  static const RESULT_ERROR_NETWORK_TIMEOUT = -2;

  ///网络返回数据格式化异常
  static const RESULT_ERROR_NETWORK_JSON_EXCEPTION = -3;

  static const RESULT_ERROR_NO_USER_ID = 1;
  static const RESULT_ERROR_NO_SIGN = 2;
  static const RESULT_ERROR_NO_TIMESTAMP = 3;
  static const RESULT_ERROR_NO_TYPE = 4;
  static const RESULT_ERROR_TIMESTAMP_ERROR = 5;
  static const RESULT_ERROR_SIGN_ERROR = 6;
  static const RESULT_ERROR_SIGN_ERROR_401 = 401;
  static const RESULT_ERROR_USER_ERROR = 7;
  static const RESULT_ERROR_AUTH_ERROR = 50;

  //签名错误
  static const RESULT_ERROR_TOKEN_ERROR = 100;

  //自定义错误
  static const RESULT_ERROR_OTHER_ERROR = 150;

  //请求成功
  static const RESULT_OK = 200;

  static final EventBus eventBus = new EventBus();

  static errorHandleFunction(code, message) {
    eventBus.fire(BaseHttpErrorEvent(code, message));
    return message;
  }
}
