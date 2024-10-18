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
  pixelMap: PixelMap | undefined = undefined;
  options: Array<EditOption> = [];
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @State private rfd: resourceManager.RawFileDescriptor | undefined = undefined;
  private imageInfo: image.ImageInfo | undefined = undefined;

  aboutToAppear() {
    this.init();
  }

  async init(): Promise<void> {
    // Stage模型
    const context: Context = getContext(this);
    // 获取resourceManager资源管理器
    const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
    let rfd = await resourceMgr.getRawFd('image.jpg');
    this.pixelMap = await ImageEditor.instance.handleImageRawfile(rfd, this.options);
    this.imageInfo = await this.pixelMap!.getImageInfo();
    this.rfd = rfd;
  }

  async update(option: EditOption): Promise<void> {
    if (this.pixelMap != undefined) {
      this.pixelMap.release();
    }
    if (this.rfd == undefined) {
      return;
    }
    this.options = [];
    this.options.push(option);

    this.pixelMap = await ImageEditor.instance.handleImageRawfile(this.rfd!, this.options);
    this.imageInfo = await this.pixelMap!.getImageInfo();
    let outputSize: Size = {
      width: this.context.width,
      height: this.context.height,
    }
    let inputSize: Size = this.imageInfo!.size;
    let fittedSizes = applyBoxFit(BoxFit.contain, inputSize, outputSize)
    let sourceSize = fittedSizes.source;
    let destinationSize = fittedSizes.destination;
    const halfWidthDelta = (outputSize.width - destinationSize.width) / 2.0;
    const halfHeightDelta = (outputSize.height - destinationSize.height) / 2.0;

    const dx = halfWidthDelta;
    const dy = halfHeightDelta;
    this.context.reset();
    this.context.drawImage(this.pixelMap, dx, dy, destinationSize.width, destinationSize.height,);
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Row() {
        Button('Scale', { type: ButtonType.Normal, stateEffect: true }).onClick(() => {
          let width = this.imageInfo!.size.width;
          let height = this.imageInfo!.size.height;
          this.update(new ScaleOption(width / 2, height / 2, true, true));
        })
        Button('Flip', { type: ButtonType.Normal, stateEffect: true }).onClick(() => {

          this.update(new FlipOption(true, true));
        })
        Button('Rotate', { type: ButtonType.Normal, stateEffect: true }).onClick(() => {

          this.update(new RotateOption(65));
        })
        Button('Clip', { type: ButtonType.Normal, stateEffect: true }).onClick(() => {
          let width = this.imageInfo!.size.width;
          let height = this.imageInfo!.size.height;
          this.update(new ClipOption((width - width / 2) / 2, (height - height / 2) / 2, width / 2, height / 2));
        })
        Button('AddText', { type: ButtonType.Normal, stateEffect: true }).onClick(() => {
          let texts: Array<EditorText> = [];
          let width = this.imageInfo!.size.width;
          let height = this.imageInfo!.size.height;
          texts.push(new EditorText("AddText", "", width / 2, height / 2, 54, {
            alpha: 255,
            red: 255,
            green: 0,
            blue: 0,
          }))
          this.update(new AddTextOption(texts));
        }).fontSize(18)
      }


      if (this.rfd != undefined) {
        Canvas(this.context)
          .width('100%')
          .height('100%')// .backgroundColor('#ffff00')
          .onReady(() => {
            if (this.pixelMap != undefined) {

              let outputSize: Size = {
                width: this.context.width,
                height: this.context.height,
              }
              let inputSize: Size = this.imageInfo!.size;
              let fittedSizes = applyBoxFit(BoxFit.contain, inputSize, outputSize)
              let sourceSize = fittedSizes.source;
              let destinationSize = fittedSizes.destination;
              const halfWidthDelta = (outputSize.width - destinationSize.width) / 2.0;
              const halfHeightDelta = (outputSize.height - destinationSize.height) / 2.0;

              const dx = halfWidthDelta;
              const dy = halfHeightDelta;

              this.context.drawImage(this.pixelMap, dx, dy, destinationSize.width, destinationSize.height,);
            }
          })
      }
    }
    .width('100%')
    .height('100%')
  }
}


enum BoxFit {
  fill,
  contain,
  cover,
  fitWidth,
  fitHeight,
  none,
  scaleDown
}

function applyBoxFit(fit: BoxFit, inputSize: Size, outputSize: Size): FittedSizes {
  if (inputSize.height <= 0.0 || inputSize.width <= 0.0 || outputSize.height <= 0.0 || outputSize.width <= 0.0) {
    return new FittedSizes({ width: 0, height: 0 }, { width: 0, height: 0 });
  }

  let sourceSize: Size;
  let destinationSize: Size;

  switch (fit) {
    case BoxFit.fill:
      sourceSize = inputSize;
      destinationSize = outputSize;
      break;
    case BoxFit.contain:
      sourceSize = inputSize;
      if (outputSize.width / outputSize.height > sourceSize.width / sourceSize.height) {
        destinationSize =
          { width: sourceSize.width * outputSize.height / sourceSize.height, height: outputSize.height };
      } else {
        destinationSize = { width: outputSize.width, height: sourceSize.height * outputSize.width / sourceSize.width };
      }
      break;
    case BoxFit.cover:
      if (outputSize.width / outputSize.height > inputSize.width / inputSize.height) {
        sourceSize = { width: inputSize.width, height: inputSize.width * outputSize.height / outputSize.width };
      } else {
        sourceSize = { width: inputSize.height * outputSize.width / outputSize.height, height: inputSize.height };
      }
      destinationSize = outputSize;
      break;
    case BoxFit.fitWidth:
      if (outputSize.width / outputSize.height > inputSize.width / inputSize.height) {
        // Like "cover"
        sourceSize = { width: inputSize.width, height: inputSize.width * outputSize.height / outputSize.width };
        destinationSize = outputSize;
      } else {
        // Like "contain"
        sourceSize = inputSize;
        destinationSize = { width: outputSize.width, height: sourceSize.height * outputSize.width / sourceSize.width };
      }
      break;
    case BoxFit.fitHeight:
      if (outputSize.width / outputSize.height > inputSize.width / inputSize.height) {
        // Like "contain"
        sourceSize = inputSize;
        destinationSize =
          { width: sourceSize.width * outputSize.height / sourceSize.height, height: outputSize.height };
      } else {
        // Like "cover"
        sourceSize = { width: inputSize.height * outputSize.width / outputSize.height, height: inputSize.height };
        destinationSize = outputSize;
      }
      break;
    case BoxFit.none:
      sourceSize =
        { width: Math.min(inputSize.width, outputSize.width), height: Math.min(inputSize.height, outputSize.height) };
      destinationSize = sourceSize;
      break;
    case BoxFit.scaleDown:
      sourceSize = inputSize;
      destinationSize = inputSize;
      const aspectRatio = inputSize.width / inputSize.height;
      if (destinationSize.height > outputSize.height) {
        destinationSize = { width: outputSize.height * aspectRatio, height: outputSize.height };
      }
      if (destinationSize.width > outputSize.width) {
        destinationSize = { width: outputSize.width, height: outputSize.width / aspectRatio };
      }
      break;
  }

  return new FittedSizes(sourceSize, destinationSize);
}


class FittedSizes {
  source: Size;
  destination: Size;

  constructor(source: Size, destination: Size) {
    this.source = source;
    this.destination = destination;
  }
}
