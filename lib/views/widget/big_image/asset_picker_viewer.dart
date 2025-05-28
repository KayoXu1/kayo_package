///
/// [Author] Alex (https://github.com/Alex525)
/// [Date] 2020/3/31 16:27
///
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kayo_package/kayo_package.dart';
import 'package:kayo_package/views/widget/alert/datetime_picker/date_format.dart';
import 'package:kayo_package/views/widget/big_image/image_data.dart';

import 'asset_picker_viewer_builder_delegate.dart';

class ImageViewer<Asset> extends StatefulWidget {
  const ImageViewer({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final AssetPickerViewerBuilderDelegate<Asset> builder;

  @override
  ImageViewerState<Asset> createState() => ImageViewerState<Asset>();

  /// Static method to push with the navigator.
  /// 跳转至选择预览的静态方法
  static show(
    BuildContext context, {
    int currentIndex = 0,
    List<ImageData>? previewAssets,
    String? url,
    List<String>? urls,
    List<String>? paths,
    List<File>? files,
    String? urlHeader,
    String noImageText = '没有可以查看的图片',
    String? noImageSrc,
    bool? darkText,
    bool shouldReversePreview = false,
  }) async {
    previewAssets = previewAssets ?? [];
    if (!BaseSysUtils.empty(files)) {
      for (File f in files!) {
        previewAssets.add(ImageData(file: f));
      }
    }
    if (!BaseSysUtils.empty(urls)) {
      for (String u in urls!) {
        if (!BaseSysUtils.empty(u)) {
          previewAssets.add(ImageData(url: u));
        }
      }
    }
    if (!BaseSysUtils.empty(paths)) {
      for (String p in paths!) {
        if (!BaseSysUtils.empty(p)) {
          previewAssets.add(ImageData(path: p));
        }
      }
    }

    if (!BaseSysUtils.empty(url)) {
      if (url!.contains(',')) {
        var split = url.split(',');
        if (!BaseSysUtils.empty(split)) {
          for (String u in split) {
            if (!BaseSysUtils.empty(u)) {
              previewAssets.add(ImageData(url: u));
            }
          }
        }
      } else {
        previewAssets.add(ImageData(url: url));
      }
    }

    if (BaseSysUtils.empty(previewAssets)) {
      LoadingUtils.showInfo(data: noImageText);
      return;
    }

    if (!BaseSysUtils.empty(previewAssets)) {
      for (ImageData i in previewAssets) {
        if (!BaseSysUtils.empty(i.url)) {
          i.url = _getImageUrl(urlHeader ?? '', i.url!);
        }
      }
    }

    // await AssetPicker.permissionCheck();
    final Widget viewer = ImageViewer<ImageData>(
      builder: DefaultAssetPickerViewerBuilderDelegate(
        currentIndex: currentIndex,
        noImageSrc: noImageSrc,
        previewAssets: previewAssets,
        darkText: darkText ?? false,
        shouldReversePreview: shouldReversePreview,
      ),
    );
    final PageRouteBuilder<List<ImageData>> pageRoute =
        PageRouteBuilder<List<ImageData>>(
      pageBuilder: (_, __, ___) => viewer,
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
    /*   final List<ImageData>? result =
        await Navigator.of(context).push<List<ImageData>>(pageRoute);
    return result;*/
    Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) => viewer, fullscreenDialog: true));
  }

  static String _getImageUrl(String header, String? url) {
    url = url ?? '';
    return (url) == ''
        ? ''
        : url.contains('http') == true
            ? url
            : ('$header/$url'
                .replaceAll('$header///', '$header')
                .replaceAll('$header//', '$header')
                .replaceAll('$header/', '$header'));
  }
}

class ImageViewerState<Asset> extends State<ImageViewer<Asset>>
    with TickerProviderStateMixin {
  AssetPickerViewerBuilderDelegate<Asset> get builder => widget.builder;

  @override
  void initState() {
    super.initState();
    builder.initStateAndTicker(this, this);
  }

  @override
  void dispose() {
    builder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return builder.build(context);
  }
}
