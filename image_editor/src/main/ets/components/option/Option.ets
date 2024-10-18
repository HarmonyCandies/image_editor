import image from '@ohos.multimedia.image';

export interface EditOption {
  canIgnore(): boolean;

  handle(pixelMap: image.PixelMap): Promise<image.PixelMap>
}