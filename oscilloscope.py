#!/usr/bin/env python

import sys
import signal
import Tkinter

from primitives import *

M = Bunch(t=20, l=10, r=10, b=10)
width=640
height=480

C = Bunch(bg=0, border=8)

palette = importPalette("4bit-RGBI.gpl")

d = collections.OrderedDict()

# Image

d[(0, 0)] = Constant(640, 480, C.bg)
for i in xrange(8):
 d[(width - M.r - 30 - 500, M.t + i*50)] = Constant(500, 40, C.border)
 d[(width - M.r - 30 - 500 + 2, M.t + i*50 + 2)] = Constant(500-4 , 40-4, C.bg)
 d[(width - M.r - 30 + 4 + 6, M.t + i*50 + 2 + 11)] = Sprite("led" + ("on" if (i%2) else "off"))

# End of Image

image = Canvas(width=width, height=height, palette = palette, widgetMap = d)
image.show()
