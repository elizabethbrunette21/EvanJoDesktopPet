const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const vm = require('node:vm');
const { createRequire } = require('node:module');
const { readPreferences, writePreferences } = require('../src/preferences.cjs');

function directory(t) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'evan-preferences-test-'));
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));
  return dir;
}

test('首次启动使用默认偏好；读取不会提前创建文件', t => {
  const file = path.join(directory(t), 'preferences.json');
  assert.deepEqual(readPreferences(file), { roaming: true, paused: false });
  assert.equal(fs.existsSync(file), false);
});

test('重新加载保留走动与暂停，临时状态不写入偏好', t => {
  const file = path.join(directory(t), 'nested', 'preferences.json');
  writePreferences(file, { roaming: false, paused: true, resting: true, visible: false, direction: -1 });
  assert.deepEqual(readPreferences(file), { roaming: false, paused: true });
  assert.deepEqual(JSON.parse(fs.readFileSync(file, 'utf8')), { roaming: false, paused: true });
  writePreferences(file, { roaming: true, paused: false });
  assert.deepEqual(readPreferences(file), { roaming: true, paused: false });
  assert.deepEqual(fs.readdirSync(path.dirname(file)), ['preferences.json']);
});

test('损坏或错误类型的设置回到安全默认值，保留其他有效布尔值', t => {
  const file = path.join(directory(t), 'preferences.json');
  for (const value of ['{broken', 'null', '[]', 'false', '42']) {
    fs.writeFileSync(file, value);
    assert.deepEqual(readPreferences(file), { roaming: true, paused: false });
    assert.equal(fs.readFileSync(file, 'utf8'), value);
  }
  fs.writeFileSync(file, JSON.stringify({ roaming: false, paused: 'false' }));
  assert.deepEqual(readPreferences(file), { roaming: false, paused: false });
  fs.writeFileSync(file, JSON.stringify({ roaming: 0, paused: true }));
  assert.deepEqual(readPreferences(file), { roaming: true, paused: true });
});

test('原子替换失败时原设置仍完整，临时文件会清理', t => {
  const dir = directory(t), file = path.join(dir, 'preferences.json');
  writePreferences(file, { roaming: false, paused: true });
  const before = fs.readFileSync(file, 'utf8');
  t.mock.method(fs, 'renameSync', () => { throw Object.assign(new Error('disk unavailable'), { code: 'EACCES' }); });
  assert.throws(() => writePreferences(file, { roaming: true, paused: false }), /disk unavailable/);
  assert.equal(fs.readFileSync(file, 'utf8'), before);
  assert.deepEqual(fs.readdirSync(dir), ['preferences.json']);
});

test('smoke 在单实例锁之前隔离配置与缓存，正常启动不改写真实路径', t => {
  const dir = directory(t), realProfile = path.join(dir, 'real-profile');
  fs.mkdirSync(realProfile);
  const sentinel = path.join(realProfile, 'preferences.json');
  fs.writeFileSync(sentinel, '{"roaming":false,"paused":true}');
  const filename = path.resolve(__dirname, '../src/main.cjs');
  const code = fs.readFileSync(filename, 'utf8'), requireMain = createRequire(filename);
  const execute = smoke => {
    const paths = { temp: dir, userData: realProfile, sessionData: realProfile };
    let atLock;
    const app = {
      getPath: key => paths[key], setPath: (key, value) => { paths[key] = value; },
      requestSingleInstanceLock: () => { atLock = { ...paths }; return false; }, quit() {}, on() {}
    };
    vm.runInNewContext(code, {
      require: name => name === 'electron' ? { app } : requireMain(name),
      process: { argv: smoke ? ['electron', '.', '--smoke-test'] : ['electron', '.'] }, console
    }, { filename });
    return atLock;
  };
  const normal = execute(false), first = execute(true), second = execute(true);
  assert.equal(normal.userData, realProfile); assert.equal(normal.sessionData, realProfile);
  assert.notEqual(first.userData, realProfile); assert.notEqual(second.userData, first.userData);
  assert.equal(first.sessionData, first.userData); assert.ok(fs.existsSync(first.userData));
  assert.equal(fs.readFileSync(sentinel, 'utf8'), '{"roaming":false,"paused":true}');
});
