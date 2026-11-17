import { Behavior, CLIPS } from './motion.mjs';
import { SpritePlayer } from './sprites.mjs';
const pet = document.querySelector('#pet'), bubble = document.querySelector('#bubble'), status = document.querySelector('#status');
const behavior = new Behavior(), player = new SpritePlayer(document.querySelector('#sprite'));
const reduced = matchMedia('(prefers-reduced-motion: reduce)');
let settings = { paused: false, resting: false, visible: true, direction: -1, roaming: true };
let pointer = null, moved = false, timer, phraseIndex = 0, raf = 0, lastTime = null, clock = 0, loaded = false, running = false, generation = 0;
let travel = { offsetX: 0, speed: 0, distance: 0, direction: -1, facing: -1, turning: false, x: 0 };
const drawTimes = [], frameTimes = [];
const percentile = (values, p) => values.length ? [...values].sort((a, b) => a - b)[Math.floor((values.length - 1) * p)] : 0;
function draw(still = false) {
  const start = performance.now();
  const moving = travel.speed > .5 || travel.turning;
  const state = moving && !pointer ? 'walk' : behavior.current;
  const inPlace = !settings.roaming && state === 'walk';
  player.draw(state, behavior.elapsed, clock, travel.direction, still, {
    ...travel, phase: inPlace ? clock * Math.PI * 3 : travel.distance / 20 * Math.PI * 2,
    strength: inPlace ? 1 : Math.min(1, travel.speed / 25)
  });
  drawTimes.push(performance.now() - start); if (drawTimes.length > 240) drawTimes.shift();
  pet.dataset.state = behavior.current; pet.dataset.renderState = state; pet.dataset.frames = String(player.frames);
}
async function frame(time) {
  raf = 0;
  const token = generation;
  const delta = lastTime === null ? 0 : Math.min((time - lastTime) / 1000, .05);
  if (lastTime !== null) { frameTimes.push(time - lastTime); if (frameTimes.length > 240) frameTimes.shift(); }
  lastTime = time; clock += delta; behavior.tick(delta);
  const walking = behavior.current === 'walk' && !pointer && settings.roaming;
  if (!pointer && (walking || travel.speed > 0 || travel.turning)) {
    try {
      const result = await window.evan.step(delta, walking);
      if (token !== generation || !running) return;
      if (result) travel = result;
    } catch (error) {
      running = false; status.hidden = false; status.textContent = '移动暂时停止，请重新打开 Evan。';
      console.error(error); return;
    }
  }
  if (token !== generation || !running) return;
  draw(); raf = requestAnimationFrame(frame);
}
function syncLoop() {
  behavior.paused = settings.paused; behavior.reduced = reduced.matches;
  if (!loaded) return;
  const animate = settings.visible && !settings.paused && !reduced.matches;
  if (!animate) {
    generation++; running = false; cancelAnimationFrame(raf); raf = 0; lastTime = null; window.evan.stop();
    // Pausing holds the exact rendered pose; only reduced motion deliberately chooses a static pose.
    if (reduced.matches && settings.visible && !settings.paused) draw(true);
  } else if (!running) { generation++; running = true; lastTime = null; raf = requestAnimationFrame(frame); }
}
function invalidateFrame() {
  generation++; cancelAnimationFrame(raf); raf = 0; running = false; lastTime = null;
}
function action(name) {
  if (settings.resting || !behavior.play(name)) return;
  invalidateFrame();
  window.evan.stop(); travel = { ...travel, speed: 0, turning: false };
  if (loaded) draw(reduced.matches); syncLoop();
}
function greet() {
  if (settings.resting) return;
  bubble.textContent = ['我在。', '嗯？是在叫我吗。', '陪你待一会儿。'][phraseIndex++ % 3];
  bubble.hidden = false; action(phraseIndex % 2 ? 'wave' : 'look');
  clearTimeout(timer); timer = setTimeout(() => { bubble.hidden = true; }, 2200);
}
pet.addEventListener('pointerdown', event => {
  if (event.button !== 0) return;
  invalidateFrame();
  pointer = { id: event.pointerId, x: event.screenX, y: event.screenY }; moved = false;
  pet.setPointerCapture(event.pointerId); window.evan.dragStart(); travel = { ...travel, offsetX: 0, speed: 0, turning: false };
  syncLoop();
});
pet.addEventListener('pointermove', event => {
  if (!pointer) return;
  if (!moved && Math.hypot(event.screenX - pointer.x, event.screenY - pointer.y) > 4) { moved = true; action('dragged'); }
  if (moved) window.evan.dragMove();
});
function finishDrag(cancelled = false) {
  if (!pointer) return;
  invalidateFrame();
  pointer = null; window.evan.dragEnd(); travel = { ...travel, offsetX: 0, speed: 0, turning: false };
  if (moved) action('hop');
  if (cancelled) moved = true;
  syncLoop();
}
pet.addEventListener('pointerup', () => finishDrag());
pet.addEventListener('pointercancel', () => finishDrag(true));
pet.addEventListener('lostpointercapture', () => finishDrag(true));
window.addEventListener('blur', () => finishDrag(true));
pet.addEventListener('click', () => { if (!moved) greet(); moved = false; });
pet.addEventListener('contextmenu', event => { event.preventDefault(); window.evan.menu(); });
window.addEventListener('mousemove', event => window.evan.setPassthrough(!pointer && !pet.contains(event.target)));
window.evan.onSettings(value => {
  const wasResting = settings.resting;
  if (value.resting !== settings.resting || value.roaming !== settings.roaming) invalidateFrame();
  settings = value;
  if (value.motion && !pointer) travel = value.motion;
  if (value.resting !== wasResting) behavior.setRest(value.resting);
  syncLoop();
});
window.evan.onAction(action); reduced.addEventListener('change', syncLoop);
try {
  await player.load(); loaded = true; status.hidden = true; pet.dataset.ready = 'true';
  window.petDiagnostics = { snapshot: () => ({ state: behavior.current, renderState: pet.dataset.renderState, elapsed: behavior.elapsed, frames: player.frames,
    ready: loaded, sheets: player.sheets.size, paused: behavior.paused, reduced: behavior.reduced, visible: settings.visible, clock,
    motion: { ...travel }, renderP95Ms: percentile(drawTimes, .95), frameP95Ms: percentile(frameTimes, .95),
    cells: Object.fromEntries([...player.sheets].map(([key, sheet]) => [key, sheet.cells.length])), clips: Object.keys(CLIPS) }) };
  draw(reduced.matches); syncLoop();
} catch (error) {
  status.textContent = '动作素材加载失败，请重新打开 Evan。'; status.hidden = false;
  pet.dataset.error = error.message; console.error(error);
}
