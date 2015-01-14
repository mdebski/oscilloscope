#!/usr/bin/env python

import sys
import signal
import Tkinter

from primitives import *

def main():
 M = Bunch(t=20, l=10, r=10, b=10)
 width=640
 height=480

 C = Bunch(bg=0, border=8, graph=12)

 palette = Palette("4bit-RGBI.gpl")

 d = collections.OrderedDict()
 image = Canvas(width=width, height=height, palette = palette, widgetMap = d)

 # Image

 #d[(320, 240)] = Constant(20, 20, 5)
 #d[(320, 260)] = Constant(20, 20, 6)
 #d[(320, 280)] = Constant(20, 20, 7)
 #d[(320, 300)] = Constant(20, 20, 8)
 #d[(320, 320)] = Constant(20, 20, 9)
 #d[(340, 240)] = Constant(20, 20, 10)
 #d[(340, 260)] = Constant(20, 20, 11)
 #d[(340, 280)] = Constant(20, 20, 12)
 #d[(340, 300)] = Constant(20, 20, 13)
 #d[(340, 320)] = Constant(20, 20, 14)
 #d[(320, 350)] = Sprite("ledon")
 #d[(340, 350)] = Sprite("ledoff")
 #d[(320-16, 240-16)] = Sprite("test")

 for i in xrange(8):
  d[(width - M.r - 30 - 500, M.t + i*50)] = Constant(500, 40, C.border)
  d[(width - M.r - 30 - 500 + 2, M.t + i*50 + 2)] = Constant(500-4 , 40-4, C.bg)
 # d[(width - M.r - 30 - 500 + 4, M.t + i*50 + 4)] = RandomGraph(500-8 , 40-8, C.graph)
  d[(width - M.r - 30 + 4 + 6, M.t + i*50 + 2 + 11)] = Led(i) # Sprite("led" + ("on" if (i%2) else "off"))

 d[(width - M.r -30 - 48, M.t + 405)] = Sprite("f")
 d[(width - M.r -30 - 32, M.t + 405)] = Digit("d1")
 d[(width - M.r -30 - 24, M.t + 405)] = Digit("d2")
 d[(width - M.r -30 - 16, M.t + 405)] = Digit("d3")
 d[(width - M.r -30 - 8,  M.t + 405)] = Digit("d4")
 d[(width - M.r -30 + 3,  M.t + 405)] = Sprite("MHz")

 # End of Image

 image.widgetMap = d
 image.buildMemory()
 image.writeCoe("video_rom.coe")
 palette.writeVhdl("palette.vhd")
 image.writeVhdl("addr_logic.vhd")
 print "Used memory: %d words" % len(image.memory)
 image.show()


main()
