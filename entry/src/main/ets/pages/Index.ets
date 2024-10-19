import {
  ImageEditor,
  EditOption,
  ScaleOption,
  FlipOption,
  RotateOption,
  ClipOption,
  AddTextOption,
} from "@candies/image_editor"
import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { EditorText } from '@candies/image_editor/src/main/ets/components/option/AddTextOption';

import { common2D, drawing } from '@kit.ArkGraphics2D';

@Entry
@Component
struct Index {
  pixelMap: PixelMap | null = null;
  private rfd: resourceManager.RawFileDescriptor | undefined = undefined;
  private imageInfo: image.ImageInfo | undefined = undefined;
  dialogController: CustomDialogController | null = null;

  // 在自定义组件即将析构销毁时将dialogController置空
  aboutToDisappear() {
    this.dialogController = null // 将dialogController置空
  }

  aboutToAppear() {
    this.init();
  }

  async init(): Promise<void> {
    // Stage模型
    const context: Context = getContext(this);
    // 获取resourceManager资源管理器
    const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
    let rfd = await resourceMgr.getRawFd('image.jpg');
    const imageSource: image.ImageSource = image.createImageSource(rfd);

    let decodingOptions: image.DecodingOptions = {
      sampleSize: 1,
      editable: true,
    };
    this.pixelMap = await imageSource.createPixelMap(decodingOptions);
    this.imageInfo = await this.pixelMap!.getImageInfo();
    this.rfd = rfd;
  }

  async showNewImage(option: EditOption): Promise<void> {
    if (this.rfd == undefined) {
      return;
    }
    if (this.pixelMap != undefined) {
      this.pixelMap.release();
    }


    this.pixelMap = await ImageEditor.instance.handleImageRawfile(this.rfd!, [option]);

    this.dialogController = new CustomDialogController({
      builder: ImageDialog({
        pixelMap: this.pixelMap,
      }),
      autoCancel: true,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        if (this.pixelMap != null) {
          this.pixelMap.release();
        }
      },
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: -20 },
      customStyle: false,
      cornerRadius: 20,
      width: 300,
      // height: 500,
      borderWidth: 1,
      borderStyle: BorderStyle.Dashed, //使用borderStyle属性，需要和borderWidth属性一起使用
      borderColor: Color.Blue, //使用borderColor属性，需要和borderWidth属性一起使用
      backgroundColor: Color.White,
    });
    this.dialogController.open();
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Row() {
        Button('Scale', { type: ButtonType.Normal, stateEffect: true }).onClick(() => {
          let width = this.imageInfo!.size.width;
          let height = this.imageInfo!.size.height;
          this.showNewImage(new ScaleOption(width / 4, height, false, true));
        }).margin(5)
        Button('Flip', { type: ButtonType.Normal, stateEffect: true }).onClick(() => {

          this.showNewImage(new FlipOption(true, true));
        }).margin(5)
        Button('Rotate', { type: ButtonType.Normal, stateEffect: true }).onClick(() => {
          this.showNewImage(new RotateOption(65));
        }).margin(5)
      }
      Row() {
        Button('Clip', { type: ButtonType.Normal, stateEffect: true }).onClick(() => {
          let width = this.imageInfo!.size.width;
          let height = this.imageInfo!.size.height;
          this.showNewImage(new ClipOption((width - width / 2) / 2, (height - height / 2) / 2, width / 2, height / 2));
        }).margin(5)
        Button('AddText', { type: ButtonType.Normal, stateEffect: true }).onClick(() => {
          let texts: Array<EditorText> = [];
          let width = this.imageInfo!.size.width;
          let height = this.imageInfo!.size.height;
          texts.push(new EditorText("AddText", width / 2, height / 2, vp2px(18), {
            alpha: 255,
            red: 255,
            green: 0,
            blue: 0,
          }))
          this.showNewImage(new AddTextOption(texts));
        }).margin(5)
      }

      Image($rawfile("image.jpg")).objectFit(ImageFit.Contain)


      // if (this.rfd != undefined) {
      //   Canvas(this.context)
      //     .width('100%')
      //     .height('100%')// .backgroundColor('#ffff00')
      //     .onReady(() => {
      //       if (this.pixelMap != undefined) {
      //         this.draw();
      //       }
      //     })
      // }
    }
    .width('100%')
    .height('100%')
  }
}


@CustomDialog
@Component
struct ImageDialog {
  pixelMap: PixelMap | null = null;
  controller?: CustomDialogController

  build() {
    Column() {
      Button('关闭')
        .onClick(() => {
          if (this.controller != undefined) {
            this.controller.close()
          }
        }).backgroundColor(0xffffff).fontColor(Color.Black)
      if (this.pixelMap != null) {
        Image(this.pixelMap).objectFit(ImageFit.Contain)
      }
    }
    .borderRadius
    (10
    )
  }
}

