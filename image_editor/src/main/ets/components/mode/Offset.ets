import { MapUtils } from '../util/MapUtils';

export class Offset {
  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }

  //
  // constructor(data: Map<string, ESObject>) {
  //   this.x = MapUtils.get(data, 'x', 0);
  //   this.y = MapUtils.get(data, 'y', 0);
  // }

  x: number;
  y: number;
}
