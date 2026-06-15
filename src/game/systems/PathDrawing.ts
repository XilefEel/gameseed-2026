import { Input, Scene } from "phaser";
import { Grid } from "../entities/Grid";
import { isAdjacent } from "../utils/grid";
import { Vec2 } from "../types";

export class PathDrawing {
  private path: Vec2[] = [];
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

    if (!cell || !this.grid.isStartCell(cell.pos)) return;

    this.isDrawing = true;
    this.path = [cell.pos];
    cell.setAsPath();
  }

  private updatePath(pointer: Input.Pointer) {
    if (!this.isDrawing) return;

    const cell = this.grid.getCellAtPointer(pointer.x, pointer.y);
    if (!cell || this.grid.isStartCell(cell.pos)) return;

    const last = this.path[this.path.length - 1];
    const secondLast = this.path[this.path.length - 2];

    if (cell.pos.x === last.x && cell.pos.y === last.y) return;

    if (
      secondLast &&
      cell.pos.x === secondLast.x &&
      cell.pos.y === secondLast.y
    ) {
      const removed = this.path.pop()!;
      this.grid.getCell(removed.x, removed.y)?.reset();
      return;
    }

    if (isAdjacent(last, cell.pos) && !this.isInPath(cell.pos)) {
      this.path.push(cell.pos);
      cell.setAsPath();
    }
  }

  private stopDrawing() {
    this.isDrawing = false;

    const last = this.path[this.path.length - 1];

    if (this.grid.isEndCell(last)) {
      // emit the path data to Game scene
      this.scene.events.emit("path-confirmed", [...this.path]);
    } else {
      this.clearPath();
    }
  }

  private isInPath(pos: Vec2): boolean {
    return this.path.some((v) => v.x === pos.x && v.y === pos.y);
  }

  clearPath() {
    this.path.forEach((p) => {
      if (!this.grid.isStartCell(p) && !this.grid.isEndCell(p)) {
        this.grid.getCell(p.x, p.y)?.reset();
      }
    });
    this.path = [];
  }

  destroy() {
    this.scene.input.off("pointerdown", this.startDrawing, this);
    this.scene.input.off("pointermove", this.updatePath, this);
    this.scene.input.off("pointerup", this.stopDrawing, this);
  }
}
