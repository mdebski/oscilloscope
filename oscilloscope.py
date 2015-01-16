#!/usr/bin/env python

import sys
import signal
import Tkinter

from primitives import *

def main():
 M = Bunch(t=20, l=10, r=10, b=10)
 width=640
 height=480

 C = Bunch(bg=0, border=8, graph=12, line=14)

 palette = Palette("4bit-RGBI.gpl")

 d = collections.OrderedDict()
 image = Canvas(width=width, height=height, palette = palette, widgetMap = d)

 # Image

 for i in xrange(8):
  d[(width - M.r - 30 - 518, M.t + i*50)] = Constant(518, 40, C.border)
  d[(width - M.r - 30 - 518 + 2, M.t + i*50 + 2)] = Constant(514 , 40-4, C.bg)
  d[(width - M.r - 30 - 518 + 3, M.t + i*50 + 4)] = Graph(512, i, True, C.graph)
  d[(width - M.r - 30 - 518 + 3, M.t + i*50 + 34)] = Graph(512, i, False, C.graph)
  d[(width - M.r - 30 + 4 + 5, M.t + i*50 + 12)] = Select(["toggle(%d) = '1'" % i], ["ledon", "ledoff"])

 d[(width - M.r -30 -24 - 48, M.t + 405)] = Sprite("f")
 d[(width - M.r -30 -24 - 32, M.t + 405)] = Digit("freq_digits(3)")
 d[(width - M.r -30 -24 - 24, M.t + 405)] = Digit("freq_digits(2)")
 d[(width - M.r -30 -24 - 16, M.t + 405)] = Digit("freq_digits(1)")
 d[(width - M.r -30 -24 - 8,  M.t + 405)] = Digit("freq_digits(0)")

 d[(width - M.r -30 -24 - 32 + 6,  M.t + 412)] = Select(["prescale = 1 or prescale = 4 or prescale = 7"], ["comma", "nocomma"])
 d[(width - M.r -30 -24 - 24 + 6,  M.t + 412)] = Select(["prescale = 0 or prescale = 3 or prescale = 6"], ["comma", "nocomma"])
 d[(width - M.r -30 -24 - 16 + 6,  M.t + 412)] = Select(["prescale = 2 or prescale = 5"], ["comma", "nocomma"])

 d[(width - M.r -30 -24 + 3,  M.t + 405)] = Select(["prescale <= 1", "prescale <= 4"], ["MHz", "kHz", "Hz"])

 d[(width - M.r -30 + 9,  M.t + 405 - 4)] = Select(["state=EVERY", "state=ONCE", "state=ONCE_PROBING"], ["every", "once", "once-probing", "once-done"])

 d[("line_pos", 0)] = Constant(2,480,C.line)

 # End of Image

 image.widgetMap = d
 image.buildMemory()
 image.writeCoe("video_rom.coe")
 palette.writeVhdl("palette.vhd")
 image.writeVhdl("renderer.vhd")
 print "Used memory: %d words" % len(image.memory)
 image.show()


main()
