import { Input, Math, Scene } from "phaser";
import { Grid } from "../entities/Grid";
import { isAdjacent } from "../utils/grid";

export class PathDrawing {
  private path: Math.Vector2[] = [];
  private isDrawing: boolean = false;
  private scene: Scene;
  private grid: Grid;

  constructor(scene: Scene, grid: Grid) {
    this.scene = scene;
    this.grid = grid;

    this.scene.input.on("pointerdown", this.startDrawing, this);
    this.scene.input.on("pointermove", this.updatePath, this);
    this.scene.input.on("pointerup", this.stopDrawing, this);
  }

  private startDrawing(pointer: Input.Pointer) {
    const cell = this.grid.getCellAtPointer(pointer.x, pointer.y);
    if (!cell || !this.grid.isStartCell(cell)) return;

    this.isDrawing = true;
    this.path = [new Math.Vector2(cell.gridX, cell.gridY)];
    cell.setAsPath();
  }

  private updatePath(pointer: Input.Pointer) {
    if (!this.isDrawing) return;

    const cell = this.grid.getCellAtPointer(pointer.x, pointer.y);
    if (!cell || this.grid.isStartCell(cell)) return;

    const last = this.path[this.path.length - 1];
    const secondLast = this.path[this.path.length - 2];

    if (cell.gridX === last.x && cell.gridY === last.y) return;

    if (
      secondLast &&
      cell.gridX === secondLast.x &&
      cell.gridY === secondLast.y
    ) {
      const removed = this.path.pop()!;
      this.grid.getCell(removed.x, removed.y)?.reset();
      return;
    }

    if (
      isAdjacent(last.x, last.y, cell.gridX, cell.gridY) &&
      !this.isInPath(cell.gridX, cell.gridY)
    ) {
      this.path.push(new Math.Vector2(cell.gridX, cell.gridY));
      cell.setAsPath();
    }
  }

  private stopDrawing() {
    this.isDrawing = false;
  }

  private isInPath(gridX: number, gridY: number): boolean {
    return this.path.some((v) => v.x === gridX && v.y === gridY);
  }

  clearPath() {
    this.path.forEach((p) => this.grid.getCell(p.x, p.y)?.reset());
    this.path = [];
  }

  destroy() {
    this.scene.input.off("pointerdown", this.startDrawing, this);
    this.scene.input.off("pointermove", this.updatePath, this);
    this.scene.input.off("pointerup", this.stopDrawing, this);
  }
}
