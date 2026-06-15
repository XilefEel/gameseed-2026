import { Scene } from "phaser";
import { Grid } from "../entities/Grid";
import { PathDrawing } from "../systems/PathDrawing";

export class Game extends Scene {
  private grid: Grid;
  private pathDrawing: PathDrawing;

  constructor() {
    super("Game");
  }

  create() {
    this.cameras.main.setBackgroundColor("#000000");

    this.grid = new Grid(this);
    this.pathDrawing = new PathDrawing(this, this.grid);
  }

  shutdown() {
    this.pathDrawing.destroy();
  }
}
