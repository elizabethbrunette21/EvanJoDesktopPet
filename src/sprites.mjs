import { frameAt } from './motion.mjs';
import { drawWalk, makeWalkLayers, EXTRA_TABS } from './walk-rig.mjs';
export const SHEETS = {
  base: { file: 'idle-v2.png', columns: 1, rows: 1, reference: 0 },
  walk: { file: 'motion-v1/walk.png', columns: 4, rows: 2, reference: 0 },
  expressions: { file: 'motion-v1/expressions-mouthless.png', columns: 4, rows: 2, reference: 0 },
  activities: { file: 'motion-v1/activities.png', columns: 4, rows: 3, reference: 9 },
  gong: { file: 'motion-v2/gong.png', columns: 2, rows: 2, reference: 0 },
  skullStaff: { file: 'motion-v2/skull-staff.png', columns: 2, rows: 2, reference: 0 }
};
export class SpritePlayer {
  constructor(canvas) {
    this.canvas = canvas; this.ctx = canvas.getContext('2d'); this.sheets = new Map(); this.frames = 0;
    const ratio = Math.min(devicePixelRatio || 1, 2);
    canvas.width = 240 * ratio; canvas.height = 260 * ratio; this.ctx.scale(ratio, ratio);
    this.displayScale = canvas.clientWidth / 240;
  }
  async load() {
    await Promise.all(Object.entries(SHEETS).map(async ([key, spec]) => {
      const image = new Image(); image.src = `../assets/characters/evan/${spec.file}`; await image.decode();
      const scratch = document.createElement('canvas'); scratch.width = image.width; scratch.height = image.height;
      const context = scratch.getContext('2d', { willReadFrequently: true }); context.drawImage(image, 0, 0);
      const pixels = context.getImageData(0, 0, image.width, image.height).data, cells = [];
      for (let i = 0; i < spec.columns * spec.rows; i++) {
        const left = Math.round(i % spec.columns * image.width / spec.columns);
        const top = Math.round(Math.floor(i / spec.columns) * image.height / spec.rows);
        const right = Math.round((i % spec.columns + 1) * image.width / spec.columns);
        const bottom = Math.round((Math.floor(i / spec.columns) + 1) * image.height / spec.rows);
        let x0 = right, x1 = left, y0 = bottom, y1 = top;
        for (let y = top; y < bottom; y++) for (let x = left; x < right; x++) {
          if (pixels[(y * image.width + x) * 4 + 3] < 48) continue;
          x0 = Math.min(x0, x); x1 = Math.max(x1, x); y0 = Math.min(y0, y); y1 = Math.max(y1, y);
        }
        if (x1 <= x0 || y1 <= y0) throw new Error(`${key} 第 ${i + 1} 帧为空`);
        cells.push({ x: x0, y: y0, width: x1 - x0 + 1, height: y1 - y0 + 1 });
      }
      // One scale per atlas keeps sitting from shrinking the character's head.
      const scale = Math.min(210 / cells[spec.reference].height, 222 / Math.max(...cells.map(c => c.width)),
        238 / Math.max(...cells.map(c => c.height)));
      const clean = document.createElement('canvas'); clean.width = image.width; clean.height = image.height;
      const art = clean.getContext('2d'); art.drawImage(image, 0, 0);
      for (const [x, y, width, height] of EXTRA_TABS[key] || []) art.clearRect(x, y, width, height);
      this.sheets.set(key, { image: clean, cells, scale });
      if (key === 'base') {
        this.walkLayers = makeWalkLayers(clean, cells[0]);
      }
    }));
  }
  drawPose(pose, alpha, state, elapsed, clock, direction, still, travel = {}) {
    const { image, cells, scale } = this.sheets.get(pose.sheet), rect = cells[pose.index];
    const width = rect.width * scale, height = rect.height * scale, t = still ? 0 : clock, walk = state === 'walk';
    const phase = travel.phase ?? elapsed * Math.PI * 2.5;
    const strength = still ? 0 : travel.strength ?? 1;
    const bounce = walk ? (1 - Math.cos(phase * 2)) * .25 * strength : Math.sin(t * 2) * .65;
    const lift = state === 'float' ? 10 + Math.sin(t * 2.4) * 6 : state === 'hop' ? Math.sin(Math.min(1, elapsed / .9) * Math.PI) * 18 : 0;
    const angle = state === 'dragged' ? Math.sin(t * 4) * .055 : ['wave', 'tilt'].includes(state) ? Math.sin(t * 5) * .018 : 0;
    const ctx = this.ctx; ctx.save(); ctx.globalAlpha = alpha;
    ctx.translate(120 + (travel.offsetX || 0) / this.displayScale, 250 - (still ? 0 : bounce + lift)); ctx.rotate(still ? 0 : angle);
    if (walk) ctx.scale(direction < 0 ? -1 : 1, 1);
    else ctx.scale(1, still ? 1 : 1 + Math.sin(t * (state === 'sleep' ? 1.7 : 2.2)) * .003);
    if (pose.sheet === 'base') {
      drawWalk(ctx, this.walkLayers, width, height, phase, walk ? strength : 0, t);
      ctx.restore(); return;
    }
    // Gentle continuous follow-through between the drawn keyframes.
    for (let strip = 0; strip < 32; strip++) {
      const unit = strip / 32, sy = rect.y + rect.height * unit;
      const sh = Math.min(rect.height / 32 + .5, rect.y + rect.height - sy);
      const sway = still ? 0 : Math.sin(t * (walk ? 6 : 1.8) - unit * 2.5) * unit * unit * (walk ? 1.8 : .75);
      ctx.drawImage(image, rect.x, sy, rect.width, sh, -width / 2 + sway, -height + height * unit, width, sh * scale + .35);
    }
    ctx.restore();
  }
  draw(state, elapsed, clock, direction = 1, still = false, travel = {}) {
    const pose = state === 'walk' ? { sheet: 'base', index: 0 } : frameAt(state, elapsed), key = `${state}:${pose.sheet}:${pose.index}`;
    if (key !== this.lastKey) {
      this.transition = this.lastSample && !['walk', 'blink', 'gong'].includes(state) && this.lastSample.state !== 'walk' && !still ? { ...this.lastSample, start: clock } : null;
      this.lastKey = key; this.lastPose = pose;
    }
    this.ctx.clearRect(0, 0, 240, 260);
    const amount = this.transition ? Math.min(1, (clock - this.transition.start) / .12) : 1;
    if (amount < 1) {
      const previous = this.transition;
      this.drawPose(previous.pose, 1 - amount, previous.state, previous.elapsed, previous.clock, previous.direction, still, { ...previous.travel, offsetX: travel.offsetX });
    }
    this.drawPose(pose, amount, state, elapsed, clock, direction, still, travel);
    this.lastSample = { pose, state, elapsed, clock, direction, travel: { ...travel } };
    if (amount === 1) this.transition = null;
    this.frames++;
  }
}
