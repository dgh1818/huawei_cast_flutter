# huawei_cast

`huawei_cast` is a Flutter plugin for OpenHarmony / HarmonyOS video casting.

It is built on top of `AVSession` and the system `AVCastPicker`, and is designed for apps that need to:

- publish media metadata to the system playback panel
- start casting by URL through the system picker
- sync play state and progress to the system media bar
- receive play / pause / seek events back from the system or remote device
- send playback commands to the connected receiver

## Platform support

- OpenHarmony / HarmonyOS only
- current implementation focuses on video playback
- the receiver must be able to access your media URL and image URL directly

If your backend is private, generate a signed URL or append a temporary auth token before calling `setMetadata(...)`.

## Installation

```yaml
dependencies:
  huawei_cast: ^1.0.0
```

For local development:

```yaml
dependencies:
  huawei_cast:
    path: ../huawei_cast
```

Then run:

```bash
flutter pub get
```

Import:

```dart
import 'package:huawei_cast/huawei_cast.dart';
```

## Recommended call order

1. Create `HuaweiCast()`.
2. Subscribe to `statusStream` and `remoteControlStream`.
3. Call `setMetadata(...)`.
4. Call `startCast(assetId)`.
5. Keep calling `setCurrentPosition(positionMs, isPlaying)` while playback changes.
6. Use `stopCast()` when the user wants to disconnect.

Important: `startCast(...)` expects metadata to already exist. Call `setMetadata(...)` first.

## API overview

### `setMetadata(contentUrl, mediaImage, title, durationMs)`

Creates or updates the underlying `AVSession`.

Use it to:

- set the media title shown in the system UI
- set the cover image shown in the cast UI
- provide the actual remote-playable URL
- provide the total duration in milliseconds

### `setCurrentPosition(positionMs, isPlaying)`

Updates the system playback bar and playback state.

Call it from your player listener or a throttled timer. This is required if you want the phone-side playback controls to show the correct elapsed time and play / pause state.

### `startCast(assetId)`

Opens the system cast picker and starts playback after the user selects a receiver.

If a cast controller already exists, the plugin tries to reuse it for the next media item.

### `statusStream`

Connection state events.

- `CastSessionState.connected`
- `CastSessionState.closed`

When connected, `HuaweiCastStatus.receiverName` contains the receiver name.

### `remoteControlStream`

Remote commands coming from the system or receiver.

- `play`
- `pause`
- `seekTo(positionMs)`

Mirror these events back to your local player so your UI and playback position stay aligned.

### `play()`, `pause()`, `seekTo(positionMs)`

Sends playback commands to the connected receiver.

Call them after the cast session becomes connected.

### `stopCast()`

Disconnects the active cast session and emits a disconnect event.

Use this for a real disconnect action.

### `clearSession()`

Clears local session state only.

Use this for cleanup when the page is disposed or when you want to drop prepared metadata without actively disconnecting a running cast session.

If the user is already casting and taps "Disconnect", use `stopCast()` instead.

## Syncing the playback bar

There are two directions to handle:

### Local player -> system playback panel

1. Call `setMetadata(...)`.
2. Continuously send `setCurrentPosition(positionMs, isPlaying)`.

This keeps metadata, elapsed time, and play state visible and correct in the HarmonyOS media session UI.

### System / remote receiver -> local player

Listen to `remoteControlStream` and apply the action to your local player:

- `play` -> local `play()`
- `pause` -> local `pause()`
- `seekTo` -> local `seekTo(...)`

This keeps your in-app play button and slider in sync with remote interactions.

## Example

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:huawei_cast/huawei_cast.dart';
import 'package:video_player/video_player.dart';

class CastCoordinator {
  CastCoordinator(this.controller) {
    _statusSub = _cast.statusStream.listen(_onStatus);
    _remoteSub = _cast.remoteControlStream.listen(_onRemoteControl);
    controller.addListener(_syncPlaybackBar);
  }

  final HuaweiCast _cast = HuaweiCast();
  final VideoPlayerController controller;

  StreamSubscription<HuaweiCastStatus>? _statusSub;
  StreamSubscription<HuaweiCastRemoteControlEvent>? _remoteSub;

  Future<void> prepareMetadata({
    required String contentUrl,
    required String imageUrl,
    required String title,
    required Duration duration,
  }) async {
    await _cast.setMetadata(
      contentUrl,
      imageUrl,
      title,
      duration.inMilliseconds,
    );
  }

  Future<void> startCasting(String assetId) async {
    await _cast.startCast(assetId);
  }

  Future<void> _onRemoteControl(HuaweiCastRemoteControlEvent event) async {
    switch (event.method) {
      case 'play':
        await controller.play();
        break;
      case 'pause':
        await controller.pause();
        break;
      case 'seekTo':
        await controller.seekTo(
          Duration(milliseconds: event.position ?? 0),
        );
        break;
    }
  }

  void _syncPlaybackBar() {
    final value = controller.value;
    if (!value.isInitialized) {
      return;
    }

    unawaited(
      _cast.setCurrentPosition(
        value.position.inMilliseconds,
        value.isPlaying,
      ),
    );
  }

  void _onStatus(HuaweiCastStatus status) {
    if (status.state == CastSessionState.connected) {
      debugPrint('Connected to: ${status.receiverName}');
      return;
    }

    debugPrint('Cast disconnected');
  }

  Future<void> disconnect() => _cast.stopCast();

  Future<void> dispose() async {
    controller.removeListener(_syncPlaybackBar);
    await _statusSub?.cancel();
    await _remoteSub?.cancel();
    await _cast.clearSession();
  }
}
```

## Switching media

To cast another video in the same flow:

1. call `setMetadata(...)` with the new media info
2. call `startCast(newAssetId)`

The plugin will try to reuse the active cast controller if possible.

## Raw native callbacks

You can inspect raw native method calls for debugging:

```dart
HuaweiCast.methodCalls.listen((call) {
  debugPrint('native call: ${call.method} ${call.arguments}');
});
```

Or install a custom handler:

```dart
HuaweiCast.setMethodCallHandler((call) async {
  debugPrint('custom handler: ${call.method}');
});
```
