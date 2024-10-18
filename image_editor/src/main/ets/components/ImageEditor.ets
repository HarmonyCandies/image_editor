import { ImageMergeOption } from "./option/ImageMergeOption";
import { image } from "@kit.ImageKit";
import { ImageUtils } from "./util/ImageUtils";
import { EditOption } from "./option/Option";
import resourceManager from "@ohos.resourceManager";


export class ImageEditor {
  private constructor() {
  }

  private static _instance: ImageEditor = new ImageEditor();
  public static instance: ImageEditor = ImageEditor._instance;

  async handleImageRawfile(rawfile: resourceManager.RawFileDescriptor,
    options: Array<EditOption>): Promise<PixelMap> {
    const imageSource: image.ImageSource = image.createImageSource(rawfile);
    return this.handleImageWithOptions(imageSource, options);
  }

  async handleImageUri(uri: string,
    options: Array<EditOption>): Promise<PixelMap> {
    const imageSource: image.ImageSource = image.createImageSource(uri);
    return this.handleImageWithOptions(imageSource, options);
  }

  async handleImageFileDescriptor(fd: number,
    options: Array<EditOption>): Promise<PixelMap> {

    const imageSource: image.ImageSource = image.createImageSource(fd);
    return this.handleImageWithOptions(imageSource, options);
  }

  async handleImageBuffer(buffer: ArrayBuffer,
    options: Array<EditOption>): Promise<PixelMap> {

    const imageSource: image.ImageSource = image.createImageSource(buffer);
    return this.handleImageWithOptions(imageSource, options);
  }

  async handleImageSource(imageSource: image.ImageSource, packOptions: image.PackingOption,
    options: Array<EditOption>): Promise<Uint8Array> {


    let pixelMap: PixelMap = await this.handleImageWithOptions(imageSource, options);

    const imagePackerApi = image.createImagePacker();

    // PixelMap编码成不同格式的存档图片
    // let format: string = 'image/jpeg';
    // switch (fmt.format) {
    //   case 0:
    //     format = 'image/png'
    //     break;
    //   default:
    //     break;
    // }
    //
    // const packOptions: image.PackingOption = {
    //   format: format,
    //   quality: fmt.quality,
    // }

    let uint8Array: Uint8Array = new Uint8Array(await imagePackerApi.packing(pixelMap, packOptions));
    pixelMap.release();
    imageSource.release();
    return uint8Array;
  }


  async handleImageWithOptions(imageSource: image.ImageSource,
    options: Array<EditOption>): Promise<PixelMap> {

    let decodingOptions: image.DecodingOptions = {
      sampleSize: 1,
      editable: true,
    };

    let pixelMap: PixelMap = await imageSource.createPixelMap(decodingOptions);
    let exifRotate: number = 0;
    try {
      let imageProperty = await imageSource.getImageProperty(image.PropertyKey.ORIENTATION);
      exifRotate = ImageUtils.parseExifRotate(imageProperty);
      await pixelMap.rotate(exifRotate % 360);
    } catch (e) {
    }

    // const brush = new drawing.Brush();
    // let colorFilter = drawing.ColorFilter.createLinearToSRGBGamma();
    // brush.setColorFilter(colorFilter);


    // let reverseWH: boolean = false;
    // if (exifRotate == 270 || exifRotate == 90) {
    //   reverseWH = true;
    // }

    for (let index = 0; index < options.length; index++) {
      const option: EditOption = options[index];
      if (option != null && !option.canIgnore()) {
        pixelMap = await option.handle(pixelMap);
      }
    }
    return pixelMap;
  }


  async mergeImage(packOptions: image.PackingOption, width: number, height: number,
    images: Array<ImageMergeOption>,): Promise<Uint8Array> {

    const context = new OffscreenCanvasRenderingContext2D(width, height, {
      antialias: true,
    });

    // 'src': image.toJson(), => 'memory'
    // 'position': position.toJson(),

    for (let index = 0; index < images.length; index++) {
      const imageMergeOption: ImageMergeOption = images[index];
      await imageMergeOption.handle(context);
    }

    const imagePackerApi = image.createImagePacker();

    // PixelMap编码成不同格式的存档图片
    // let format: string = 'image/jpeg';
    // switch (fmt.format) {
    //   case 0:
    //     format = 'image/png'
    //     break;
    //   default:
    //     break;
    // }
    //
    // const packOptions: image.PackingOption = {
    //   format: format,
    //   quality: fmt.quality,
    // }
    let pixelMap = context.getPixelMap(0, 0, width, height);

    let scale = px2vp(1);
    await pixelMap.scale(scale, scale);
    let uint8Array: Uint8Array = new Uint8Array(await imagePackerApi.packing(pixelMap, packOptions));
    pixelMap.release();
    return uint8Array;
  }
}