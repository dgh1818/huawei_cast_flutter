/**
 * MIT License
 *
 * Copyright (c) 2025 dgh1818
 * https://github.com/dgh1818/immich_ohos
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import MethodChannel, {
  MethodCallHandler,
  MethodResult
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { AbilityAware, AbilityPluginBinding } from '@ohos/flutter_ohos';
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';


const TAG = "HuaweiCastPlugin"

/** ImageGallerySaverPlugin2 **/
export default class HuaweiCastPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  public avCastController?: avSession.AVCastController;
  public avSession?: avSession.AVSession;
  public sessionId?: string;
  public playItem?: avSession.AVQueueItem;
  private channel: MethodChannel | null = null;
  private applicationContext: common.UIAbilityContext | null = null;
  //private fileMimeType: FileMimeTypeUtil = new FileMimeTypeUtil();
  private binding: AbilityPluginBinding | null = null;

  constructor() {
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.binding = binding;
    this.applicationContext = binding.getAbility().context;
  }

  onDetachedFromAbility(): void {

  }

  getUniqueClassName(): string {
    return "HuaweiCastPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "caster");
    this.channel.setMethodCallHandler(this);
    //this.applicationContext = binding.getApplicationContext();
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
    }
  }

  async onMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      case "LoadVideo":
        let contentId: string = call.args.get("contentId");
        let streamType: string = call.args.get("streamType");
        let contentType: string = call.args.get("contentType");
        let contentUrl: string = call.args.get("contentUrl");
        return result.success(await this.loadMedia(contentId, streamType, contentType,contentUrl,result));
      default:
        return result.notImplemented();
    }
  }


  /**
   * 设置输出设备变化监听器
   */
  private setOutputDeviceChangeListener(): void {
    this.avSession?.on('outputDeviceChange', (connectState: avSession.ConnectionState,
      device: avSession.OutputDeviceInfo) => {
      const castCategory = device?.devices?.[0].castCategory;
      // 成功连接远程设备
      if (castCategory === avSession.AVCastCategory.CATEGORY_REMOTE &&
        connectState === avSession.ConnectionState.STATE_CONNECTED) {
        // 获取cast控制器
        this.avSession?.getAVCastController().then(async (controller: avSession.AVCastController) => {
          //Log.info(0x0666, TAG, 'success to get avController');
          this.avCastController = controller;
          if(this.playItem) {
            this.startCast(this.playItem);
          }
        })
      }

      // 远端断开 或 本地连上 都算断开投播
      const isDisConnect = (castCategory === avSession.AVCastCategory.CATEGORY_REMOTE &&
        connectState === avSession.ConnectionState.STATE_DISCONNECTED)
        || (castCategory === avSession.AVCastCategory.CATEGORY_LOCAL &&
          connectState === avSession.ConnectionState.STATE_CONNECTED);
      if (isDisConnect) {
        //this.stopCast(this.playItem);
      }
    });
  }

  /**
   * 开始投播
   */
  private async startCast(mediaInfo:avSession.AVQueueItem): Promise<void> {

    // 通知业务开始投播
    //const deviceName: string = '客厅的智慧屏';
    //this.callbackOnStart?.(deviceName);

    // 构建播放影片队列数据，开始prepare
    try {
      await this.avCastController?.prepare(mediaInfo);
      this.avCastController!.start(this.playItem);
    } catch (err) {
      //this.handlerCastError(err, 'avSessionError', 'prepare');
    }
  }

  async loadMedia(contentId: string, streamType: string, contentType: string, contentUrl: string, result: MethodResult) :Promise<void>{
    if (this.applicationContext) {
      this.playItem = {
        itemId: 1,
        description: {
          assetId: contentId,
          title: contentId,
          mediaUri: contentUrl,
        }
      };
      let avCastPicker = new avSession.AVCastPickerHelper(this.applicationContext);
      let tag = "createNewSession";

      let avCastPickerOptions: avSession.AVCastPickerOptions = {
        sessionType: 'video',
      }
      avCastPicker.select(avCastPickerOptions).then(() => {
        console.info('select successfully');



        avSession.createAVSession(this.applicationContext, 'cast', "video").then(async (data: avSession.AVSession) => {
          this.avSession = data;
          this.sessionId = this.avSession.sessionId;
          console.info(`CreateAVSession : SUCCESS : sessionId = ${this.sessionId}`);
          this.avCastController = await this.avSession.getAVCastController();
          this.setOutputDeviceChangeListener();


        }).catch((err: BusinessError) => {
          console.error(`CreateAVSession BusinessError: code: ${err.code}, message: ${err.message}`);
        });
      }).catch((err: BusinessError) => {
        console.error(`AVCastPicker.select failed with err: ${err.code}, ${err.message}`);
      });
    }
  }
}
