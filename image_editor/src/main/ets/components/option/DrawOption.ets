import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { EditOption } from './Option';
import { common2D, drawing } from '@kit.ArkGraphics2D';
import { Offset } from '@kit.ArkUI';

export class DrawOption implements EditOption {
  static readonly key: string = 'draw';
  draws: Array<DrawPart>;

  constructor(draws: Array<DrawPart>) {
    this.draws = draws;
  }

  static fromMap(data: Map<string, ESObject>): DrawOption {
    let list: Array<Map<string, ESObject>> = MapUtils.get(data, 'parts', []);
    const draws: Array<DrawPart> = [];
    for (let index = 0; index < list.length; index++) {
      const element: Map<string, ESObject> = list[index];
      let key: string = element.get('key');
      let value: Map<string, ESObject> = MapUtils.getMap(element, 'value');
      let drawPart: DrawPart | null = null;
      switch (key) {
        case LineDrawPart.key:
          drawPart = LineDrawPart.fromMap(value);
          break;
        case PointDrawPart.key:
          drawPart = PointDrawPart.fromMap(value);
          break;
        case RectDrawPart.key:
          drawPart = RectDrawPart.fromMap(value);
          break;
        case OvalDrawPart.key:
          drawPart = OvalDrawPart.fromMap(value);
          break;
        case PathDrawPart.key:
          drawPart = PathDrawPart.fromMap(value);
          break;
        default:
          break;
      }
      if (drawPart != null && !drawPart.canIgnore()) {
        draws.push(drawPart);
      }
    }
    return new DrawOption(draws);
  }

  canIgnore(): boolean {
    return this.draws.length === 0;
  }

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    let canvas = new drawing.Canvas(pixelMap);
    for (const element of this.draws) {
      element.handle(canvas);
    }
    return pixelMap;
  }
}

interface DrawPart {
  handle(canvas: drawing.Canvas): void;

  canIgnore(): boolean;
}

export class DrawPaint {
  static readonly key: string = 'paint';
  color: common2D.Color;
  lineWeight: number;
  paintStyleFill: boolean;

  constructor(color: common2D.Color, lineWeight: number, paintStyleFill: boolean) {
    this.color = color;
    this.lineWeight = lineWeight;
    this.paintStyleFill = paintStyleFill;
  }

  static fromMap(data: Map<string, ESObject>): DrawPaint {
    return new DrawPaint(
      MapUtils.getColor(MapUtils.getMap(data, 'color')),
      MapUtils.get(data, 'lineWeight', 2),
      MapUtils.get(data, 'paintStyleFill', true)
    );
  }
}

export class LineDrawPart implements DrawPart {
  static readonly key: string = 'line';
  start: Offset;
  end: Offset;
  paint: DrawPaint;

  constructor(paint: DrawPaint, start: Offset, end: Offset) {
    this.paint = paint;
    this.start = start;
    this.end = end;
  }

  static fromMap(data: Map<string, ESObject>): LineDrawPart {
    const paint = DrawPaint.fromMap(data);
    const start = MapUtils.getOffset(MapUtils.getMap(data, 'start'));
    const end = MapUtils.getOffset(MapUtils.getMap(data, 'end'));
    return new LineDrawPart(paint, start, end);
  }

  canIgnore(): boolean {
    return false;
  }

  handle(canvas: drawing.Canvas): void {
    let pen: drawing.Pen = new drawing.Pen();
    pen.setColor(this.paint.color);
    pen.setStrokeWidth(this.paint.lineWeight);
    canvas.attachPen(pen);
    canvas.drawLine(this.start.x, this.start.y, this.end.x, this.end.y);
    canvas.detachPen();
  }
}

// 类似地为其他类添加 fromMap 方法
export class PointDrawPart implements DrawPart {
  static readonly key: string = 'point';
  offsets: Array<Offset>;
  paint: DrawPaint;

  constructor(paint: DrawPaint, offsets: Array<Offset>) {
    this.paint = paint;
    this.offsets = offsets;
  }

  static fromMap(data: Map<string, ESObject>): PointDrawPart {
    const paint = DrawPaint.fromMap(data);
    const offsets =
      MapUtils.get<Array<ESObject>>(data, 'offset', []).map((element: ESObject) => MapUtils.getOffset(element));
    return new PointDrawPart(paint, offsets);
  }

