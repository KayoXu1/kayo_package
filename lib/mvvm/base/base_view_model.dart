import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:kayo_package/kayo_package.dart';
import 'package:kayo_package/mvvm/base/base_view_model_bus_event.dart';

import 'base_view_theme_bus_event.dart';

///
///  kayo_package
///  base_view_model.dart
///
///  Created by kayoxu on 2020/8/6 at 2:39 PM
///  Copyright © 2020 kayoxu. All rights reserved.
///

enum ViewState {
  idle,
  busy, //加载中
  empty, //无数据
  error, //加载失败
}

class BaseViewModel with ChangeNotifier {
  late bool _disposed = false;
  late ViewState _viewState;
  BuildContext? context;
  late bool autoLoadData;
  bool isMobileResolution = false;
  StreamSubscription? _themeChangeNotifier;

  bool? themeNotifier = false;

  BaseViewModel(
      {ViewState? viewState,
      BuildContext? context,
      bool? themeNotifier = false})
      : _viewState = (viewState ?? ViewState.idle),
        context = context {
    this.themeNotifier = themeNotifier;

    debugPrint('BaseViewModel---constructor--->$runtimeType');
    // BaseViewModelBusEvent.handleFunction(
    //     viewModel: '$runtimeType',
    //     type: BaseViewModelBusEvent.BASE_VIEW_MODEL_PUSH);
  }

  /// ViewState
  ViewState get viewState => _viewState;

  setIsMobileResolution(BuildContext? context) {
    isMobileResolution =
        (MediaQuery.of(context ?? this.context!).size.width) < 768;
  }

  setBuildContext(BuildContext context) {
    this.context = context;
  }

  set viewState(ViewState viewState) {
//    _viewStateError = null;
    _viewState = viewState;
    notifyListeners();
  }

  bool get isBusy => viewState == ViewState.busy;

  bool get isIdle => viewState == ViewState.idle;

  bool get isEmpty => viewState == ViewState.empty;

  bool get isError => viewState == ViewState.error;

  void setIdle() {
    viewState = ViewState.idle;
  }

  void setBusy() {
    viewState = ViewState.busy;
  }

  void setEmpty() {
    viewState = ViewState.empty;
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    debugPrint('BaseViewModel dispose -->$runtimeType');

    BaseViewModelBusEvent.handleFunction(
        viewModel: '$runtimeType',
        type: BaseViewModelBusEvent.BASE_VIEW_MODEL_POP);
    if (themeNotifier == true) {
      _themeChangeNotifier?.cancel();
      _themeChangeNotifier = null;
    }
    super.dispose();
  }

  void initState() {
    debugPrint('BaseViewModel initState -->$runtimeType');
    if (themeNotifier == true) {
      _themeChangeNotifier = BaseViewModelThemeBusEvent.eventBus
          .on<BaseViewModelThemeBusEvent>()
          .listen((event) {
        this.onThemeChange(event.data);
      });
    }

    BaseViewModelBusEvent.handleFunction(
        viewModel: '$runtimeType',
        type: BaseViewModelBusEvent.BASE_VIEW_MODEL_PUSH);
  }

  void onThemeChange(dynamic data) {
    if (themeNotifier == true) {
      notifyListeners();
    }
  }

  void onTickerProvider(TickerProvider? vsync) {}
}
