"""Asset-aware regression check. Run with Python 3 + Pillow; no Windows UI needed."""
from pathlib import Path
import re
import xml.etree.ElementTree as ET
from PIL import Image

ROOT = Path(__file__).resolve().parents[1] / 'src/EvanJoDesktopPet.Windows'
ANIMATION = ROOT / 'Characters/EvanJo/Animation'
ASSETS = ROOT / 'Resources/Characters/EvanJo'
NS = {'w': 'http://schemas.microsoft.com/winfx/2006/xaml/presentation'}
NAME = '{http://schemas.microsoft.com/winfx/2006/xaml}Name'


def images(filename):
    doc = ET.parse(ANIMATION / filename)
    return doc.getroot(), {el.get(NAME): el for el in doc.findall('.//w:Image', NS)}


def bounds(element, path):
    with Image.open(path) as image:
        box = image.getchannel('A').point(lambda a: 255 if a > 16 else 0).getbbox()
        assert box, f'Empty layer: {path}'
        sx, sy = float(element.get('Width')) / image.width, float(element.get('Height')) / image.height
    if element.get('Stretch') == 'Uniform':
        sx = sy = min(sx, sy)
    left, top = float(element.get('Canvas.Left')), float(element.get('Canvas.Top'))
    return left + box[0] * sx, top + box[1] * sy, left + box[2] * sx, top + box[3] * sy


def character_height(layers, pose, offset_y=0):
    boxes = [bounds(layers[name + 'Image'], ASSETS / f'{pose}/Animation/{name}/evan_jo_{pose.lower()}_{name.lower()}.png') for name in ('Head', 'Body')]
    top, bottom = min(b[1] for b in boxes), max(b[3] for b in boxes)
    return bottom - top, bottom + offset_y


idle, idle_layers = images('EvanJoIdleAnimationView.xaml')
happy, happy_layers = images('EvanJoHappyAnimationView.xaml')
pose_view = ET.parse(ROOT / 'Characters/EvanJo/Views/EvanJoPoseView.xaml').getroot()
width, height = float(pose_view.get('Width')), float(pose_view.get('Height'))
assert (float(happy.get('Width')), float(happy.get('Height'))) == (width, height)
idle_view = next(e for e in pose_view.iter() if e.get(NAME) == 'IdleAnimationView')
idle_offset = float(idle_view.get('Margin').split(',')[1])
measurements = [character_height(idle_layers, 'Idle', idle_offset), character_height(happy_layers, 'Happy')]
assert abs(measurements[0][0] - measurements[1][0]) < 0.6, measurements
assert all(abs(bottom - 176) < 0.2 for _, bottom in measurements), measurements

controller = (ANIMATION / 'EvanJoHappyAnimationController.cs').read_text()
view_code = (ANIMATION / 'EvanJoHappyAnimationView.xaml.cs').read_text()
def offsets(name):
    block = controller.split(name + ' =', 1)[1].split('};', 1)[0]
    return [(float(x), float(y)) for x, y in re.findall(r'new\((-?[\d.]+), (-?[\d.]+)\)', block)]
midpoints, endpoints = offsets('FlowerMidpointOffsets'), offsets('FlowerFinalOffsets')
assert len(midpoints) == len(endpoints) == 7
assert 'FlowerSizeScale = 1.8' in controller
assert 'Flowers/evan_jo_happy_flowers.png' in view_code
assert 'Flowers/flower_01.png' not in view_code
mask_rects = [(20.28, 24.96, 20.28, 20.28), (107.64, 18.72, 24.96, 23.4),
              (121.68, 45.24, 14.04, 15.6), (127.92, 74.88, 24.96, 26.52),
              (123.24, 107.64, 18.72, 18.72), (6.24, 81.12, 28.08, 28.08),
              (10.92, 102.96, 18.72, 18.72)]
anchors = [(0.195, 0.225), (0.77, 0.195), (0.825, 0.34), (0.90, 0.565),
           (0.85, 0.75), (0.13, 0.61), (0.13, 0.72)]
with Image.open(ASSETS / 'Happy/Animation/Flowers/evan_jo_happy_flowers.png') as atlas:
    alpha = atlas.getchannel('A').point(lambda a: 255 if a > 16 else 0)
    atlas_width, atlas_height = atlas.size
for i in range(1, 8):
    element = happy_layers[f'Flower{i:02}Image']
    assert float(element.get('Width')) == float(element.get('Height')) == 156
    assert (float(element.get('Canvas.Left')), float(element.get('Canvas.Top'))) == (42, 33.6986)
    assert tuple(map(float, element.get('RenderTransformOrigin').split(','))) == anchors[i - 1]
    clip = element.find('w:Image.Clip/w:RectangleGeometry', NS)
    assert clip is not None
    rect = tuple(map(float, clip.get('Rect').split(',')))
    assert rect == mask_rects[i - 1]
    crop = tuple(round(v * atlas_width / 156) for v in
                 (rect[0], rect[1], rect[0] + rect[2], rect[1] + rect[3]))
    local_box = alpha.crop(crop).getbbox()
    assert local_box, (i, 'empty atlas mask')
    box = (crop[0] + local_box[0], crop[1] + local_box[1],
           crop[0] + local_box[2], crop[1] + local_box[3])
    anchor_x = 42 + anchors[i - 1][0] * 156
    anchor_y = 33.6986 + anchors[i - 1][1] * 156
    for scale, dx, dy in [(0.72, 0, 0), (1.8, *midpoints[i - 1]),
                          (1.8, *endpoints[i - 1])]:
        left, right = (anchor_x + scale * (42 + x * 156 / atlas_width - anchor_x) + dx
                       for x in (box[0], box[2]))
        top, bottom = (anchor_y + scale * (33.6986 + y * 156 / atlas_height - anchor_y) + dy
                       for y in (box[1], box[3]))
        assert 0 <= left < right <= width, (i, 'horizontal clipping')
        assert 0 <= top < bottom <= height, (i, 'vertical clipping')
    if i in (1, 2, 4, 6):
        assert min(right - left, bottom - top) >= 26, (i, 'flower is too small')

line = happy_layers['JumpLinesImage']
line_bounds = bounds(line, ASSETS / 'Happy/Animation/JumpLines/evan_jo_happy_jump_lines.png')
assert 12 <= line_bounds[2] - line_bounds[0] <= 16, line_bounds
assert 173 <= line_bounds[1] <= 176 and 180 <= line_bounds[3] <= 183, line_bounds
scene = happy.find('w:Canvas', NS)
assert scene is not None and list(scene)[-1] is line

# Required layers must be independently decodable and present in the resource glob.
for pose, names in {'Loading': ['Body', 'Text', 'Spinner'],
                    'Thinking': ['Body', 'Glasses', 'Bubble', 'Dot1', 'Dot2', 'Dot3', 'Leaf'],
                    'Sleepy': ['BodyBack', 'HandFront', 'Glasses', 'GlassesReflection', 'BlueMist', 'YellowSparkle']}.items():
    for name in names:
        with Image.open(ASSETS / pose / 'Animation' / (name + '.png')) as image:
            assert image.mode == 'RGBA'
            image.verify()
print(f'PASS: Happy atlas masks, flower paths, and jump-line placement {line_bounds}; Idle/Happy feet {measurements}; 16 expression layers valid.')
