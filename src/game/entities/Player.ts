import { GRID_CONFIG } from "../config/grid";
import { Vec2 } from "../types";
import { gridToPixel } from "../utils/grid";
import { GameObjects, Scene } from "phaser";

export class Player extends GameObjects.Container {
  private sprite: GameObjects.Rectangle;
  pos: Vec2;

  constructor(scene: Scene, pos: Vec2) {
    const { pixelX, pixelY } = gridToPixel(pos.x, pos.y);

    super(scene, pixelX, pixelY);

    this.sprite = scene.add.rectangle(0, 0, 40, 40, GRID_CONFIG.colors.player);
    this.add(this.sprite);

    this.pos = pos;

    scene.add.existing(this);
  }

  moveToCell(pos: Vec2, duration: number): Promise<void> {
    this.pos = pos;

    const { pixelX, pixelY } = gridToPixel(pos.x, pos.y);

    return new Promise((resolve) => {
      this.scene.tweens.add({
        targets: this,
        x: pixelX,
        y: pixelY,
        duration: duration,
        ease: "Sine.easeInOut",
        onComplete: () => resolve(),
      });
    });
  }
}
