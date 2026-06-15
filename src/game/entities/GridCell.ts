import { GRID_CONFIG } from "../config/grid";
import { Vec2 } from "../types";
import { gridToPixel } from "../utils/grid";
import { GameObjects, Scene } from "phaser";

const { cellSize, colors } = GRID_CONFIG;

export class GridCell extends GameObjects.Rectangle {
  pos: Vec2;
  isStart: boolean = false;
  isEnd: boolean = false;
  isPath: boolean = false;

  constructor(scene: Scene, gridX: number, gridY: number) {
    const { pixelX, pixelY } = gridToPixel(gridX, gridY);

    super(scene, pixelX, pixelY, cellSize - 3, cellSize - 3, colors.cell);

    this.pos = {
      x: gridX,
      y: gridY,
    };

    scene.add.existing(this);

    this.setInteractive();
    this.setStrokeStyle(1, colors.cellBorder);

    this.on("pointerover", () => {
      if (!this.isStart && !this.isEnd && !this.isPath) {
        this.setFillStyle(colors.hover);
      }
    });

    this.on("pointerout", () => {
      if (!this.isStart && !this.isEnd && !this.isPath) {
        this.setFillStyle(colors.cell);
      }
    });
  }

  setAsStart() {
    this.isStart = true;
    this.setFillStyle(colors.start);
  }

  setAsEnd() {
    this.isEnd = true;
    this.setFillStyle(colors.end);
  }

  setAsPath() {
    this.isPath = true;
    console.log(`Path cell at (${this.pos.x}, ${this.pos.y})`);

    if (!this.isStart && !this.isEnd) {
      this.setFillStyle(colors.path);
    }
  }

  reset() {
    this.isStart = false;
    this.isEnd = false;
    this.isPath = false;
    this.setFillStyle(colors.cell);
  }
}
