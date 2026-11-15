# Render a mockup headlessly to design/renders/mockup-<name>.png, crop the empty tail, and write a half-size overview to a scratch dir.
import subprocess, sys, os
from PIL import Image
Image.MAX_IMAGE_PIXELS = None
CH = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
HERE = os.path.dirname(os.path.abspath(__file__))
name, scratch = sys.argv[1], sys.argv[2]
src = os.path.abspath(os.path.join(HERE, '..', name + '.html'))
out = os.path.abspath(os.path.join(HERE, '..', '..', 'renders', 'mockup-' + name + '.png'))
subprocess.run([CH, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=2200,16000', '--screenshot=' + out, 'file://' + src],
               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
im = Image.open(out).convert('RGB')
w, h = im.size
px = im.load()
bg = px[5, h - 5]
y = h - 1
while y > 0 and all(px[x, y] == bg for x in range(0, w, 7)):
    y -= 1
full = y >= h - 2
im = im.crop((0, 0, w, min(h, y + 60)))
im.save(out)
print(out, im.size, 'TRUNCATED?' if full else '')
n = max(1, round(im.size[1] / 2600))
step = im.size[1] // n
for k in range(n):
    part = im.crop((0, k * step, w, im.size[1] if k == n - 1 else (k + 1) * step))
    part = part.resize((part.size[0] // 2, part.size[1] // 2))
    p = os.path.join(scratch, 'ov-%s-%d.png' % (name, k)); part.save(p); print(p, part.size)
