import { Scene } from "phaser";
import { Grid } from "../entities/Grid";

export class Game extends Scene {
  private grid: Grid;

  constructor() {
    super("Game");
  }

  create() {
    this.cameras.main.setBackgroundColor("#000000");

    this.grid = new Grid(this);
  }
}
