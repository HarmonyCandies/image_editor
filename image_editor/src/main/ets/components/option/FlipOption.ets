import { EditOption } from './Option';
import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';

export class FlipOption implements EditOption {
  static readonly key: string = 'flip';

  horizontal: boolean;
  vertical: boolean;

  constructor(horizontal: boolean, vertical: boolean) {
    this.horizontal = horizontal;
    this.vertical = vertical;
  }

  static fromMap(data: Map<string, ESObject>): FlipOption {
    const horizontal = MapUtils.get(data, 'h', false);
    const vertical = MapUtils.get(data, 'v', false);
    return new FlipOption(horizontal, vertical);
  }

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    await pixelMap.flip(this.horizontal, this.vertical);
    return pixelMap;
  }

  canIgnore(): boolean {
    return !this.horizontal && !this.vertical;
  }
}
