import 'dart:async';

import 'package:flutter/services.dart';

class HuaweiCast {
  static const MethodChannel _channel = const MethodChannel('huawei_cast');

  static FutureOr<dynamic> loadMedia(
    String contentId,
    String streamType,
    String contentType,
    String contentUrl,
  ) async {
    final result = await _channel.invokeMethod('LoadVideo', <String, dynamic>{
      'contentId': contentId,
      'streamType': streamType,
      'contentType': contentType,
      'contentUrl': contentUrl,
    });
    return result;
  }
}
