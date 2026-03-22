import 'dart:async';

import 'package:flutter/services.dart';

enum CastSessionState { connected, closed }

class HuaweiCastStatus {
  const HuaweiCastStatus({
    required this.state,
    this.receiverName = '',
  });

  final CastSessionState state;
  final String receiverName;
}

class HuaweiCastRemoteControlEvent {
  const HuaweiCastRemoteControlEvent._({
    required this.method,
    this.position,
  });

  const HuaweiCastRemoteControlEvent.play() : this._(method: 'play');

  const HuaweiCastRemoteControlEvent.pause() : this._(method: 'pause');

  const HuaweiCastRemoteControlEvent.seekTo(int position)
    : this._(method: 'seekTo', position: position);

  final String method;
  final int? position;
}

class HuaweiCast {
  static const MethodChannel _channel = MethodChannel('huawei_cast');
  static final StreamController<MethodCall> _methodCalls = StreamController<MethodCall>.broadcast();
  static final StreamController<HuaweiCastStatus> _statusEvents =
      StreamController<HuaweiCastStatus>.broadcast();
  static final StreamController<HuaweiCastRemoteControlEvent> _remoteControlEvents =
      StreamController<HuaweiCastRemoteControlEvent>.broadcast();
  static Future<dynamic> Function(MethodCall call)? _handler;
  static bool _initialized = false;
  static String _receiverName = '';

  HuaweiCast() {
    _ensureInitialized();
  }

  static Stream<MethodCall> get methodCalls {
    _ensureInitialized();
    return _methodCalls.stream;
  }

  Stream<HuaweiCastStatus> get statusStream {
    _ensureInitialized();
    return _statusEvents.stream;
  }

  Stream<HuaweiCastRemoteControlEvent> get remoteControlStream {
    _ensureInitialized();
    return _remoteControlEvents.stream;
  }

  String get receiverName {
    _ensureInitialized();
    return _receiverName;
  }

  static void _ensureInitialized() {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _channel.setMethodCallHandler(_dispatchMethodCall);
  }

  static Future<dynamic> _dispatchMethodCall(MethodCall call) async {
    _methodCalls.add(call);

    switch (call.method) {
      case 'castConnected':
        final arguments = call.arguments as Map<Object?, Object?>?;
        _receiverName = arguments?['receiverName'] as String? ?? '';
        _statusEvents.add(HuaweiCastStatus(state: CastSessionState.connected, receiverName: _receiverName));
        break;
      case 'castDisconnected':
        _receiverName = '';
        _statusEvents.add(const HuaweiCastStatus(state: CastSessionState.closed));
        break;
      case 'play':
        _remoteControlEvents.add(const HuaweiCastRemoteControlEvent.play());
        break;
      case 'pause':
        _remoteControlEvents.add(const HuaweiCastRemoteControlEvent.pause());
        break;
      case 'seekTo':
        final arguments = call.arguments as Map<Object?, Object?>?;
        final position = arguments?['position'] as int? ?? 0;
        _remoteControlEvents.add(HuaweiCastRemoteControlEvent.seekTo(position));
        break;
      default:
        break;
    }

    return _handler?.call(call);
  }

  static void setMethodCallHandler(
    Future<dynamic> Function(MethodCall call)? handler,
  ) {
    _ensureInitialized();
    _handler = handler;
  }

  FutureOr<dynamic> setMetadata(
    String contentUrl,
    String mediaImage,
    String title,
    int duration,
  ) async {
    final result = await _channel.invokeMethod('setMetadata', <String, dynamic>{
      'contentUrl': contentUrl,
      'mediaImage': mediaImage,
      'title': title,
      'duration': duration,
    });
    return result;
  }

  FutureOr<dynamic> startCast(String assetId) async {
    final result = await _channel.invokeMethod(
      'startCast',
      <String, dynamic>{'assetId': assetId},
    );
    return result;
  }

  FutureOr<dynamic> setCurrentPosition(int position, bool isPlaying) async {
    final result =
        await _channel.invokeMethod('setCurrentPosition', <String, dynamic>{
      'position': position,
      'isPlaying': isPlaying,
    });
    return result;
  }

  FutureOr<dynamic> clearSession() async {
    final result = await _channel.invokeMethod('clearSession');
    return result;
  }

  FutureOr<dynamic> play() async {
    final result = await _channel.invokeMethod('play');
    return result;
  }

  FutureOr<dynamic> pause() async {
    final result = await _channel.invokeMethod('pause');
    return result;
  }

  FutureOr<dynamic> seekTo(int position) async {
    final result = await _channel.invokeMethod(
      'seekTo',
      <String, dynamic>{'position': position},
    );
    return result;
  }

  FutureOr<dynamic> stopCast() async {
    final result = await _channel.invokeMethod('stopCast');
    return result;
  }
}
