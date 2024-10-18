import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { EditOption } from './Option';

export class ClipOption implements EditOption {
  static readonly key: string = 'clip';

  x: number;
  y: number;
  width: number;
  height: number;

  constructor(x: number, y: number, width: number, height: number) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }

  static fromMap(data: Map<string, ESObject>): ClipOption {
    const x = MapUtils.get(data, 'x', 0);
    const y = MapUtils.get(data, 'y', 0);
    const width = MapUtils.get(data, 'width', 0);
    const height = MapUtils.get(data, 'height', 0);
    return new ClipOption(x, y, width, height);
  }

  canIgnore(): boolean {
    return this.width <= 0 || this.height <= 0;
  }

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    await pixelMap.crop({
      size: {
        width: this.width,
        height: this.height,
      },
      x: this.x,
      y: this.y,
    });
    return pixelMap;
  }
}
