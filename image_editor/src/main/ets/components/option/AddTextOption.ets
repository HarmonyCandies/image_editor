import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { EditOption } from './Option';
import { common2D, drawing } from '@kit.ArkGraphics2D';

export class AddTextOption implements EditOption {
  static readonly key: string = 'add_text';
  texts: Array<EditorText>;

  constructor(texts: Array<EditorText>) {
    this.texts = texts;
  }

  static fromMap(data: Map<string, ESObject>): AddTextOption {
    const list: Array<Map<string, ESObject>> = MapUtils.get(data, 'texts', []);
    const texts = list.map(EditorText.fromMap);
    return new AddTextOption(texts);
  }

  canIgnore(): boolean {
    return this.texts.length === 0;
  }

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    try {
      let canvas = new drawing.Canvas(pixelMap);
      for (const element of this.texts) {
        await element.handle(canvas);
      }
    } catch (e) {
      console.log(e);
    }
    return pixelMap;
  }
}

export class EditorText {
  text: string;
  fontName: string;
  x: number;
  y: number;
  size: number;
  color: common2D.Color;
  fontFilePath: string;

  constructor(text: string, fontName: string, x: number, y: number, size: number, color: common2D.Color,
    fontFilePath: string) {
    this.text = text;
    this.fontName = fontName;
    this.x = x;
    this.y = y;
    this.size = size;
    this.color = color;
    this.fontFilePath = fontFilePath;
  }

  static fromMap(data: Map<string, ESObject>): EditorText {
    return new EditorText(
      MapUtils.get(data, 'text', ''),
      MapUtils.get(data, 'fontName', ''),
      MapUtils.get(data, 'x', 0),
      MapUtils.get(data, 'y', 0),
      MapUtils.get(data, 'size', 0),
      MapUtils.getColor(data),
      MapUtils.get(data, 'fontFilePath', ''),
    );
  }

  canIgnore(): boolean {
    return this.text === '' || this.size === 0;
  }

  async handle(canvas: drawing.Canvas) {
    if (this.canIgnore()) {
      return;
    }

    const brush = new drawing.Brush();
    brush.setColor(this.color);
    const font = new drawing.Font();
    font.setSize(this.size);
    // TODO, 没有 api 设置自定义
    let typeface = new drawing.Typeface();
    if (this.fontFilePath != undefined) {
      typeface = drawing.Typeface.makeFromFile(this.fontFilePath);
    }
    // let familyName = typeface.getFamilyName();
    font.setTypeface(typeface);
    const textBlob = drawing.TextBlob.makeFromString(this.text, font, drawing.TextEncoding.TEXT_ENCODING_UTF8);
    let bounds = textBlob.bounds();
    canvas.attachBrush(brush);
    canvas.drawTextBlob(textBlob, this.x - bounds.left, this.y - bounds.top);
    canvas.detachBrush();
  }
}
