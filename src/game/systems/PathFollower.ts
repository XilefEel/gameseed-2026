import { Scene } from "phaser";
import { Player } from "../entities/Player";
import { Vec2 } from "../types";

export class PathFollower {
  private player: Player;
  private scene: Scene;
  private speed: number = 200;

  isMoving: boolean = false;

  constructor(scene: Scene, player: Player) {
    this.scene = scene;
    this.player = player;
  }

  async follow(path: Vec2[]) {
    if (this.isMoving) return;
    this.isMoving = true;

    for (const point of path) {
      await this.player.moveToCell(point, this.speed);
    }

    this.isMoving = false;
    this.scene.events.emit("player-follow-complete");
  }
}
