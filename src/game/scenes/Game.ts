import { Scene } from "phaser";
import { Grid } from "../entities/Grid";
import { PathDrawing } from "../systems/PathDrawing";
import { Vec2 } from "../types";

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

    // listen for events
    this.events.on("pathConfirmed", (path: Vec2[]) => {
      console.log("Received path confirmation event with path:", path);
      console.log("path confirmed, move player");
    });
  }

  shutdown() {
    this.pathDrawing.destroy();
  }
}
