import { Scene } from "phaser";
import { GRID_CONFIG } from "../config/grid";
import { pixelToGrid } from "../utils/grid";
import { GridCell } from "./GridCell";
import { Vec2 } from "../types";

export class Grid {
  private cells: GridCell[][] = [];
  private scene: Scene;

  start: Vec2 = { x: 0, y: 0 };
  end: Vec2 = { x: GRID_CONFIG.columns - 1, y: GRID_CONFIG.rows - 1 };

  constructor(scene: Scene) {
    this.scene = scene;
    this.build();
  }

  private build() {
    const { rows, columns } = GRID_CONFIG;

    for (let y = 0; y < rows; y++) {
      const row: GridCell[] = [];

      for (let x = 0; x < columns; x++) {
        const cell = new GridCell(this.scene, x, y);
        row.push(cell);
      }

      this.cells.push(row);
    }

    this.getCell(this.start.x, this.start.y)?.setAsStart();
    this.getCell(this.end.x, this.end.y)?.setAsEnd();
  }

  getCell(gridX: number, gridY: number): GridCell | null {
    const { rows, columns } = GRID_CONFIG;
    if (gridX < 0 || gridX >= columns || gridY < 0 || gridY >= rows) {
      return null;
    }

    return this.cells[gridY][gridX];
  }

  getCellAtPointer(pointerX: number, pointerY: number): GridCell | null {
    const { rows, columns } = GRID_CONFIG;
    const { gridX, gridY } = pixelToGrid(pointerX, pointerY);

    if (gridX < 0 || gridY < 0 || gridX >= columns || gridY >= rows) {
      return null;
    }

    return this.cells[gridY][gridX];
  }

  isStartCell(cell: Vec2): boolean {
    return cell.x === this.start.x && cell.y === this.start.y;
  }

  isEndCell(cell: Vec2): boolean {
    return cell.x === this.end.x && cell.y === this.end.y;
  }

  resetPath() {
    for (const row of this.cells) {
      for (const cell of row) {
        cell.reset();
      }
    }
  }
}
