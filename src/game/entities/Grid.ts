import { Math, Scene } from "phaser";
import { GRID_CONFIG } from "../config/grid";
import { pixelToGrid } from "../utils/grid";
import { GridCell } from "./GridCell";

export class Grid {
  private cells: GridCell[][] = [];
  private scene: Scene;

  start: Math.Vector2 = new Math.Vector2(0, 0);
  end: Math.Vector2 = new Math.Vector2(7, 7);

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

  isStartCell(cell: GridCell): boolean {
    return cell.isStart;
  }

  isEndCell(cell: GridCell): boolean {
    return cell.isEnd;
  }

  resetPath() {
    for (const row of this.cells) {
      for (const cell of row) {
        cell.reset();
      }
    }
  }
}
