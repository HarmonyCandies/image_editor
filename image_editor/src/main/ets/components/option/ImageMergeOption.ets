import image from '@ohos.multimedia.image';
import { Offset } from '../mode/Offset';
import { MapUtils } from '../util/MapUtils';
import { drawing } from '@kit.ArkGraphics2D';

export class ImageMergeOption {
  image: Uint8Array;
  offset: Offset;
  width: number;
  height: number;

  constructor(image: Uint8Array, offset: Offset, width: number, height: number) {
    this.image = image;
    this.offset = offset;
    this.width = width;
    this.height = height;
  }

  static fromMap(data: Map<string, ESObject>): ImageMergeOption {
    const image = MapUtils.get(MapUtils.getMap(data, 'src'), 'memory', new Uint8Array());
    const position: Map<string, ESObject> = MapUtils.getMap(data, 'position');
    const offset = MapUtils.getOffset(position);
    const width = MapUtils.get(position, 'w', 0);
    const height = MapUtils.get(position, 'h', 0);
    return new ImageMergeOption(image, offset, width, height);
  }

  async handle(context: OffscreenCanvasRenderingContext2D): Promise<void> {
    const imageSource: image.ImageSource = image.createImageSource(this.image.buffer);
    let decodingOptions: image.DecodingOptions = {
      sampleSize: 1,
    };
    let pixelMap: image.PixelMap = await imageSource.createPixelMap(decodingOptions);
    context.drawImage(pixelMap, this.offset.x, this.offset.y, this.width, this.height);
  }
}
