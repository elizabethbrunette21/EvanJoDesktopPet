import test from 'node:test';
import assert from 'node:assert/strict';
import { legPose, wingPose, drawWalk, LEG_PARTS, WING_PARTS } from '../src/walk-rig.mjs';

test('原有两条圆短腿整体交替运动，没有额外脚部关节', () => {
  assert.equal(LEG_PARTS.length, 2);
  for (let phase = 0; phase < Math.PI * 2; phase += .01) {
    const a = legPose(phase, 0, 1), b = legPose(phase, 1, 1);
    assert.ok(a.y >= -.3 && a.y <= 0 && Math.abs(a.angle) <= .025);
    assert.ok(a.y === 0 || b.y === 0);
    const next = legPose(phase + .01, 0, 1);
    assert.ok(Math.hypot(a.angle - next.angle, a.y - next.y) < .01);
  }
});

test('翅尖慢速对称轻摆、循环连续、幅度小于一度', () => {
  assert.equal(WING_PARTS.length, 2);
  for (let t = 0; t < 3.6; t += .01) {
    const left = wingPose(t, 0), right = wingPose(t, 1);
    assert.ok(Math.abs(left) <= .012);
    assert.ok(Math.abs(left + right) < 1e-8);
    assert.ok(Math.abs(left - wingPose(t + .01, 0)) < .001);
  }
  assert.ok(Math.abs(wingPose(3.6, 0) - wingPose(0, 0)) < 1e-8);
});
test('两侧原翅片各绘制一次，完整腿和身体仍在前景且尺寸不变', () => {
  const left = { image: { width: 302, height: 98 }, x: 56, y: 1126, pivotX: 175, pivotY: 0 };
  const right = { image: { width: 284, height: 97 }, x: 595, y: 1127, pivotX: 102, pivotY: -1 };
  const body = { width: 946, height: 1247 };
  const leg = { image: { width: 58, height: 84 }, x: 364, y: 1138, pivotX: 27, pivotY: 5 };
  for (let t = 0; t < 3.6; t += .1) {
    const calls = [];
    const ctx = { save() {}, restore() {}, translate() {}, rotate() {}, drawImage(...args) { calls.push(args); } };
    drawWalk(ctx, { body, legs: [leg], wings: [left, right] }, 946, 1247, 0, 0, t);
    assert.deepEqual(calls.map(c => c[0]), [left.image, right.image, leg.image, body]);
    assert.deepEqual(calls[0].slice(3), [302, 98]); assert.deepEqual(calls[1].slice(3), [284, 97]);
  }
});
test('每条完整小腿只画一次，衣片在前覆盖根部，不追加脚掌', () => {
  const layers = { body: { width: 946, height: 1247 }, legs: [
    { image: { width: 58, height: 84 }, x: 364, y: 1138, pivotX: 27, pivotY: 5 },
    { image: { width: 63, height: 124 }, x: 509, y: 1096, pivotX: 30, pivotY: 12 }
  ] };
  for (let phase = 0; phase < Math.PI * 2; phase += .1) {
    const calls = [];
    const ctx = { save() {}, restore() {}, translate() {}, rotate() {}, drawImage(...args) { calls.push(args); } };
    drawWalk(ctx, layers, 946, 1247, phase, 1);
    assert.equal(calls.length, 3);
    assert.deepEqual(calls.map(c => c[0]), [layers.legs[0].image, layers.legs[1].image, layers.body]);
    assert.deepEqual(calls[0].slice(3), [58, 84]); assert.deepEqual(calls[1].slice(3), [63, 124]);
  }
});
