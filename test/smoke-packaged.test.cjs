const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { findPackagedApp, runPackagedSmoke } = require('../scripts/smoke-packaged.cjs');

test('根据平台查找打包程序，Mac 优先检查通用包', t => {
  const dist = fs.mkdtempSync(path.join(os.tmpdir(), 'evan-package-check-'));
  t.after(() => fs.rmSync(dist, { recursive: true, force: true }));
  const native = path.join(dist, 'mac-arm64/Evan.app/Contents/MacOS/Evan');
  const universal = path.join(dist, 'mac-universal/Evan.app/Contents/MacOS/Evan');
  const windows = path.join(dist, 'win-unpacked/Evan.exe');
  for (const binary of [native, universal, windows]) { fs.mkdirSync(path.dirname(binary), { recursive: true }); fs.writeFileSync(binary, ''); }
  assert.equal(findPackagedApp(dist, 'darwin', 'arm64'), universal);
  assert.equal(findPackagedApp(dist, 'win32', 'x64'), windows);
  fs.rmSync(universal);
  assert.equal(findPackagedApp(dist, 'darwin', 'arm64'), native);
  assert.throws(() => findPackagedApp(dist, 'linux', 'x64'), /No packaged app/);
});
test('程序退出零但未真正完成检查，不能误判成功', async () => {
  await assert.rejects(runPackagedSmoke(process.execPath, ['-e', 'process.exit(0)']), /did not report smoke success/);
});
test('检查成功标记与正常退出同时满足才通过', async () => {
  await runPackagedSmoke(process.execPath, ['-e', "console.log('Evan motion smoke passed: {}')"]);
  await assert.rejects(runPackagedSmoke(process.execPath, ['-e', "console.log('Evan motion smoke passed: {}'); process.exit(1)"]), /code 1/);
});
test('超时检查会终止程序并失败', async () => {
  await assert.rejects(runPackagedSmoke(process.execPath, ['-e', 'setInterval(() => {}, 1000)'], 150), /timed out/);
});
