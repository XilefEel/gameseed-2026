import { GRID_CONFIG } from "../config/grid";
import { Vec2 } from "../types";

export const gridToPixel = (
  gridX: number,
  gridY: number,
): {
  pixelX: number;
  pixelY: number;
} => {
  const { cellSize, offsetX, offsetY } = GRID_CONFIG;

  return {
    pixelX: offsetX + gridX * cellSize + cellSize / 2,
    pixelY: offsetY + gridY * cellSize + cellSize / 2,
  };
};

export const pixelToGrid = (
  pixelX: number,
  pixelY: number,
): {
  gridX: number;
  gridY: number;
} => {
  const { cellSize, offsetX, offsetY } = GRID_CONFIG;

  return {
    gridX: Math.floor((pixelX - offsetX) / cellSize),
    gridY: Math.floor((pixelY - offsetY) / cellSize),
  };
};

export const isAdjacent = (a: Vec2, b: Vec2): boolean => {
  const dx = Math.abs(a.x - b.x);
  const dy = Math.abs(a.y - b.y);
  return (dx === 1 && dy === 0) || (dx === 0 && dy === 1);
};

export const isValidPath = (path: Vec2[], start: Vec2, end: Vec2): boolean => {
  if (path.length < 2) return false;

  const first = path[0];
  if (first.x !== start.x || first.y !== start.y) return false;

  const last = path[path.length - 1];
  if (last.x !== end.x || last.y !== end.y) return false;

  for (let i = 1; i < path.length; i++) {
    if (!isAdjacent(path[i - 1], path[i])) {
      return false;
    }
  }

  const seen = new Set<string>(path.map((p) => `${p.x},${p.y}`));
  if (seen.size !== path.length) return false;

  return true;
};
