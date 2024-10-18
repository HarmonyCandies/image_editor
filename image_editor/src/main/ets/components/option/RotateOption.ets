import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { EditOption } from './Option';

export class RotateOption implements EditOption {
  static readonly key: string = 'rotate';

  constructor(degree: number) {
    this.degree = degree % 360;
  }

  degree: number;

  canIgnore(): boolean {
    return this.degree === 0;
  }

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    await pixelMap.rotate(this.degree);
    return pixelMap;
  }

  static fromMap(data: Map<string, ESObject>): RotateOption {
    const degree = MapUtils.get(data, 'degree', 0);
    return new RotateOption(degree);
  }
}
