# Render a mockup headlessly, crop the empty tail, and cut viewing slices (slices go to a scratch dir, the full render to design/renders/).
import subprocess, sys, os
from PIL import Image
Image.MAX_IMAGE_PIXELS = None
CH = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
HERE = os.path.dirname(os.path.abspath(__file__))
name = sys.argv[1]; scratch = sys.argv[2]
src = os.path.abspath(os.path.join(HERE, '..', name + '.html'))
out = os.path.abspath(os.path.join(HERE, '..', '..', 'renders', 'mockup-' + name + '.png'))
subprocess.run([CH, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=2200,' + (sys.argv[3] if len(sys.argv) > 3 else '15500'), '--screenshot=' + out, 'file://' + src],
               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
im = Image.open(out).convert('RGB')
w, h = im.size
bg = im.getpixel((5, h - 5))
px = im.load()
y = h - 1
while y > 0 and all(px[x, y] == bg for x in range(0, w, 7)):
    y -= 1
im = im.crop((0, 0, w, min(h, y + 60)))
im.save(out)
print(out, im.size)
# slices: find h2 rules (2px dark line at x=40..) -> cut per section
ys = [0]
for yy in range(1, im.size[1] - 1):
    r = px[40, yy]
    if r[0] < 60 and r[1] < 60 and r[2] < 60 and px[900, yy][0] < 60 and px[1500, yy][0] < 60 and px[40, yy - 1][0] > 200:
        ys.append(yy - 10)
ys.append(im.size[1])
for i in range(len(ys) - 1):
    seg = im.crop((0, ys[i], w, ys[i + 1]))
    # further split tall sections into ~1100px pieces
    n = max(1, round(seg.size[1] / 1150))
    step = seg.size[1] // n
    for k in range(n):
        part = seg.crop((0, k * step, w, seg.size[1] if k == n - 1 else (k + 1) * step))
        p = os.path.join(scratch, '%s-%02d-%d.png' % (name, i, k))
        part.save(p)
        print(p, part.size)
