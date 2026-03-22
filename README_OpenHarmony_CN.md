# huawei_cast

`huawei_cast` 是一个面向 OpenHarmony / HarmonyOS 的 Flutter 投屏插件，当前主要用于视频投屏。

它基于系统 `AVSession` 和 `AVCastPicker`，可以帮助你完成这些事：

- 把标题、封面、时长同步到系统播控条
- 拉起系统投屏设备选择器并按 URL 开始投屏
- 持续同步播放进度和播放状态
- 接收系统或远端设备回传的播放、暂停、拖动事件
- 在 Flutter 里主动控制远端播放、暂停、跳转、断开

## 平台支持

- 仅支持 OpenHarmony / HarmonyOS
- 当前实现以视频播放为主
- 远端设备必须能直接访问你传入的 `contentUrl` 和 `mediaImage`

如果你的视频地址需要鉴权，不要直接传只有本机能访问的地址。应该在调用 `setMetadata(...)` 前，自己拼接短期有效的 token 或签名 URL。

## 安装

```yaml
dependencies:
  huawei_cast: ^1.0.0
```

如果你本地联调插件，也可以这样写：

```yaml
dependencies:
  huawei_cast:
    path: ../huawei_cast
```

执行：

```bash
flutter pub get
```

导入：

```dart
import 'package:huawei_cast/huawei_cast.dart';
```

## 推荐调用顺序

建议按下面这个时序接入：

1. 创建 `HuaweiCast()` 实例。
2. 监听 `statusStream` 和 `remoteControlStream`。
3. 先调用 `setMetadata(...)`。
4. 再调用 `startCast(assetId)` 拉起系统投屏选择器。
5. 播放过程中持续调用 `setCurrentPosition(positionMs, isPlaying)`。
6. 用户点击断开时调用 `stopCast()`。

重点：`startCast(...)` 依赖 `setMetadata(...)` 事先缓存好的标题、封面、媒体地址。如果你没先调 `setMetadata(...)`，原生侧没有完整媒体信息，投屏流程就不完整。

## API 说明

### `setMetadata(contentUrl, mediaImage, title, durationMs)`

作用：创建或更新当前媒体对应的本地 `AVSession`。

它负责把这些信息交给系统播控和投屏能力：

- `contentUrl`：远端设备真正要播放的视频地址
- `mediaImage`：系统投屏 UI 里展示的封面地址
- `title`：播控条和投屏面板展示的标题
- `durationMs`：总时长，单位是毫秒

什么时候调：

- 当前视频切换时
- 你的鉴权 URL 刷新时
- 标题、封面、时长变化时
- 你希望系统播控条先预热当前媒体信息时

### `setCurrentPosition(positionMs, isPlaying)`

作用：同步系统播控条上的播放进度和播放状态。

这是“同步播控条”的关键 API。你可以在播放器监听器里调，也可以做一个节流后的定时同步。只要你持续上报当前位置和播放态，系统侧的进度条、播放按钮状态就会跟着更新。

参数说明：

- `positionMs`：当前播放位置，单位毫秒
- `isPlaying`：当前是否处于播放态

### `startCast(assetId)`

作用：开始投屏。

第一次调用时会拉起系统投屏设备选择器，用户选中设备后开始投放当前媒体。

参数里的 `assetId` 是当前媒体的标识。真正给远端播放的是 `contentUrl`，`assetId` 更像是这条媒体在投屏会话里的唯一 key。

如果当前已经有一个活跃的 cast controller，插件会优先复用它来切下一条视频，而不是每次都重新弹设备选择器。

### `statusStream`

作用：监听连接状态。

目前会发两种状态：

- `CastSessionState.connected`
- `CastSessionState.closed`

连接成功时，`HuaweiCastStatus.receiverName` 会带上当前设备名，你可以直接拿来显示“正在投屏到某某电视”。

### `remoteControlStream`

作用：监听系统播控或远端设备回传的控制事件。

目前会收到三类事件：

