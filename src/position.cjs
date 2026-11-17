const SIZE = { width: 208, height: 256 };
function clampPosition(point, area, size = SIZE) {
  return {
    x: Math.round(Math.max(area.x, Math.min(point.x, area.x + Math.max(0, area.width - size.width)))),
    y: Math.round(Math.max(area.y, Math.min(point.y, area.y + Math.max(0, area.height - size.height))))
  };
}
function validPosition(value) {
  return value !== null && typeof value === 'object' &&
    [value.x, value.y].every(coordinate => Number.isInteger(coordinate) && coordinate >= -2147483648 && coordinate <= 2147483647);
}
const WALK_SPEED = 30, ACCELERATION = 110, TURN_SECONDS = .48;
class DesktopMotion {
  constructor(x, direction = -1) { this.direction = direction; this.distance = 0; this.reset(x); }
  reset(x) { this.x = x; this.velocity = 0; this.turn = null; }
  stop() {
    if (this.turn !== null && this.turn >= TURN_SECONDS / 2) this.direction *= -1;
    this.turn = null; this.velocity = 0;
  }
  snapshot() {
    return { x: this.x, offsetX: this.x - Math.round(this.x), speed: Math.abs(this.velocity), distance: this.distance,
      direction: this.direction, facing: this.direction * (this.turn === null ? 1 : Math.cos(Math.PI * this.turn / TURN_SECONDS)),
      turning: this.turn !== null };
  }
  step(delta, walking, area, width = SIZE.width) {
    if (!Number.isFinite(delta) || delta <= 0) return this.snapshot();
    const dt = Math.min(delta, .05), min = area.x, max = min + Math.max(0, area.width - width);
    this.x = Math.max(min, Math.min(max, this.x));
    if (max === min) { this.velocity = 0; this.turn = null; return this.snapshot(); }
    if (this.turn !== null) {
      this.turn += dt;
      if (this.turn >= TURN_SECONDS) { this.turn = null; this.direction *= -1; }
      return this.snapshot();
    }
    const edge = this.direction > 0 ? max - this.x : this.x - min;
    if (walking && edge < .5 && Math.abs(this.velocity) < 5) {
      this.velocity = 0; this.turn = 0; return this.snapshot();
    }
    const target = walking ? this.direction * Math.min(WALK_SPEED, Math.sqrt(2 * ACCELERATION * Math.max(0, edge - .25))) : 0;
    const oldVelocity = this.velocity;
    this.velocity += Math.max(-ACCELERATION * dt, Math.min(ACCELERATION * dt, target - this.velocity));
    const oldX = this.x;
    this.x = Math.max(min, Math.min(max, this.x + (oldVelocity + this.velocity) * .5 * dt));
    this.distance += Math.abs(this.x - oldX);
    return this.snapshot();
  }
}
module.exports = { SIZE, clampPosition, validPosition, DesktopMotion, WALK_SPEED };
