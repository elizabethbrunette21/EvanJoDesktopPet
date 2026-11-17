const { app, BrowserWindow, Menu, Tray, ipcMain, screen } = require('electron');
const fs = require('node:fs');
const path = require('node:path');
const { SIZE, clampPosition, validPosition, DesktopMotion } = require('./position.cjs');
const { readPreferences, writePreferences } = require('./preferences.cjs');
const smoke = process.argv.includes('--smoke-test');
// Isolate test preferences, Chromium data and the instance lock before touching the real profile.
if (smoke) {
  const directory = fs.mkdtempSync(path.join(app.getPath('temp'), 'evan-smoke-'));
  app.setPath('userData', directory);
  app.setPath('sessionData', directory);
}
const labels = { idle: '站着陪你', blink: '眨眨眼', look: '左右看看', tilt: '歪歪头', listen: '认真听着', wave: '挥挥手', walk: '走一走', sit: '坐下来', sleep: '打个盹', stretch: '伸懒腰', hop: '跳一下', float: '飘起来', dragged: '悬空晃晃', turn: '转身', sign: '举牌子', gong: '敲锣', skullStaff: '拿着骷髅头杆子' };
let win, tray, drag, stateFile, preferencesFile, motion;
let passthrough = false;
const settings = { paused: false, resting: false, roaming: true, direction: -1, visible: true };
function keepVisible(point) { return clampPosition(point, screen.getDisplayNearestPoint(point).workArea); }
function savePosition() {
  if (smoke || !win || win.isDestroyed()) return;
  const [x, y] = win.getPosition();
  try { fs.writeFileSync(stateFile, JSON.stringify({ x, y })); }
  catch (error) { console.warn('无法保存 Evan 的位置:', error.message); }
}
function resetMotion() {
  if (motion && win && !win.isDestroyed()) motion.reset(win.getPosition()[0]);
}
function stopWalking() { if (motion) motion.stop(); }
function stepMotion(event, delta, walking) {
  if (!win || win.isDestroyed() || event.sender.isDestroyed()) return null;
  if (event.sender !== win.webContents || event.senderFrame !== win.webContents.mainFrame ||
      typeof walking !== 'boolean' || !Number.isFinite(delta) || delta < 0 || delta > .1) return null;
  if (settings.paused || settings.resting || !settings.visible || drag || !settings.roaming) {
    stopWalking(); return motion.snapshot();
  }
  const [x, y] = win.getPosition();
  if (Math.abs(x - Math.round(motion.x)) > 1) motion.reset(x);
  const oldSpeed = Math.abs(motion.velocity);
  const result = motion.step(delta, walking, screen.getDisplayNearestPoint({ x, y }).workArea);
  const nativeX = Math.round(result.x);
  if (nativeX !== x) win.setPosition(nativeX, y, false);
  settings.direction = result.direction;
  if (oldSpeed > 0 && result.speed === 0) savePosition();
  return result;
}
function publish(refresh = true, visible = settings.visible) {
  settings.visible = visible;
  win.webContents.send('pet:settings', { ...settings, motion: motion?.snapshot() });
  if (tray && refresh) tray.setContextMenu(menu());
}
function change(patch) {
  const preferencesChanged = ['roaming', 'paused'].some(key => Object.hasOwn(patch, key) && patch[key] !== settings[key]);
  Object.assign(settings, patch);
  if (preferencesChanged && preferencesFile) {
    try { writePreferences(preferencesFile, settings); }
    catch (error) { console.warn('无法保存 Evan 的偏好设置:', error.message); }
  }
  if (settings.paused || settings.resting || !settings.roaming) stopWalking();
  publish();
}
function action(name) {
  if (!Object.hasOwn(labels, name)) return;
  change({ paused: false, resting: false });
  win.webContents.send('pet:action', name);
}
function repositionPet() {
  const [x, y] = win.getPosition(), point = keepVisible({ x, y });
  win.setPosition(point.x, point.y); resetMotion();
}
function showPet() { repositionPet(); win.showInactive(); publish(false, true); }
function hidePet() { stopWalking(); win.hide(); publish(false, false); }
function menu() {
  return Menu.buildFromTemplate([
    { label: '显示 Evan', click: showPet },
    { label: '做个动作', submenu: Object.entries(labels).map(([name, label]) => ({ label, click: () => action(name) })) },
    { label: '自由走动', type: 'checkbox', checked: settings.roaming, click: item => change({ roaming: item.checked }) },
    { label: '暂停动画', type: 'checkbox', checked: settings.paused, click: item => change({ paused: item.checked }) },
    { label: '休息一会儿', type: 'checkbox', checked: settings.resting, click: item => change({ resting: item.checked, paused: false }) },
    { label: '回到屏幕右下角', click: () => {
      const area = screen.getPrimaryDisplay().workArea;
      const point = clampPosition({ x: area.x + area.width - SIZE.width - 24, y: area.y + area.height - SIZE.height }, area);
      stopWalking(); win.setPosition(point.x, point.y); resetMotion(); showPet(); savePosition(); action('idle');
    } },
    { type: 'separator' },
    { label: '隐藏 Evan', click: hidePet },
    { label: '退出 Evan', click: () => app.quit() }
  ]);
}
if (!app.requestSingleInstanceLock()) app.quit();
else {
  app.on('second-instance', () => { if (win) showPet(); });
  app.whenReady().then(async () => {
    stateFile = path.join(app.getPath('userData'), 'position.json');
    preferencesFile = path.join(app.getPath('userData'), 'preferences.json');
    try { Object.assign(settings, readPreferences(preferencesFile)); }
    catch (error) { console.warn('忽略无法读取的偏好设置:', error.message); }
    const area = screen.getPrimaryDisplay().workArea;
    let point = { x: area.x + area.width - SIZE.width - 24, y: area.y + area.height - SIZE.height };
    try { const saved = JSON.parse(fs.readFileSync(stateFile, 'utf8')); if (validPosition(saved)) point = saved; }
    catch (error) { if (error.code !== 'ENOENT') console.warn('忽略无法读取的位置:', error.message); }
    win = new BrowserWindow({ ...SIZE, ...keepVisible(point), frame: false, transparent: true,
      resizable: false, maximizable: false, fullscreenable: false, alwaysOnTop: true, skipTaskbar: true, hasShadow: false, show: false,
      webPreferences: { preload: path.join(__dirname, 'preload.cjs'), contextIsolation: true, nodeIntegration: false, sandbox: true, backgroundThrottling: false }
    });
    motion = new DesktopMotion(win.getPosition()[0], settings.direction);
    ipcMain.handle('pet:step', stepMotion);
    win.webContents.setWindowOpenHandler(() => ({ action: 'deny' }));
    win.webContents.on('will-navigate', event => event.preventDefault());
    if (process.platform === 'darwin') { app.dock.hide(); win.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true }); }
    for (const [channel, handler] of Object.entries({
      'pet:drag-start': () => { drag = { cursor: screen.getCursorScreenPoint(), bounds: win.getBounds() }; resetMotion(); },
      'pet:drag-move': () => {
        if (!drag) return;
        const cursor = screen.getCursorScreenPoint();
        const point = keepVisible({ x: drag.bounds.x + cursor.x - drag.cursor.x, y: drag.bounds.y + cursor.y - drag.cursor.y });
        win.setPosition(point.x, point.y); resetMotion();
      },
      'pet:drag-end': () => { drag = null; resetMotion(); savePosition(); },
      'pet:passthrough': (_event, value) => {
        if (typeof value === 'boolean' && value !== passthrough && !drag) { passthrough = value; win.setIgnoreMouseEvents(value, { forward: true }); }
      },
      'pet:stop': stopWalking,
      'pet:menu': () => menu().popup({ window: win })
    })) ipcMain.on(channel, (event, ...args) => {
      if (event.sender === win.webContents && event.senderFrame === win.webContents.mainFrame) handler(event, ...args);
    });
    screen.on('display-removed', repositionPet);
    screen.on('display-metrics-changed', repositionPet);
    win.on('show', () => publish(false, true)); win.on('hide', () => publish(false, false));
    win.on('blur', () => { if (drag) { drag = null; resetMotion(); } });
    win.on('close', savePosition);
    await win.loadFile(path.join(__dirname, 'index.html'));
    win.showInactive(); publish(false);
    if (smoke) {
      win.webContents.debugger.attach('1.3');
      const setReducedMotion = reduce => win.webContents.debugger.sendCommand('Emulation.setEmulatedMedia', {
        features: [{ name: 'prefers-reduced-motion', value: reduce ? 'reduce' : 'no-preference' }]
      });
      await require('./smoke.cjs')({ win, app, action, change, settings, hidePet, showPet, motion, screen, setReducedMotion });
      return;
    }
    tray = new Tray(path.join(__dirname, '../assets/tray.png')); tray.setToolTip('Evan');
    tray.on('click', showPet); tray.on('right-click', () => tray.setContextMenu(menu()));
    tray.setContextMenu(menu());
  }).catch(error => { console.error(error); app.exit(1); });
}
app.on('window-all-closed', () => app.quit());
