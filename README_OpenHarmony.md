<p align="center">
  <h1 align="center"> <code>image_gallery_saver</code> </h1>
</p>



This project is based on [image_gallery_saver@2.0.3](https://pub.dev/packages/image_gallery_saver/versions/2.0.3).



## 1. Installation and Usage


### 1.1 Installation


Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
dependencies:
  image_gallery_saver:
    git:
      url: https://gitcode.com/openharmony-sig/flutter_image_gallery_saver.git
```

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Usage

For use cases [ohos/example](./example)

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.7.12-ohos-1.1.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

| Name                | return          | Description                                                                                                             | Type     | ohos Support |
|---------------------|-------------------------------------------------------------------------------------------------------------------------|----------|-------------------|-------------------|
| saveImage(Uint8List imageBytes, {int quality = 80, String? name, bool isReturnImagePathOfIOS = false})                                 | FutureOr<dynamic> | save image to Gallery. | function | yes          |
| saveFile(String file, {String? name, bool isReturnPathOfIOS = false}) | Future                                                  | Save the PNG，JPG，JPEG image or video located at [file] to the local device media gallery. | function | yes          |

### Partners
| Name                | return          | Description                                                                                                             | Type     | ohos Support |
|---------------------|-------------------------------------------------------------------------------------------------------------------------|----------|-------------------|-------------------|
| imageBytes                                 |  | The byte data of the image. | Uint8List | yes          |
| quality                                 |  | The quality of image saving. | int | yes          |
| name                                 |  | The file name when saving to the photo library. | String | yes          |
| isReturnImagePathOfIOS                                 |  | Whether to return the image path on the iOS device. | bool | yes          |
| file                                 |  | Specify the path or content of the target file to be saved. | String | yes          |

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

## 5. Known Issues

not

## 6. Others

## 7. License

This project is licensed under  [MIT License](https://gitcode.com/openharmony-sig/flutter_image_gallery_saver/blob/master/LICENSE) .

> Template version: v0.0.1