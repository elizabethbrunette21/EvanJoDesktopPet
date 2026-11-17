const pose = (sheet, index) => ({ sheet, index });
const base = pose('base', 0), e = i => pose('expressions', i), a = i => pose('activities', i);
export const CLIPS = {
  idle: { seconds: 1.2, frames: [base] },
  blink: { seconds: .32, frames: [e(0), e(1), e(2), e(1), e(0)] },
  look: { seconds: 2, frames: [e(3), e(0), e(4), e(0)] },
  tilt: { seconds: 1.6, frames: [e(5)] },
  listen: { seconds: 1.8, frames: [e(6)] },
  wave: { seconds: 1.6, frames: [e(7)] },
  // Use the approved standing proportions and its original whole rounded legs.
  walk: { seconds: 10.4, frames: [base] },
  sit: { seconds: 2.4, frames: [a(0), a(1), a(1), a(1), a(1), a(1)] },
  sleep: { seconds: 5.5, frames: [a(2), a(3), a(3), a(3), a(3), a(3), a(2)] },
  stretch: { seconds: 2.4, frames: [a(4), a(5), a(5), a(5), a(4)] },
  hop: { seconds: .9, frames: [a(0), a(6), a(6), a(6), a(0)] },
  float: { seconds: 3, frames: [a(7)] },
  dragged: { seconds: Infinity, frames: [a(8)] },
  turn: { seconds: 2.2, frames: [a(9), a(10), a(10), a(9)] },
  sign: { seconds: 3, frames: [a(11)] },
  gong: { seconds: 4, frames: Array.from({ length: 4 }, (_, i) => pose('gong', i)), fps: 6 },
  skullStaff: { seconds: 5, frames: Array.from({ length: 4 }, (_, i) => pose('skullStaff', i)), fps: 2 }
};
export function frameAt(name, elapsed) {
  const clip = CLIPS[name];
  const i = clip.fps ? Math.floor(elapsed * clip.fps) % clip.frames.length :
    Math.min(clip.frames.length - 1, Math.floor(elapsed / clip.seconds * clip.frames.length));
  return clip.frames[Math.max(0, i)];
}
// Walking links the shuffled activities so the pet explores instead of posing in one place.
export class Behavior {
  constructor(random = Math.random) {
    Object.assign(this, { random, current: 'idle', elapsed: 0, queue: ['walk', 'idle'], bag: [], resting: false, paused: false, reduced: false });
  }
  play(name) {
    if (!Object.hasOwn(CLIPS, name)) return false;
    this.current = name; this.elapsed = 0;
    this.queue = name === 'sleep' ? ['sit', 'stretch', 'idle', 'walk', 'idle'] : ['idle', 'walk', 'idle'];
    return true;
  }
  setRest(value) {
    if (this.resting === value) return;
    this.resting = value;
    this.play(value ? 'sit' : 'stretch');
    if (value) this.queue = ['sleep'];
  }
  tick(delta) {
    if (this.paused || this.reduced || !Number.isFinite(delta) || delta <= 0) return;
    // A long scheduling stall must not replay a whole sequence when the window resumes.
    this.elapsed += Math.min(delta, .25);
    if (this.resting && this.current === 'sleep') { this.elapsed = Math.min(this.elapsed, 3); return; }
    while (this.elapsed >= CLIPS[this.current].seconds) {
      this.elapsed -= CLIPS[this.current].seconds;
      let next = this.queue.shift();
      if (!next) {
        if (!this.bag.length) {
          this.bag = Object.keys(CLIPS).filter(n => !['idle', 'walk', 'dragged'].includes(n));
          for (let i = this.bag.length - 1; i > 0; i--) {
            const j = Math.floor(this.random() * (i + 1));
            [this.bag[i], this.bag[j]] = [this.bag[j], this.bag[i]];
          }
        }
        next = this.bag.pop();
        if (next === 'sleep') { next = 'sit'; this.queue.push('sleep', 'sit', 'stretch', 'idle', 'walk', 'idle'); }
        else this.queue.push('idle', 'walk', 'idle');
      }
      this.current = next;
    }
  }
}