- `play`
- `pause`
- `seekTo(positionMs)`

这条流非常重要。因为用户可能不是在你 App 内点按钮，而是在系统播控条、电视端或者外部遥控入口上操作。你需要把这些事件再同步回本地播放器，这样本地 UI 和真实播放状态才不会跑偏。

### `play()`, `pause()`, `seekTo(positionMs)`

作用：从 Flutter 主动控制远端设备。

适合用于你自己的投屏控制面板，比如：

- 自定义“播放 / 暂停”按钮
- 自定义拖动进度条
- 快进到某个位置

注意：这几个方法要在已经连接成功之后再调。否则原生侧还没有准备好 cast controller，会发不出去。

### `stopCast()`

作用：主动断开当前投屏。

它会做这些事：

- 释放远端 cast controller
- 停止当前投屏
- 清理本地 session
- 主动回发 `castDisconnected`

如果你的页面上有“断开投屏”按钮，应该调用这个方法。

### `clearSession()`

作用：只清理本地 `AVSession`、metadata 和监听器。

它更适合这些场景：

- 页面销毁，需要做本地清理
- 你提前 `setMetadata(...)` 预热了会话，但最后没有真的开始投屏
- 你只是想把本地 session 状态收掉

如果当前已经在投屏，而你的目标是“断开设备”，请优先用 `stopCast()`，不要只调 `clearSession()`。

## 怎么做播控条同步

播控同步分两部分。

### 1. 本地播放器 -> 系统播控条

步骤：

1. 媒体就绪后先调一次 `setMetadata(...)`
2. 播放过程中持续调用 `setCurrentPosition(positionMs, isPlaying)`

这样系统播控条里的这些内容就会同步：

- 标题
- 封面
- 总时长
- 当前播放位置
- 当前是播放还是暂停

### 2. 系统播控条 / 远端设备 -> 本地播放器

监听 `remoteControlStream`，然后把事件转给你自己的播放器：

- 收到 `play` 就调本地播放器 `play()`
- 收到 `pause` 就调本地播放器 `pause()`
- 收到 `seekTo` 就调本地播放器 `seekTo(...)`

这样用户在系统播控条上拖进度、点暂停时，你 App 内的视频控件和进度条也会同步变化。

## 完整示例

下面是一段比较接近实际接入方式的示例，使用 `video_player` 做本地播放器同步：

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
      debugPrint('已连接设备: ${status.receiverName}');
      return;
    }

    debugPrint('投屏已断开');
  }

  Future<void> playRemote() => _cast.play();

  Future<void> pauseRemote() => _cast.pause();

  Future<void> seekRemote(Duration position) {
    return _cast.seekTo(position.inMilliseconds);
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

## 切换下一条视频怎么做

如果你正在投屏，想切到另一条视频，推荐顺序是：

1. 先重新调用 `setMetadata(newContentUrl, newImageUrl, newTitle, newDurationMs)`
2. 再调用 `startCast(newAssetId)`

插件会优先尝试复用当前连接，而不是强制重建全部投屏流程。

## 调试

如果你想看更底层的原生回调，可以监听原始方法流：

```dart
HuaweiCast.methodCalls.listen((call) {
  debugPrint('native call: ${call.method} ${call.arguments}');
});
```

或者自定义全局回调：

```dart
HuaweiCast.setMethodCallHandler((call) async {
  debugPrint('custom handler: ${call.method}');
});
```

一般情况下，`statusStream` 和 `remoteControlStream` 就够用了。

## 常见问题

### 为什么我点了投屏，但电视没开始播？

优先检查这几件事：

- 你有没有先调用 `setMetadata(...)`
- `contentUrl` 是否真的能被远端设备访问
- `mediaImage` 是否是合法可访问地址
- 当前媒体是不是视频

### 为什么播控条有标题，但进度不动？

通常是因为你没有持续调用 `setCurrentPosition(...)`。

### 断开时该调哪个？

- 要真正断开投屏：`stopCast()`
- 只做本地资源清理：`clearSession()`
