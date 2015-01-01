import os
import re
import textwrap
import itertools
import collections

import Tkinter as tk
from PIL import Image, ImageTk

def Bin(n, l):
 return bin(n)[2:].rjust(l, '0')

class Bunch:
 def __init__(self, **kwds):
  self.__dict__.update(kwds)

class Palette(object):
 def __init__(self, filename):
  self.palette = []
  self.raw_palette = []
  with open(filename, 'r') as f:
   l = f.readline().strip()
   if l != "GIMP Palette":
    raise ValueError("Invalid header")
   for l in f.readlines():
    l = re.sub(r'([^#]*)#.*$', r'\1', l)
    l = l.strip()
    if not l:
     continue
    m = re.match(r'^\s*(\d+)\s+(\d+)\s+(\d+)\s*$', l)
    if not m:
     #raise ValueError("Unexpected line: " + l)
     continue
    t = (int(m.group(1)), int(m.group(2)), int(m.group(3)))
    self.raw_palette.append(t)
    self.palette.append("#%02x%02x%02x" % t)

 def __getitem__(self, index):
  return self.palette[index]

 def generate(self):
  boilerplate = textwrap.dedent("""\
   library IEEE;
   use IEEE.STD_LOGIC_1164.ALL;

   entity palette is
    port(
     color_4bit: in std_logic_vector(3 downto 0);
     color_8bit: out std_logic_vector(7 downto 0)
    );
   end palette;

   architecture Behavioral of palette is
   begin
    with color_4bit select color_8bit <=
    %s
   end Behavioral;
  """)
  case = ""
  for i, val in enumerate(self.raw_palette):
   case += ''' X"%02x" when X"%x",\n ''' % (self.to8bit(val), i)
  case += ''' X"00" when others;'''

  return boilerplate % case

 def to8bit(self, val):
  def roundBits(val, n):
   assert (n==2) or (n==3)
   vals = {}
   vals[3] = [0, 36, 73, 109, 146, 182, 219, 255]
   vals[2] = [0, 85, 170, 255]
   if val not in vals[n]:
    print "Warning: not exact rounding of %d" % val
   rounded = int(round((float(val) / 255.0) * float(2**n-1)))
   return Bin(rounded, n)

  r, g, b = val
  r = roundBits(r, 3)
  g = roundBits(g, 3)
  b = roundBits(b, 2)
  return int(r + g + b, 2)


 def writeVhdl(self, filename):
  with open(filename, 'w') as f:
   f.write(self.generate())


class Canvas(object):
 def __init__(self, width, height, palette, widgetMap):
  self.root = tk.Tk()
  def ping():
   self.root.after(50, ping)
  ping()
  self.canvas = tk.Canvas(self.root, width=width, height=height)
  self.canvas.pack()
  self.palette = palette
  self.widgetMap = widgetMap
  self.memory = []
  self.offset = 0

 def show(self):
  for pos, widget in self.widgetMap.iteritems():
   print "Drawing: %s at %s" % (str(widget), str(pos))
   item = widget.draw(self.canvas, self.palette)
   self.canvas.move(item, pos[0], pos[1])
  self.root.mainloop()

 def generate(self, hpos, vpos):
  gen = ''
  for pos, widget in reversed(list(self.widgetMap.iteritems())):
   gen += textwrap.dedent("""
    elsif((%s > %d) and (%s > %d) and (%s < %d) and (%s < %d) then
   """) % (hpos, pos[0], vpos, pos[1], hpos, widget.w, vpos, widget.h)
   gen += " " + widget.generate('(%s-%d)' % (hpos, pos[0]), '(%s-%d)' % (vpos, pos[1]))
  gen = gen[4:] + textwrap.dedent("""
   end if;
  """)
  return gen

 def memPush(self, n):
  self.memory.append(Bin(n, 4))
  self.offset += 1

 def buildMemory(self):
  for i in xrange(16):
   self.memPush(i)
  widgets_to_offsets = {}
  for w in self.widgetMap.itervalues():
   a = w.serialize()
   if(a):
    if w.key not in widgets_to_offsets:
     widgets_to_offsets[w.key] = self.offset
     for v in a:
      self.memPush(v)
    w.offset = widgets_to_offsets[w.key]

 def writeCoe(self, filename):
  with open(filename, 'w') as f:
   f.write(textwrap.dedent("""\
    memory_initialization_radix=2;
    memory_initialization_vector=
   """))
   for word, i in itertools.izip(self.memory, xrange(len(self.memory))):
    f.write(word)
    f.write(";" if i == len(self.memory)-1 else ",\n")



class Widget(object):
 def __init__(self, *args, **kwargs):
  self.args = args
  self.kwargs = kwargs

 def draw(self, canvas, palette):
  raise NotImplementedError

 def serialize(self):
  return []


class Constant(Widget):
 def __init__(self, *args, **kwargs):
  super(Constant, self).__init__(*args, **kwargs)
  a = self.args
  self.w = self.args[0]
  self.h = self.args[1]
  self.c = self.args[2]

 def draw(self, canvas, palette):
  return canvas.create_rectangle(0, 0, self.w, self.h, fill=palette[self.c])

 def generate(self, hpos, vpos):
  return '''X"%x"''' % self.c

 def __str__(self):
  a = self.args
  return "Constant %d W: %d, H: %d" % (a[2], a[0], a[1])

class Sprite(Widget):
 def __init__(self, *args, **kwargs):
  super(Sprite, self).__init__(*args, **kwargs)
  name = self.args[0]
  self.key = name
  self._image = Image.open("sprites/" + name + ".png")
  self.image = ImageTk.PhotoImage(self._image)
  self.w = self.image.width()
  self.h = self.image.height()
  self.offset = None

 def draw(self, canvas, palette):
  return canvas.create_image(self.image.width()/2, self.image.height()/2, image=self.image)

 def generate(self, hpos, vpos):
  assert self.offset is not None, "Run buildMemory first!"
  return '''%s slr 6 + %s + %d''' % (hpos, vpos, self.offset)

 def serialize(self):
  return [ord(x) for x in self._image.tobytes()]

 def __str__(self):
  return "Sprite " + self.args[0]
