const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { SIZE } = require('./position.cjs');
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
module.exports = async ({ win, app, action, change, settings, hidePet, showPet, motion, screen }) => {
  const evaluate = code => win.webContents.executeJavaScript(code);
  const snapshot = () => evaluate('window.petDiagnostics.snapshot()');
  try {
    for (let i = 0; i < 150; i++) {
      const ready = await evaluate("document.querySelector('#pet').dataset.ready === 'true'");
      if (ready) break;
      const error = await evaluate("document.querySelector('#pet').dataset.error");
      if (error) throw new Error(error);
      await delay(100);
    }
    const first = await snapshot(); assert.equal(first.sheets, 6);
    assert.deepEqual(win.getSize(), [SIZE.width, SIZE.height]);
    assert.deepEqual(await evaluate(`(() => {
      const rect = document.querySelector('#pet').getBoundingClientRect();
      return [rect.width, rect.height];
    })()`), [192, 208]);
    assert.deepEqual(first.cells, { base: 1, walk: 8, expressions: 8, activities: 12, gong: 4, skullStaff: 4 });
    const shape = await evaluate(`(async () => {
      const { SpritePlayer } = await import('./sprites.mjs');
      const probe = document.createElement('canvas'); probe.style.width = '192px';
      probe.style.position = 'absolute'; probe.style.left = '-1000px'; document.body.appendChild(probe);
      const p = new SpritePlayer(probe); await p.load();
      const base = p.sheets.get('base').image.getContext('2d');
      const alpha = (x, y) => base.getImageData(x, y, 1, 1).data[3];
      const result = { legs: p.walkLayers.legs.length,
        wings: p.walkLayers.wings.length,
        extraTabs: [alpha(522, 1310), alpha(598, 1310)],
        originalLegs: [alpha(490, 1260), alpha(638, 1250)] };
      const { drawWalk } = await import('./walk-rig.mjs');
      const check = document.createElement('canvas'); check.width = 240; check.height = 260;
      const ctx = check.getContext('2d', { willReadFrequently: true });
      const s = p.sheets.get('base'), rect = s.cells[0];
      const render = clock => {
        ctx.clearRect(0, 0, 240, 260); ctx.save(); ctx.translate(120, 250);
        drawWalk(ctx, p.walkLayers, rect.width * s.scale, rect.height * s.scale, 0, 0, clock); ctx.restore();
        return ctx.getImageData(0, 0, 240, 260).data;
      };
      const a = render(0), b = render(.9); let changed = 0, protectedChanged = 0;
      for (let y = 0; y < 260; y++) for (let x = 0; x < 240; x++) {
        const i = (y * 240 + x) * 4;
        if (![0, 1, 2, 3].some(c => a[i+c] !== b[i+c])) continue;
        changed++;
        if (y < 210 || (x >= 100 && x <= 140)) protectedChanged++;
      }
      result.wingPixelsChanged = changed; result.protectedPixelsChanged = protectedChanged;
      probe.remove(); return result;
    })()`);
    assert.equal(shape.legs, 2); assert.deepEqual(shape.extraTabs, [0, 0]);
    assert.ok(shape.originalLegs.every(alpha => alpha > 128));
    assert.equal(shape.wings, 2); assert.ok(shape.wingPixelsChanged > 0);
    assert.equal(shape.protectedPixelsChanged, 0);
    await delay(300); assert.ok((await snapshot()).frames > first.frames);
    assert.equal(await evaluate('typeof require'), 'undefined'); assert.ok(win.isAlwaysOnTop());
    const captureDir = path.join(app.getPath('temp'), 'evan-motion-smoke'); fs.mkdirSync(captureDir, { recursive: true });
    for (const name of first.clips) {
      action(name); await delay(180); assert.equal((await snapshot()).state, name);
      fs.writeFileSync(path.join(captureDir, `${name}.png`), (await win.webContents.capturePage()).toPNG());
    }
    action('idle');
    await evaluate("document.querySelector('#pet').click()"); await delay(100);
    assert.equal(await evaluate("document.querySelector('#bubble').hidden"), false);
    change({ paused: true }); await delay(100); const paused = await snapshot(); await delay(200);
    assert.equal((await snapshot()).frames, paused.frames);
    change({ paused: false }); await delay(150); assert.ok((await snapshot()).frames > paused.frames);
    hidePet(); await delay(100); const hidden = await snapshot(); await delay(200);
    assert.equal((await snapshot()).visible, false);
    assert.equal((await snapshot()).clock, hidden.clock); showPet(); await delay(150);
    change({ resting: true }); await delay(2800); assert.equal((await snapshot()).state, 'sleep');
    change({ resting: false }); action('walk'); const before = win.getPosition(); await delay(650);
    const after = win.getPosition();
    if (!(await snapshot()).reduced) assert.notEqual(after[0], before[0]);
    change({ roaming: false }); await delay(100); const stationary = win.getPosition(); await delay(250);
    assert.deepEqual(win.getPosition(), stationary);
    change({ roaming: true }); action('idle');
    // Sample real native movement and fractional compensation while the renderer owns the frame clock.
    action('walk'); await delay(650);
    const samples = await evaluate(`new Promise(resolve => {
      const samples = []; const sample = () => {
        samples.push(window.petDiagnostics.snapshot());
        if (samples.length === 60) resolve(samples); else requestAnimationFrame(sample);
      }; requestAnimationFrame(sample);
    })`);
    assert.ok(samples.some(s => Math.abs(s.motion.offsetX) > .01));
    for (let i = 1; i < samples.length; i++) {
      assert.ok(Math.abs(samples[i].motion.x - samples[i-1].motion.x) <= 2.41);
      assert.ok(Math.abs(samples[i].motion.offsetX) <= .5);
    }
    win.webContents.sendInputEvent({ type: 'mouseDown', x: 130, y: 180, button: 'left', clickCount: 1 });
    await delay(150); const heldPosition = win.getPosition();
    assert.equal((await snapshot()).motion.speed, 0); assert.equal((await snapshot()).motion.offsetX, 0);
    await delay(150); assert.deepEqual(win.getPosition(), heldPosition);
    win.webContents.sendInputEvent({ type: 'mouseUp', x: 130, y: 180, button: 'left', clickCount: 1 });
    await delay(100); action('walk'); await delay(150);
    change({ paused: true }); await delay(100);
    const frozen = await evaluate("document.querySelector('#sprite').toDataURL()");
    const frozenPosition = win.getPosition(); await delay(200);
    assert.equal(await evaluate("document.querySelector('#sprite').toDataURL()"), frozen);
    assert.deepEqual(win.getPosition(), frozenPosition);
    change({ paused: false });
    const area = screen.getDisplayMatching(win.getBounds()).workArea;
    win.setPosition(area.x + Math.max(0, area.width - SIZE.width) - 1, win.getPosition()[1]);
    motion.direction = 1; motion.reset(win.getPosition()[0]); action('walk');
    await delay(200); change({ roaming: false, resting: true }); await delay(100);
    assert.equal((await snapshot()).motion.turning, false);
    assert.notEqual((await snapshot()).renderState, 'walk');
    change({ roaming: true, resting: false });
    win.setPosition(area.x + Math.max(0, area.width - SIZE.width) - 1, win.getPosition()[1]);
    motion.direction = 1; motion.reset(win.getPosition()[0]); action('walk');
    await delay(1000); assert.equal((await snapshot()).motion.direction, -1);
    assert.ok(win.getPosition()[0] <= area.x + area.width - SIZE.width);
    console.log('Movement timing:', JSON.stringify({ frameP95Ms: samples.at(-1).frameP95Ms, renderP95Ms: samples.at(-1).renderP95Ms }));
    if (process.argv.includes('--record-wings')) {
      const frames = await evaluate(`(async () => {
        const { SpritePlayer } = await import('./sprites.mjs');
        const probe = document.createElement('canvas'); probe.style.width = '192px';
        probe.style.position = 'absolute'; probe.style.left = '-1000px'; document.body.appendChild(probe);
        const p = new SpritePlayer(probe); await p.load();
        const out = document.createElement('canvas'); out.width = 208; out.height = 256;
        const ctx = out.getContext('2d'), frames = [];
        for (let i = 0; i < 108; i++) {
          p.draw('idle', 0, i/30, 1, false, { phase: 0, strength: 0, offsetX: 0 });
          ctx.fillStyle = '#e5eaed'; ctx.fillRect(0, 0, 208, 256); ctx.drawImage(probe, 8, 48, 192, 208);
          frames.push(out.toDataURL('image/png').split(',')[1]);
        }
        probe.remove(); return frames;
      })()`);
      const dir = path.join(app.getPath('temp'), 'evan-wings-preview'); fs.mkdirSync(dir, { recursive: true });
      frames.forEach((data, i) => fs.writeFileSync(path.join(dir, String(i).padStart(4, '0') + '.png'), Buffer.from(data, 'base64')));
      console.log('Wing preview:', dir);
    }
    if (process.argv.includes('--record-roaming')) {
      const dir = path.join(app.getPath('temp'), 'evan-roaming-preview'); fs.mkdirSync(dir, { recursive: true });
      win.setPosition(area.x + Math.min(600, Math.max(0, area.width - SIZE.width - 30)), win.getPosition()[1]);
      motion.direction = -1; motion.reset(win.getPosition()[0]); action('walk');
      const origin = win.getPosition()[0], began = performance.now();
      for (let i = 0; i < 240; i++) {
        await delay(Math.max(0, began + i * 1000/30 - performance.now()));
        const data = await evaluate(`(() => {
          const c = document.createElement('canvas'); c.width = 720; c.height = 340;
          const ctx = c.getContext('2d'); ctx.fillStyle = '#e5eaed'; ctx.fillRect(0, 0, 720, 340);
          const x = window.petDiagnostics.snapshot().motion.x;
          const sprite = document.querySelector('#sprite');
          ctx.drawImage(sprite, 480 + Math.round(x) - ${origin}, 320 - sprite.clientHeight, sprite.clientWidth, sprite.clientHeight);
          return c.toDataURL('image/png').split(',')[1];
        })()`);
        fs.writeFileSync(path.join(dir, `${String(i).padStart(4, '0')}.png`), Buffer.from(data, 'base64'));
      }
      console.log('Roaming preview:', dir);
    }
    if (process.argv.includes('--record-preview') || process.argv.includes('--record-props')) {
      const propsOnly = process.argv.includes('--record-props');
      const framesDir = path.join(app.getPath('temp'), propsOnly ? 'evan-props-preview' : 'evan-motion-preview'); fs.mkdirSync(framesDir, { recursive: true });
      let frame = 0;
      for (const name of propsOnly ? ['gong', 'skullStaff'] : ['idle', 'blink', 'walk', 'wave', 'sit', 'sleep', 'stretch', 'hop', 'float', 'turn', 'sign', 'tilt', 'gong', 'skullStaff']) {
        action(name);
        for (let i = 0; i < (propsOnly ? 36 : 18); i++) {
          await delay(1000 / 12);
          fs.writeFileSync(path.join(framesDir, `${String(frame++).padStart(4, '0')}.png`), (await win.webContents.capturePage()).toPNG());
        }
      }
      console.log('Preview frames:', framesDir);
    }
    console.log('Evan motion smoke passed:', JSON.stringify({ clips: first.clips.length, cells: first.cells, captures: captureDir, reduced: first.reduced }));
    app.exit(0);
  } catch (error) { console.error(error); app.exit(1); }
};
