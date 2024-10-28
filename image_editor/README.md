# image_editor

Arkts plugin, Support crop, flip, rotate, color martix, mix image, add text. merge multi images.

Arkts 插件，支持裁剪、翻转、旋转、颜色矩阵、混合图像、添加文本和合并多张图片。

The tool api for  https://github.com/HarmonyCandies/image_cropper

## 安装

`ohpm install @candies/image_editor`

## Support

| Feature           | Support |
| :---------------- | :-----: |
| flip              |    ✅    |
| crop              |    ✅    |
| rotate            |    ✅    |
| scale             |    ✅    |
| mix image         |    ✅    |
| merge multi image |    ✅    |
| add text          |    ✅    |
| draw point        |    ✅    |
| draw line         |    ✅    |
| draw rect         |    ✅    |
| draw circle       |    ✅    |
| draw path         |    ✅    |
| draw Bezier       |    ✅    |

## Usage

### flip

```typescript
FlipOption(horizontal: boolean, vertical: boolean)
```

```typescript
let pixelMap = await ImageEditor.instance.handleImageRawfile(this.rfd!, [new FlipOption(true, true)]);
```

### crop

```typescript
let pixelMap = await ImageEditor.instance.handleImageRawfile(this.rfd!, [new ClipOption(0, 0, 100, 100)]);
```

 ### rotate

```typescript
let pixelMap = await ImageEditor.instance.handleImageRawfile(this.rfd!, [new RotateOption(65)]);
```

### scale
```typescript
ScaleOption(width: number, height: number, keepRatio: boolean, keepWidthFirst: boolean)
```

```typescript
let pixelMap = await ImageEditor.instance.handleImageRawfile(this.rfd!, [new ScaleOption(100, 100, false, true)]);
```

### mix image

```typescript
MixImageOption(
    target: Uint8Array,
    x: number,
    y: number,
    width: number,
    height: number,
    blendModeStr: drawing.BlendMode | undefined,
) 
```

```typescript
let pixelMap = await ImageEditor.instance.handleImageRawfile(this.rfd!, [new MixImageOption(otherImage,0,0,100,100,BlendMode.SoftLight)]);
```


### add text

```typescript
EditorText(text: string, x: number, y: number, size: number, color: common2D.Color,
    fontFilePath: string | null = null, fontName: string | null = null,)
```

```typescript
let texts: Array<EditorText> = [];
texts.push(new EditorText("AddText", 0, 0, vp2px(18), {
  alpha: 255,
  red: 255,
  green: 0,
  blue: 0,
}))
let pixelMap = await ImageEditor.instance.handleImageRawfile(this.rfd!, [new AddTextOption(texts)]);
```

### merge multi image
```typescript
ImageMergeOption(image: PixelMap, offset: Offset, width: number, height: number)
```

```typescript
let images: Array<ImageMergeOption> = [];
images.push(new ImageMergeOption(image, {x: 0, y: 0}, 50, 50));
images.push(new ImageMergeOption(image1, { x: 25, y: 25}, 20, 20));
let pixelMap = await ImageEditor.instance.mergeImage(this.rfd!, [new mergeImage(100,100,images)]);
```

### draw 

```typescript
DrawPaint(color: common2D.Color, lineWeight: number, paintStyleFill: boolean)
```

 
```typescript

let draws: Array<DrawPart> = [];

// LineDrawPart(paint: DrawPaint, start: Offset, end: Offset)
draws.push(new LineDrawPart(new DrawPaint({
  alpha: 255,
  red: 255,
  green: 0,
  blue: 0,
}, 1 , false),{ x: 25, y: 25},{ x: 25, y: 25},));

// PointDrawPart(paint: DrawPaint, offsets: Array<Offset>)
draws.push(new PointDrawPart(new DrawPaint({
  alpha: 255,
  red: 255,
  green: 0,
  blue: 0,
}, 1 , false),[{ x: 25, y: 25},{ x: 25, y: 25}]));

// RectDrawPart(paint: DrawPaint, rect: common2D.Rect)
draws.push(new RectDrawPart(new DrawPaint({
  alpha: 255,
  red: 255,
  green: 0,
  blue: 0,
}, 1 , false),{
  left: 25,
  top: 25,
  right: 50,
  bottom: 50,
}));

// OvalDrawPart(paint: DrawPaint, rect: common2D.Rect)
draws.push(new OvalDrawPart(new DrawPaint({
  alpha: 255,
  red: 255,
  green: 0,
  blue: 0,
}, 1 , false),{
  left: 25,
  top: 25,
  right: 50,
  bottom: 50,
}));

// PathDrawPart(paint: DrawPaint, parts: Array<PathPart>, autoClose: boolean)

let pathParts: Array<PathPart> = [];
// MovePathPart(offset: Offset)
pathParts.push(new MovePathPart( { x: 25, y: 25}));
// LineToPathPart(offset: Offset)
pathParts.push(new LineToPathPart( { x: 25, y: 25}));
// BezierPathPart(control1: Offset, control2: Offset | null, target: Offset)
pathParts.push(new BezierPathPart( { x: 25, y: 25},{x: 50, y: 10},{x: 27, y: 5}));
// ArcToPathPart(rect: common2D.Rect, startAngle: number, sweepAngle: number, useCenter: boolean)
pathParts.push(new BezierPathPart( {
  left: 25,
  top: 25,
  right: 50,
  bottom: 50,
},0,90,true));


draws.push(new OvalDrawPart(new DrawPaint({
  alpha: 255,
  red: 255,
  green: 0,
  blue: 0,
}, 1 , false),pathParts,true));

let pixelMap = await ImageEditor.instance.handleImageRawfile(this.rfd!, [new DrawOption(draws)]);

```
