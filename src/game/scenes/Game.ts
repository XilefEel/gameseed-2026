import { Scene } from "phaser";
import { Grid } from "../entities/Grid";
import { PathDrawing } from "../systems/PathDrawing";
import { Vec2 } from "../types";
import { Player } from "../entities/Player";
import { PathFollower } from "../systems/PathFollower";

export class Game extends Scene {
  private grid: Grid;
  private player: Player;
  private pathDrawing: PathDrawing;
  private pathFollower: PathFollower;

  constructor() {
    super("Game");
  }

  create() {
    this.cameras.main.setBackgroundColor("#000000");

    this.grid = new Grid(this);
    this.player = new Player(this, this.grid.start);

    this.pathDrawing = new PathDrawing(this, this.grid);
    this.pathFollower = new PathFollower(this, this.player);

    // listen for events

    this.events.on("path-confirmed", (path: Vec2[]) => {
      if (this.pathFollower.isMoving) return;
      this.pathDrawing.clearPath();
      this.pathFollower.follow(path);
    });

    this.events.on("player-follow-complete", () => {
      console.log("Player has reached the destination!");
    });
  }

  shutdown() {
    this.pathDrawing.destroy();
    this.events.off("pathConfirmed");
    this.events.off("player-follow-complete");
  }
}
