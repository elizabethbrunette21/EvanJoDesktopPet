const test = require('node:test');
const assert = require('node:assert/strict');
const { SIZE, clampPosition, validPosition, DesktopMotion, WALK_SPEED } = require('../src/position.cjs');

test('屏幕拔出后恢复到可见区域，支持负坐标副屏', () => {
  const area = { x: -1920, y: -100, width: 1920, height: 1080 };
  assert.deepEqual(clampPosition({ x: 5000, y: 5000 }, area), { x: -SIZE.width, y: area.y + area.height - SIZE.height });
  assert.deepEqual(clampPosition({ x: -5000, y: -5000 }, area), { x: -1920, y: -100 });
  assert.deepEqual(clampPosition({ x: -800, y: 20 }, area), { x: -800, y: 20 });
});
test('屏幕小于窗口时仍保留左上角可见', () => {
  assert.deepEqual(clampPosition({ x: 999, y: 999 }, { x: 10, y: 20, width: 100, height: 100 }), { x: 10, y: 20 });
});
test('损坏的位置数据不用于窗口坐标', () => {
  for (const value of [null, {}, { x: '1', y: 2 }, { x: Infinity, y: 0 }, { x: 1e20, y: 0 }, { x: 1.5, y: 0 }]) assert.equal(validPosition(value), false);
  assert.equal(validPosition({ x: -100, y: 0 }), true);
});

test('连续起步和刹停，保留小数位移补偿，步态距离与位移一致', () => {
  const m = new DesktopMotion(500, 1), area = { x: 0, width: 3000 };
  const first = m.step(1/60, true, area);
  assert.ok(first.speed > 0 && first.speed < WALK_SPEED);
  let s;
  for (let i = 0; i < 60; i++) s = m.step(1/60, true, area);
  assert.equal(s.speed, WALK_SPEED);
  assert.ok(Math.abs(s.distance - (s.x - 500)) < 1e-8);
  assert.ok(Math.abs(s.offsetX) <= .5 && s.offsetX !== 0);
  const stopping = m.step(1/60, false, area);
  assert.ok(stopping.speed > 0 && stopping.speed < WALK_SPEED);
  for (let i = 0; i < 40; i++) s = m.step(1/60, false, area);
  assert.equal(s.speed, 0);
  assert.equal(m.step(1/60, false, area).x, s.x);
});
test('负坐标屏幕边缘先停下再连续转向，绝不越界', () => {
  const area = { x: -1920, width: 1920 }, m = new DesktopMotion(-275, 1);
  let sawTurn = false, sawOpposite = false, previousFacing = 1;
  for (let i = 0; i < 240; i++) {
    const s = m.step(1/60, true, area);
    assert.ok(s.x >= -1920 && s.x <= -SIZE.width);
    assert.ok(Math.abs(s.facing - previousFacing) < .12);
    if (s.turning) { sawTurn = true; assert.equal(s.speed, 0); }
    if (s.direction === -1 && s.speed > 5) sawOpposite = true;
    previousFacing = s.facing;
  }
  assert.ok(sawTurn && sawOpposite);
});
test('高低刷新率位移相近；暂停后无补跑；拖动后重置原点', () => {
  const area = { x: 0, width: 3000 };
  const run = rate => { const m = new DesktopMotion(500, 1); for (let i = 0; i < rate * 2; i++) m.step(1/rate, true, area); return m; };
  assert.ok(Math.abs(run(30).x - run(120).x) < .12);
  const m = run(60), before = m.x;
  m.step(10, true, area); assert.ok(m.x - before <= WALK_SPEED * .05);
  const snapshot = m.snapshot(); m.step(NaN, true, area); assert.deepEqual(m.snapshot(), snapshot);
  m.reset(100); assert.equal(m.snapshot().offsetX, 0); assert.equal(m.snapshot().speed, 0);
  const tiny = m.step(.02, true, { x: 10, width: 100 }); assert.equal(tiny.x, 10); assert.equal(tiny.speed, 0);
});

test('转身中停止移动会落定朝向，不会把休息动作卡成侧身走路', () => {
  const m = new DesktopMotion(1000 - SIZE.width, 1), area = { x: 0, width: 1000 };
  m.step(.01, true, area); m.step(.25, true, area);
  assert.equal(m.snapshot().turning, true);
  m.stop();
  assert.equal(m.snapshot().turning, false); assert.equal(m.snapshot().speed, 0);
  assert.equal(Math.abs(m.snapshot().facing), 1);
  const x = m.x; m.step(.02, false, area); assert.equal(m.x, x);
});
