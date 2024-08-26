// this utility class is used to load images from the application directory

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_loader.freezed.dart';

@freezed
class ImageData with _$ImageData {
  const factory ImageData({
    required Image image,
    required int width,
    required int height,
  }) = _ImageData;
}

class ImageLoader {
  static Future<ImageData> loadImage(String path) async {
    final dir = Directory.current.path;
    final file = File('$dir/$path');
    final completer = Completer<ImageData>();
    if (!file.existsSync()) {
      completer.completeError('File not found: $path');
      return completer.future;
    }

    final bytes = await file.readAsBytes();
    final image = Image.memory(bytes);
    image.image.resolve(const ImageConfiguration())
      ..addListener(
        ImageStreamListener((info, _) {
          print('Image loaded: ${info.image.width}x${info.image.height}');
          if (completer.isCompleted) {
            return;
          }
          completer.complete(ImageData(
            image: image,
            width: info.image.width,
            height: info.image.height,
          ));
        }, onError: (dynamic exception, StackTrace? stackTrace) {
          print('Image load failed: $exception');
          if (completer.isCompleted) {
            return;
          }
          completer.completeError(exception, stackTrace);
        }),
      );
    return completer.future;
  }
}
