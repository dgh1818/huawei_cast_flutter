<p align="center">
  <h1 align="center"> <code>image_gallery_saver</code> </h1>
</p>


本项目基于 [image_gallery_saver@2.0.3](https://pub.dev/packages/image_gallery_saver/versions/2.0.3) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
dependencies:
  image_gallery_saver:
    git:
      url: https://gitcode.com/openharmony-sig/flutter_image_gallery_saver.git
```

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 使用案例

使用案例详见 [ohos/example](./example)

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.7.12-ohos-1.0.6; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

| Name                | return          | Description                                                                                                             | Type     | ohos Support |
|---------------------|-------------------------------------------------------------------------------------------------------------------------|----------|-------------------|-------------------|
| saveImage(Uint8List imageBytes, {int quality = 80, String? name, bool isReturnImagePathOfIOS = false})                                 | FutureOr<dynamic> | 将图片保存到图库。 | function | yes          |
| saveFile(String file, {String? name, bool isReturnPathOfIOS = false}) | Future                                                  | 将位于 [file] 的 PNG、JPG、JPEG 图像或视频保存到本地设备的媒体图库中。 | function | yes          |

### 参数
| Name                | return          | Description                                                                                                             | Type     | ohos Support |
|---------------------|-------------------------------------------------------------------------------------------------------------------------|----------|-------------------|-------------------|
| imageBytes                                 |  | 图片的字节数据。 | Uint8List | yes          |
| quality                                 |  | 保存图片时的质量。 | int | yes          |
| name                                 |  | 保存到照片库时的文件名。 | String | yes          |
| isReturnImagePathOfIOS                                 |  | 是否返回iOS设备上的图片路径。 | bool | yes          |
| file                                 |  | 指定要保存的目标文件的路径或内容。 | String | yes          |

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

## 5. 遗留问题

无

## 6. 其他

## 7. 开源协议

本项目基于 [MIT开源协议](https://gitcode.com/openharmony-sig/flutter_image_gallery_saver/blob/master/LICENSE) ，请自由地享受和参与开源。



> 模板版本: v0.0.1