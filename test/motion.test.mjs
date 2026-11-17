import test from 'node:test';
import assert from 'node:assert/strict';
import { Behavior, CLIPS, frameAt } from '../src/motion.mjs';
import { SHEETS } from '../src/sprites.mjs';
const advance = (b, seconds) => { for (let i = 0; i < seconds * 100; i++) b.tick(.01); };
test('每个动作帧都落在有效图集单元格内，走路循环完整', () => {
  assert.equal(Object.hasOwn(CLIPS, 'happy'), false);
  assert.equal(Object.hasOwn(CLIPS, 'talk'), false);
  for (const [name, clip] of Object.entries(CLIPS)) {
    for (const f of clip.frames) { const s = SHEETS[f.sheet]; assert.ok(f.index >= 0 && f.index < s.rows * s.columns, name); }
    assert.ok(frameAt(name, 0));
  }
  assert.equal(frameAt('walk', .7).index, 0); assert.equal(frameAt('walk', 9).index, 0);
  assert.equal(frameAt('gong', .5).index, 3); assert.equal(frameAt('gong', 4/6).index, 0);
  assert.equal(frameAt('skullStaff', 1.5).index, 3); assert.equal(frameAt('skullStaff', 2).index, 0);
});
test('自动轮换覆盖所有活动；拖起不会自行超时', () => {
  const b = new Behavior(() => .5), visited = new Set();
  for (let i = 0; i < 40000; i++) { b.tick(.01); visited.add(b.current); }
  for (const name of Object.keys(CLIPS).filter(n => n !== 'dragged')) assert.ok(visited.has(name), name);
  b.play('dragged'); advance(b, 30); assert.equal(b.current, 'dragged'); b.play('hop'); advance(b, 1); assert.equal(b.current, 'idle');
  assert.equal(b.play('__proto__'), false);
});
test('短暂站立后开始走动，并在每项活动之间继续走动', () => {
  const b = new Behavior(() => .5);
  advance(b, 1.1); assert.equal(b.current, 'idle');
  advance(b, .2); assert.equal(b.current, 'walk');
  const transitions = ['walk'];
  let walkTime = 0;
  for (let i = 0; i < 40000; i++) {
    b.tick(.01);
    if (b.current === 'walk') walkTime += .01;
    if (b.current !== transitions.at(-1)) transitions.push(b.current);
  }
  assert.ok(walkTime > 200, '自动活动中超过一半时间应在走路');
  const walks = transitions.reduce((indices, name, i) => name === 'walk' ? [...indices, i] : indices, []);
  assert.ok(walks.length > 20);
  for (let i = 1; i < walks.length; i++) {
    const between = transitions.slice(walks[i - 1] + 1, walks[i]).filter(name => name !== 'idle');
    assert.ok(between.length > 0 && between.length <= 4, between.join(','));
  }
});
test('不同刷新频率保持相同动作进度，切换时保留余下时间', () => {
  const slow = new Behavior(() => .5), fast = new Behavior(() => .5);
  for (let i = 0; i < 1287; i++) slow.tick(.05);
  for (let i = 0; i < 6435; i++) fast.tick(.01);
  assert.equal(slow.current, fast.current);
  assert.ok(Math.abs(slow.elapsed - fast.elapsed) < 1e-8);
  const b = new Behavior();
  b.play('hop'); b.tick(.25); b.tick(.25); b.tick(.25); b.tick(.25);
  assert.equal(b.current, 'idle'); assert.ok(Math.abs(b.elapsed - .1) < 1e-8);
  const before = b.elapsed; b.tick(NaN); b.tick(Infinity); b.tick(-1); assert.equal(b.elapsed, before);
  b.tick(60); assert.ok(Math.abs(b.elapsed - before - .25) < 1e-8);
});
test('暂停、减弱动态效果、休息、醒来均可恢复', () => {
  const b = new Behavior(); b.play('walk'); b.paused = true; advance(b, 10); assert.equal(b.elapsed, 0);
  b.paused = false; b.reduced = true; advance(b, 10); assert.equal(b.elapsed, 0);
  b.reduced = false; b.setRest(true); advance(b, 20); assert.equal(b.current, 'sleep'); assert.ok(b.elapsed <= 3);
  b.setRest(false); assert.equal(b.current, 'stretch'); advance(b, 3); assert.equal(b.current, 'idle');
});
