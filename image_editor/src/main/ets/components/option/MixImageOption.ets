import { drawing } from '@kit.ArkGraphics2D';
import { EditOption } from './Option';
import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { ScaleOption } from './ScaleOption';
import { ImageUtils } from '../util/ImageUtils';

export class MixImageOption implements EditOption {
  static readonly key: string = 'mix_image';
  private static blendModeMap: Map<string, drawing.BlendMode> = new Map([
    ['clear', drawing.BlendMode.CLEAR],
    ['src', drawing.BlendMode.SRC],
    ['dst', drawing.BlendMode.DST],
    ['srcOver', drawing.BlendMode.SRC_OVER],
    ['dstOver', drawing.BlendMode.DST_OVER],
    ['srcIn', drawing.BlendMode.SRC_IN],
    ['dstIn', drawing.BlendMode.DST_IN],
    ['srcOut', drawing.BlendMode.SRC_OUT],
    ['dstOut', drawing.BlendMode.DST_OUT],
    ['srcATop', drawing.BlendMode.SRC_ATOP],
    ['dstATop', drawing.BlendMode.DST_ATOP],
    ['xor', drawing.BlendMode.XOR],
    ['darken', drawing.BlendMode.DARKEN],
    ['lighten', drawing.BlendMode.LIGHTEN],
    ['multiply', drawing.BlendMode.MULTIPLY],
    ['screen', drawing.BlendMode.SCREEN],
    ['overlay', drawing.BlendMode.OVERLAY],
  ]);

  constructor(
    target: Uint8Array,
    x: number,
    y: number,
    width: number,
    height: number,
    blendModeStr: drawing.BlendMode | undefined,
  ) {
    this.target = target;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.blendMode = blendModeStr;
  }

  static fromMap(data: Map<string, ESObject>): MixImageOption {
    const target = MapUtils.get(MapUtils.getMap(data, 'target'), 'memory', new Uint8Array());
    const x = MapUtils.get(data, 'x', 0);
    const y = MapUtils.get(data, 'y', 0);
    const width = MapUtils.get(data, 'w', 0);
    const height = MapUtils.get(data, 'h', 0);
    const blendModeStr = MapUtils.get(data, 'mixMode', '');
    return new MixImageOption(target, x, y, width, height, MixImageOption.blendModeMap.get(blendModeStr));
  }

  target: Uint8Array;
  x: number;
  y: number;
  width: number;
  height: number;
  blendMode: drawing.BlendMode | undefined;

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    let canvas = new drawing.Canvas(pixelMap);
    let brush = new drawing.Brush();

    if (this.blendMode !== undefined) {
      brush.setBlendMode(this.blendMode);
    }
    canvas.attachBrush(brush);

    const imageSource: image.ImageSource = image.createImageSource(this.target.buffer);
    let decodingOptions: image.DecodingOptions = {
      sampleSize: 1,
      editable: true,
    };
    let targetPixelMap: image.PixelMap = await imageSource.createPixelMap(decodingOptions);
    let exifRotate: number = 0;

    try {
      let imageProperty = await imageSource.getImageProperty(image.PropertyKey.ORIENTATION);
      exifRotate = ImageUtils.parseExifRotate(imageProperty);
      await pixelMap.rotate(exifRotate % 360);
    } catch (e) {
      // Handle error if needed
    }

    let scaleOption: ScaleOption = new ScaleOption(this.width, this.height, false, true);
    await scaleOption.handle(targetPixelMap);
    canvas.drawImage(targetPixelMap, this.x, this.y);
    canvas.detachBrush();

    return pixelMap;
  }

  canIgnore(): boolean {
    return false;
  }
}
