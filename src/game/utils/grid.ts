import { GRID_CONFIG } from "../config/grid";

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

export const isAdjacent = (
  x1: number,
  y1: number,
  x2: number,
  y2: number,
): boolean => {
  const dx = Math.abs(x1 - x2);
  const dy = Math.abs(y1 - y2);
  return (dx === 1 && dy === 0) || (dx === 0 && dy === 1);
};
