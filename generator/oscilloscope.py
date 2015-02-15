#!/usr/bin/env python

import sys
import signal
import Tkinter

from primitives import *

def main():
 M = Bunch(t=20, l=10, r=10, b=10)
 width=640
 height=480

 C = Bunch(bg=0, border=8, graph=12, line=14, select=13, hack=7)

 palette = Palette("4bit-RGBI.gpl")

 d = collections.OrderedDict()
 image = Canvas(width=width, height=height, palette = palette, widgetMap = d, select_color=C.select)

 # Image

 d[(0, 0)] = Constant(5, 1, C.hack, name="Cross TL")
 d[(0, 1)] = Constant(1, 4, C.hack, name="Cross TL")
 d[(width-1, height-6)] = Constant(1, 5, C.hack, name="Cross BR")
 d[(width-6, height-1)] = Constant(5, 1, C.hack, name="Cross BR")

 d[(width - M.r - 30 - 518, M.t)] = Constant(2, 400, C.border, name="Left border")
 d[(width - M.r - 30 - 2, M.t)] = Constant(2, 400, C.border, name="Right border")

 d[(width - M.r - 30 - 518 + 2, M.t)] = Constant(516, 2, C.border, name="Top border")

 for i in xrange(8):
  d[(width - M.r - 30 - 518, M.t + 50 + i*50)] = Constant(518, 2, C.border, name="%d border" % i)
  d[(width - M.r - 30 - 518 + 3, M.t + i*50 + 10)] = Graph(512, i, True, C.graph, name="%d graph top" % i)
  d[(width - M.r - 30 - 518 + 3, M.t + i*50 + 42)] = Graph(512, i, False, C.graph, name="%d graph bottom" % i)
  d[(width - M.r - 30 + 4 + 5, M.t + i*50 + 5 + 13)] = Select(["toggle(%d) = '1'" % i], ["ledon", "ledoff"], name="%d led" % i)

 d[(width - M.r -30 -24 - 48, M.t + 8 + 405)] = Sprite("f", select=0, select_width=12)
 d[(width - M.r -30 -24 - 32, M.t + 8 + 405)] = Digit("freq_digits(3)")
 d[(width - M.r -30 -24 - 24, M.t + 8 + 405)] = Digit("freq_digits(2)")
 d[(width - M.r -30 -24 - 16, M.t + 8 + 405)] = Digit("freq_digits(1)")
 d[(width - M.r -30 -24 - 8,  M.t + 8 + 405)] = Digit("freq_digits(0)")

 d[(width - M.r -30 -24 - 24, M.t + 8 + 417)] = Digit("dist_digits(2)")
 d[(width - M.r -30 -24 - 16, M.t + 8 + 417)] = Digit("dist_digits(1)")
 d[(width - M.r -30 -24 - 8,  M.t + 8 + 417)] = Digit("dist_digits(0)")

 d[(width - M.r -30 -24 - 32 + 6,  M.t + 8 + 412)] = Select(["prescale = 1 or prescale = 4 or prescale = 7"], ["comma", "nocomma"])
 d[(width - M.r -30 -24 - 24 + 6,  M.t + 8 + 412)] = Select(["prescale = 0 or prescale = 3 or prescale = 6"], ["comma", "nocomma"])
 d[(width - M.r -30 -24 - 16 + 6,  M.t + 8 + 412)] = Select(["prescale = 2 or prescale = 5"], ["comma", "nocomma"])

 d[(width - M.r -30 -24 + 3,  M.t + 8 + 405)] = Select(["prescale <= 1", "prescale <= 4"], ["MHz", "kHz", "Hz"], select=1)

 d[(width - M.r -30 + 9,  M.t + 8 + 405 - 4)] = Select(["state=EVERY", "state=ONCE", "state=ONCE_PROBING"], ["every", "once", "once-probing", "once-done"], select=2)

 d[("line_pos", 0)] = Constant(1,480,C.line, select=3, name="Line")
 d[("line2_pos", 0)] = Constant(1,480,C.line, select=4, name="Line2")

 # End of Image

 image.widgetMap = d
 image.buildMemory()
 image.writeCoe("autogen/video_rom.coe")
 palette.writeVhdl("autogen/palette.vhd")
 image.writeVhdl("autogen/renderer.vhd")
 print "Used memory: %d words" % len(image.memory)
 image.show()


main()
