import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'base_view_model.dart';

///
///  kayo_package
///  base_view_model_list.dart
///
///  Created by kayoxu on 2020/8/6 at 6:26 PM
///  Copyright © 2020 kayoxu. All rights reserved.
///

///只有列表，可分页
abstract class BaseViewModelList<T> extends BaseViewModel {
  static int pageNumFirst = 1;

  // final int pageSize = 20;
  int _currentPageNum = pageNumFirst;

  List<T> data = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  RefreshController get refreshController => _refreshController;

  int getPageSize() {
    return 20;
  }

  int getPageIndex() {
    return _currentPageNum;
  }

  int get pageSize => getPageSize();

  loadDataWithPageIndex(int pageIndex,
      {ValueChanged<List<T>>? onSuccess,
      ValueChanged<List<T>>? onCache,
      ValueChanged<String>? onError}) {
    _currentPageNum = pageIndex;
    loadData(
        pageIndex: pageIndex,
        onSuccess: (data) {
          _setData(data);
          if (null != onSuccess) {
            onSuccess(data);
          }
        },
        onCache: (data) {
          if (null != onCache) {
            _setData(data);
            onCache(data);
          }
        },
        onError: (data) {
          refreshController.loadFailed();
          if (null != onError) {
            onError(data);
          }
        });
  }

  // 下拉刷新
  refresh(
      {ValueChanged<List<T>>? onSuccess,
      ValueChanged<List<T>>? onCache,
      ValueChanged<String>? onError}) async {
    var hasMoreData = hasMore() == true;
    setBusy();

    if (hasMoreData) _currentPageNum = pageNumFirst;
    try {
      loadData(
          pageIndex: hasMoreData ? _currentPageNum : null,
          onSuccess: (data) {
            _setData(data);
            if (null != onSuccess) {
              onSuccess(data);
            }
          },
          onCache: (data) {
            if (null != onCache) {
              _setData(data, loadData: false);
              onCache(data);
            }
          },
          onError: (data) {
            if (null != onError) {
              onError(data);
            }
            refreshController.refreshFailed();
            setIdle();
          });
    } catch (e, s) {
//      if (init) list.clear();
//      setError(e, s);
      setIdle();
    }
  }

  void _setData(List<T>? data, {bool loadData = true}) {
    if ((data?.length ?? 0) == 0) {
      refreshController.refreshCompleted(resetFooterState: true);
      this.data.clear();
      if (loadData == true) {
        setEmpty();
      }
    } else {
//      onCompleted(data);
      this.data.clear();
      this.data.addAll(data!);
      refreshController.refreshCompleted();
      // 小于分页的数量,禁止上拉加载更多
      if (data.length < pageSize) {
        refreshController.loadNoData();
      } else {
        //防止上次上拉加载更多失败,需要重置状态
        refreshController.loadComplete();
      }
      if (loadData == true) {
        setIdle();
      }
    }
  }

  /// 上拉加载更多
  loadMore(
      {ValueChanged<List<T>>? onSuccess,
      ValueChanged<List<T>>? onCache,
      ValueChanged<String>? onError}) async {
    try {
      loadData(
          pageIndex: ++_currentPageNum,
          onSuccess: (data) {
            _setMoreData(data);
            if (null != onSuccess) {
              onSuccess(data);
            }
          },
          onCache: (data) {
            if (null != onCache) {
              _setMoreData(data);
              onCache(data);
            }
          },
          onError: (data) {
            _currentPageNum--;
            refreshController.loadFailed();
            if (null != onError) {
              onError(data);
            }
          });
    } catch (e, s) {
      _currentPageNum--;
      refreshController.loadFailed();
      debugPrint('error--->\n' + e.toString());
      debugPrint('statck--->\n' + s.toString());
      return null;
    }
  }

  void _setMoreData(List<T> data) {
    if (data.isEmpty) {
      _currentPageNum--;
      refreshController.loadNoData();
    } else {
      //          onCompleted(data);
      this.data.addAll(data);
      if (data.length < pageSize) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
      notifyListeners();
    }
  }

  /// 加载数据
  loadData(
      {int? pageIndex,
      ValueChanged<List<T>>? onSuccess,
      ValueChanged<List<T>>? onCache,
      ValueChanged<String>? onError});

  ///有上拉加载更多
  bool hasMore();

  @override
  void initState() {
    super.initState();
    if (autoLoadData == true) {
      setBusy();
      refresh();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
