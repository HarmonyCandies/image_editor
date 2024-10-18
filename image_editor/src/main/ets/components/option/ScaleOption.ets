import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { EditOption } from './Option';

export class ScaleOption implements EditOption {
  static readonly key: string = 'scale';

  constructor(width: number, height: number, keepRatio: boolean, keepWidthFirst: boolean) {
    this.width = width;
    this.height = height;
    this.keepRatio = keepRatio;
    this.keepWidthFirst = keepWidthFirst;
  }

  width: number;
  height: number;
  keepRatio: boolean;
  keepWidthFirst: boolean;

  canIgnore(): boolean {
    return false;
  }

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    let w = this.width;
    let h = this.height;
    let imageInfo = await pixelMap.getImageInfo();
    if (this.keepRatio) {
      let srcRatio = imageInfo.size.width / imageInfo.size.height;
      if (this.keepWidthFirst) {
        h = w / srcRatio;
      } else {
        w = srcRatio * h;
      }
    }

    let width: number = imageInfo.size.width;
    let height: number = imageInfo.size.height;
    if (width !== w || height !== h) {
      let sx: number = w / width;
      let sy: number = h / height;
      await pixelMap.scale(sx, sy);
    }

    return pixelMap;
  }

  static fromMap(data: Map<string, ESObject>): ScaleOption {
    const width = MapUtils.get(data, 'width', 0);
    const height = MapUtils.get(data, 'height', 0);
    const keepRatio = MapUtils.get(data, 'keepRatio', false);
    const keepWidthFirst = MapUtils.get(data, 'keepWidthFirst', true);
    return new ScaleOption(width, height, keepRatio, keepWidthFirst);
  }
}
