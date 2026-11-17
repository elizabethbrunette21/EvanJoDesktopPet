// These are the original rounded legs beside the hanging black garment, not separate feet.
// Source-pixel contours belong to the versioned 1118×1407 idle-v2.png.
export const LEG_PARTS = [
  { pivot: [490, 1225], contour: [[487,1220],[475,1226],[468,1236],[463,1253],[463,1274],[469,1290],[484,1302],[515,1303],[520,1285],[516,1263],[511,1245],[506,1225]] },
  { pivot: [638, 1190], contour: [[635,1178],[650,1190],[660,1208],[668,1234],[670,1253],[665,1274],[651,1291],[631,1301],[613,1301],[608,1280],[612,1250],[612,1221],[617,1195],[624,1184]] }
];
// Only the exposed lower fans move; upper roots, hair and bead chains stay in front.
export const WING_PARTS = [
  { pivot: [330,1208], contour: [[159,1210],[185,1213],[210,1220],[239,1222],[265,1221],[292,1214],[320,1215],[350,1213],[380,1213],[409,1212],[438,1210],[456,1208],[456,1220],[438,1242],[410,1260],[375,1278],[335,1290],[290,1301],[245,1305],[207,1299],[178,1286],[162,1266],[155,1240]] },
  { pivot: [796,1208], contour: [[694,1209],[720,1214],[748,1216],[776,1212],[804,1211],[832,1210],[860,1214],[887,1212],[915,1212],[943,1212],[970,1215],[977,1238],[976,1258],[969,1277],[954,1292],[930,1302],[900,1305],[867,1300],[832,1291],[797,1277],[763,1263],[731,1246],[705,1227]] }
];
// Remove the extra sole/toe tabs introduced by the earlier generated art. Source files stay intact.
// Seated and floating poses retain their original whole rounded legs.
export const EXTRA_TABS = {
  base: [[484,1303,76,26],[562,1303,74,26]],
  expressions: Array.from({ length: 8 }, (_, i) => [165 + i%4*384, 444 + Math.floor(i/4)*512, 62, 15]),
  activities: [[150,682,28,17],[184,682,28,17],[504,680,28,19],[543,680,28,19],
    [499,1052,28,15],[529,1052,31,15],[869,1048,29,19],[901,1048,29,19],[1228,1047,30,20],[1260,1047,29,20]],
  gong: [[263,566,88,20],[868,566,88,20],[263,1214,88,20],[868,1214,88,20]],
  skullStaff: [[300,538,65,20],[859,538,66,20],[300,1167,65,20],[856,1167,66,20]]
};
export function makeWalkLayers(image, rect) {
  const body = document.createElement('canvas'); body.width = rect.width; body.height = rect.height;
  const context = body.getContext('2d');
  context.drawImage(image, rect.x, rect.y, rect.width, rect.height, 0, 0, rect.width, rect.height);
  const extract = parts => parts.map(part => {
    const left = Math.min(...part.contour.map(p => p[0])), top = Math.min(...part.contour.map(p => p[1]));
    const width = Math.max(...part.contour.map(p => p[0])) - left + 1, height = Math.max(...part.contour.map(p => p[1])) - top + 1;
    const mask = document.createElement('canvas'); mask.width = width; mask.height = height;
    const m = mask.getContext('2d'); m.beginPath();
    part.contour.forEach(([x, y], i) => { if (i === 0) m.moveTo(x - left, y - top); else m.lineTo(x - left, y - top); });
    m.closePath(); m.fill();
    const layer = document.createElement('canvas'); layer.width = width; layer.height = height;
    const c = layer.getContext('2d'); c.drawImage(image, left, top, width, height, 0, 0, width, height);
    c.globalCompositeOperation = 'destination-in'; c.drawImage(mask, 0, 0);
    // Keep the top attachment covered by the original foreground, with each visible part drawn once.
    context.save(); context.beginPath(); context.rect(0, top - rect.y + 12, body.width, body.height); context.clip();
    context.globalCompositeOperation = 'destination-out'; context.drawImage(mask, left - rect.x, top - rect.y); context.restore();
    return { image: layer, x: left - rect.x, y: top - rect.y, pivotX: part.pivot[0] - left, pivotY: part.pivot[1] - top };
  });
  return { body, legs: extract(LEG_PARTS), wings: extract(WING_PARTS) };
}
export function legPose(phase, side, strength) {
  const swing = Math.sin(phase + (side === 0 ? 0 : Math.PI));
  const amount = Math.max(0, Math.min(1, strength));
  return { y: -Math.max(0, swing) * .3 * amount, angle: swing * .025 * amount };
}
export function wingPose(clock, side) {
  return Math.sin(clock * Math.PI * 2 / 3.6) * .012 * (side === 0 ? 1 : -1);
}
export function drawWalk(ctx, layers, width, height, phase, strength, clock = 0) {
  const scale = width / layers.body.width;
  (layers.wings || []).forEach((wing, side) => {
    ctx.save();
    ctx.translate(-width/2 + (wing.x + wing.pivotX) * scale, -height + (wing.y + wing.pivotY) * scale);
    ctx.rotate(wingPose(clock, side));
    ctx.drawImage(wing.image, -wing.pivotX * scale, -wing.pivotY * scale, wing.image.width * scale, wing.image.height * scale);
    ctx.restore();
  });
  layers.legs.forEach((leg, side) => {
    const pose = legPose(phase, side, strength);
    ctx.save();
    ctx.translate(-width/2 + (leg.x + leg.pivotX) * scale, -height + (leg.y + leg.pivotY) * scale + pose.y);
    ctx.rotate(pose.angle);
    ctx.drawImage(leg.image, -leg.pivotX * scale, -leg.pivotY * scale, leg.image.width * scale, leg.image.height * scale);
    ctx.restore();
  });
  ctx.drawImage(layers.body, -width/2, -height, width, height);
}