  canIgnore(): boolean {
    return this.offsets.length === 0;
  }

  handle(canvas: drawing.Canvas): void {
    let pen: drawing.Pen = new drawing.Pen();
    pen.setColor(this.paint.color);
    pen.setStrokeWidth(this.paint.lineWeight);
    canvas.attachPen(pen);
    let path: drawing.Path = new drawing.Path();
    for (const element of this.offsets) {
      if (this.offsets.indexOf(element) === 0) {
        path.moveTo(element.x, element.y);
      } else {
        path.lineTo(element.x, element.y);
      }
    }
    canvas.drawPath(path);
    canvas.detachPen();
  }
}

export class RectDrawPart implements DrawPart {
  static readonly key: string = 'rect';
  rect: common2D.Rect;
  paint: DrawPaint;

  constructor(paint: DrawPaint, rect: common2D.Rect) {
    this.paint = paint;
    this.rect = rect;
  }

  static fromMap(data: Map<string, ESObject>): RectDrawPart {
    const paint = DrawPaint.fromMap(data);
    const rect = MapUtils.getRect(MapUtils.getMap(data, 'rect'));
    return new RectDrawPart(paint, rect);
  }

  canIgnore(): boolean {
    return false;
  }

  handle(canvas: drawing.Canvas): void {
    if (this.paint.paintStyleFill) {
      let brush = new drawing.Brush();
      brush.setColor(this.paint.color);
      canvas.attachBrush(brush);
      this.drawRect(canvas);
      canvas.detachBrush();
    } else {
      let pen: drawing.Pen = new drawing.Pen();
      pen.setColor(this.paint.color);
      pen.setStrokeWidth(this.paint.lineWeight);
      canvas.attachPen(pen);
      this.drawRect(canvas);
      canvas.detachPen();
    }
  }

  drawRect(canvas: drawing.Canvas): void {
    canvas.drawRect(this.rect);
  }
}

export class OvalDrawPart extends RectDrawPart {
  static readonly key: string = 'oval';

  drawRect(canvas: drawing.Canvas): void {
    let path: drawing.Path = new drawing.Path();
    let kappa = .5522848;
    let x = this.rect.left;
    let y = this.rect.top;
    let width = this.rect.right - this.rect.left;
    let height = this.rect.bottom - this.rect.top;
    let ox = (width / 2) * kappa;
    let oy = (height / 2) * kappa;
    let xe = x + width;
    let ye = y + height;
    let xm = x + width / 2;
    let ym = y + height / 2;
    path.moveTo(x, ym);
    path.cubicTo(x, ym - oy, xm - ox, y, xm, y);
    path.cubicTo(xm + ox, y, xe, ym - oy, xe, ym);
    path.cubicTo(xe, ym + oy, xm + ox, ye, xm, ye);
    path.cubicTo(xm - ox, ye, x, ym + oy, x, ym);
    path.close();
    canvas.drawPath(path);
  }
}

export class PathDrawPart implements DrawPart {
  static readonly key: string = 'path';
  parts: Array<PathPart>;
  paint: DrawPaint;
  autoClose: boolean;

  constructor(paint: DrawPaint, parts: Array<PathPart>, autoClose: boolean) {
    this.paint = paint;
    this.parts = parts;
    this.autoClose = autoClose;
  }

  static fromMap(data: Map<string, ESObject>): PathDrawPart {
    const paint = DrawPaint.fromMap(data);
    const parts: Array<PathPart> = [];
    const list: Array<ESObject> = MapUtils.get<Array<ESObject>>(data, 'parts', []);
    for (let index = 0; index < list.length; index++) {
      const element: Map<string, ESObject> = list[index];
      let key: string = element.get('key');
      let value: Map<string, ESObject> = MapUtils.getMap(element, 'value');
      let pathPart: PathPart | null = null;
      switch (key) {
        case MovePathPart.key:
          pathPart = MovePathPart.fromMap(value);
          break;
        case LineToPathPart.key:
          pathPart = LineToPathPart.fromMap(value);
          break;
        case BezierPathPart.key:
          pathPart = BezierPathPart.fromMap(value);
          break;
        case ArcToPathPart.key:
          pathPart = ArcToPathPart.fromMap(value);
          break;
        default:
          break;
      }
      if (pathPart != null && !pathPart.canIgnore()) {
        parts.push(pathPart);
      }
    }
    const autoClose = MapUtils.get(data, 'autoClose', false);
    return new PathDrawPart(paint, parts, autoClose);
  }

