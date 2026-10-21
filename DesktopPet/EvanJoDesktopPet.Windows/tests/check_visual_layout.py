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
def offsets(name):
    block = controller.split(name + ' =', 1)[1].split('};', 1)[0]
    return [(float(x), float(y)) for x, y in re.findall(r'new\((-?[\d.]+), (-?[\d.]+)\)', block)]
midpoints, endpoints = offsets('FlowerMidpointOffsets'), offsets('FlowerFinalOffsets')
assert len(midpoints) == len(endpoints) == 7
for i in range(1, 8):
    element = happy_layers[f'Flower{i:02}Image']
    left, top, right, bottom = bounds(element, ASSETS / f'Happy/Animation/Flowers/flower_{i:02}.png')
    for dx, dy in [(0, 0), midpoints[i - 1], endpoints[i - 1]]:
        assert 0 <= left + dx < right + dx <= width, (i, 'horizontal clipping')
        assert 0 <= top + dy < bottom + dy <= height, (i, 'vertical clipping')
    if i in (1, 2, 4, 6):
        assert min(right - left, bottom - top) >= 22, (i, 'flower is too small')

# Required layers must be independently decodable and present in the resource glob.
for pose, names in {'Loading': ['Body', 'Text', 'Spinner'],
                    'Thinking': ['Body', 'Glasses', 'Bubble', 'Dot1', 'Dot2', 'Dot3', 'Leaf'],
                    'Sleepy': ['BodyBack', 'HandFront', 'Glasses', 'GlassesReflection', 'BlueMist', 'YellowSparkle']}.items():
    for name in names:
        with Image.open(ASSETS / pose / 'Animation' / (name + '.png')) as image:
            assert image.mode == 'RGBA'
            image.verify()
print(f'PASS: Idle/Happy heights and feet {measurements}; all 7 flower paths fit {width:g}x{height:g}; 16 new layers valid.')