  canIgnore(): boolean {
    return this.parts.length === 0;
  }

  handle(canvas: drawing.Canvas): void {
    if (this.paint.paintStyleFill) {
      let brush = new drawing.Brush();
      brush.setColor(this.paint.color);
      canvas.attachBrush(brush);
      this.drawPath(canvas);
      canvas.detachBrush();
    } else {
      let pen: drawing.Pen = new drawing.Pen();
      pen.setColor(this.paint.color);
      pen.setStrokeWidth(this.paint.lineWeight);
      canvas.attachPen(pen);
      this.drawPath(canvas);
      canvas.detachPen();
    }
  }

  drawPath(canvas: drawing.Canvas): void {
    let path: drawing.Path = new drawing.Path();
    for (const element of this.parts) {
      element.handle(path);
    }
    if (this.autoClose) {
      path.close();
    }
    canvas.drawPath(path);
  }
}

abstract class PathPart {
  abstract handle(path: drawing.Path): void;

  canIgnore(): boolean {
    return false;
  }
}

class MovePathPart extends PathPart {
  static readonly key: string = 'move';
  offset: Offset;

  constructor(offset: Offset) {
    super();
    this.offset = offset;
  }

  static fromMap(data: Map<string, ESObject>): MovePathPart {
    const offset = MapUtils.getOffset(MapUtils.getMap(data, 'offset'));
    return new MovePathPart(offset);
  }

  handle(path: drawing.Path): void {
    path.moveTo(this.offset.x, this.offset.y);
  }
}

class LineToPathPart extends MovePathPart {
  static readonly key: string = 'lineTo';

  constructor(offset: Offset) {
    super(offset);
  }

  static fromMap(data: Map<string, ESObject>): LineToPathPart {
    const offset = MapUtils.getOffset(MapUtils.getMap(data, 'offset'));
    return new LineToPathPart(offset);
  }

  handle(path: drawing.Path): void {
    path.lineTo(this.offset.x, this.offset.y);
  }
}

class BezierPathPart extends PathPart {
  static readonly key: string = 'bezier';
  control1: Offset;
  control2: Offset | null;
  target: Offset;

  // kind: number;

  constructor(control1: Offset, control2: Offset | null, target: Offset) {
    super();
    this.control1 = control1;
    this.control2 = control2;
    this.target = target;
    //this.kind = kind;
  }

  static fromMap(data: Map<string, ESObject>): BezierPathPart {
    const control1 = MapUtils.getOffset(MapUtils.getMap(data, 'c1'));
    const control2 = data.get('c2') ? MapUtils.getOffset(MapUtils.getMap(data, 'c2')) : null;
    const target = MapUtils.getOffset(MapUtils.getMap(data, 'target'));
    // const kind = MapUtils.get(data, 'kind', 2);
    return new BezierPathPart(control1, control2, target);
  }

  handle(path: drawing.Path): void {
    if (this.control2 != null) {
      path.cubicTo(this.control1.x, this.control1.y, this.control2.x, this.control2.y, this.target.x, this.target.y);
    } else {
      path.quadTo(this.control1.x, this.control1.y, this.target.x, this.target.y);
    }
  }
}

class ArcToPathPart extends PathPart {
  static readonly key: string = 'arcTo';
  rect: common2D.Rect;
  startAngle: number;
  sweepAngle: number;
  useCenter: boolean;

  constructor(rect: common2D.Rect, startAngle: number, sweepAngle: number, useCenter: boolean) {
    super();
    this.rect = rect;
    this.startAngle = startAngle;
    this.sweepAngle = sweepAngle;
    this.useCenter = useCenter;
  }

  static fromMap(data: Map<string, ESObject>): ArcToPathPart {
    const rect = MapUtils.getRect(MapUtils.getMap(data, 'rect'));
    const startAngle = MapUtils.get(data, 'start', 0);
    const sweepAngle = MapUtils.get(data, 'sweep', 0);
    const useCenter = MapUtils.get(data, 'useCenter', false);
    return new ArcToPathPart(rect, startAngle, sweepAngle, useCenter);
  }

  handle(path: drawing.Path): void {
    path.arcTo(this.rect.left, this.rect.top, this.rect.right, this.rect.bottom, this.startAngle, this.sweepAngle);
  }
}
