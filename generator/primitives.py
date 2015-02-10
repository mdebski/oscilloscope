import os
import re
import random
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
 def __init__(self, width, height, palette, widgetMap, select_color):
  self.root = tk.Tk()
  self.select_color = select_color
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
  Constant(640, 480, 0).draw(self.canvas, self.palette)
  for pos, widget in self.widgetMap.iteritems():
   items = widget.draw(self.canvas, self.palette)
   for item in items:
     a = pos[0] if isinstance(pos[0], (int, long)) else random.randint(0,640)
     b = pos[1] if isinstance(pos[1], (int, long)) else random.randint(0,480)
     self.canvas.move(item, a, b)
  self.root.mainloop()

 def generate(self, hpos="hcount", vpos="vcount"):
  boilerplate = textwrap.dedent("""\
   library IEEE;
   use IEEE.STD_LOGIC_1164.ALL;
   use IEEE.NUMERIC_STD.ALL;
   use work.common.all;

   entity renderer is
    port(
     hcount, vcount: in unsigned(10 downto 0);
     toggle: in std_logic_vector(7 downto 0);
     freq_digits: in DIGIT_ARRAY(3 downto 0);
     selected: in unsigned(3 downto 0);
     line_pos: in unsigned(10 downto 0);
     line2_pos: in unsigned(10 downto 0);
     state: in STATE_TYPE;
     prescale: in unsigned(2 downto 0);

     output: out std_logic_vector(11 downto 0);
     index: out unsigned(2 downto 0);
     select_mem: out std_logic
    );
   end renderer;

   architecture Behavioral of renderer is
    signal select_x1, select_x2, select_y1, select_y2: unsigned(10 downto 0);
   begin
   %s
   process(hcount, vcount, toggle, line_pos, freq_digits, state, prescale) is begin
    index <= "000";
    %s
   end process; end Behavioral;
  """)
  gen = ''
  gen += textwrap.dedent("""
   elsif (((%s = select_x1) or (%s = select_x2)) and ((%s = select_y1) or (%s = select_y1))) then
     output <= X"%03x"; select_mem <= '0';
  """) % (hpos, vpos, hpos, vpos, self.select_color)
  for pos, widget in reversed(list(self.widgetMap.iteritems())):
   gen += textwrap.dedent("""
    elsif ((%s >= %s) and (%s >= %s) and (%s < %s + %d) and (%s < %s + %d)) then
   """) % (hpos, str(pos[0]), vpos, str(pos[1]), hpos, str(pos[0]), widget.w, vpos, str(pos[1]), widget.h)
   gen += " " + widget.generate('(%s-%s)' % (hpos, str(pos[0])), '(%s-%s)' % (vpos, str(pos[1])))
  gen = gen[4:] + textwrap.dedent("""
   else
    output <= X"000"; select_mem <= '0';
   end if;
  """)
  select = self.formatSelect()
  return boilerplate % (select, gen)

 def formatSelect(self):
  data = collections.defaultdict(dict)
  s = ""
  for ((x,y), w) in self.widgetMap.iteritems():

   def add(p, i):
    if isinstance(p, (int, long)):
     return '''"%s"''' % (Bin(max(p+i, 0), 11))
    if i > 0:
     return "%s + %d" % (p,i)
    if i < 0:
     return "%s - %d" % (p, -i)
    return p

   if 'select' in w.kwargs:
    num = w.kwargs['select']
    data['x1'][num] = add(x, -1)
    data['x2'][num] = add(x, w.w + 1)
    data['y1'][num] = add(y, -1)
    data['y2'][num] = add(y, w.h + 1)

  for k, v in data.iteritems():
   s += " with selected select select_%s <=\n" % k
   for k, v in v.iteritems():
    s += '''  %s when X"%01x",\n''' % (v, k)
   s += '''  "00000000000" when others;\n'''

  return s[:-1]

 def writeVhdl(self, filename):
  with open(filename, 'w') as f:
   f.write(self.generate())

 def memPush(self, n):
  if(0 <= n < 16):
   self.memory.append(Bin(n, 4))
   self.offset += 1
  else:
   raise ValueError("Invalid memory push: %s" % str(n))

 def buildMemory(self):
  for i in xrange(16):
   self.memPush(i)
  widgets_to_offsets = {}
  for w in self.widgetMap.itervalues():
   for k, a in w.serialize().iteritems():
    if k not in widgets_to_offsets:
     widgets_to_offsets[k] = self.offset
     for v in a:
      self.memPush(v)
   w.setOffsets(widgets_to_offsets)
  print widgets_to_offsets

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
  return {}

 def setOffsets(self, offsets):
  pass


class Constant(Widget):
 def __init__(self, *args, **kwargs):
  super(Constant, self).__init__(*args, **kwargs)
  a = self.args
  self.w = self.args[0]
  self.h = self.args[1]
  self.c = self.args[2]

 def draw(self, canvas, palette):
  print "Draw: %s" % str(self)
  return [canvas.create_rectangle(0, 0, self.w, self.h, fill=palette[self.c])]

 def generate(self, hpos, vpos):
  return '''output <= X"%03x"; select_mem <= '0'; ''' % self.c

 def __str__(self):
  a = self.args
  return "Constant %d W: %d, H: %d" % (a[2], a[0], a[1])

class Line(Widget):
 def __init__(self, *args, **kwargs):
  super(Line, self).__init__(*args, **kwargs)
  self.var = self.args[0]
  self.w = 1
  self.h = 480

 def draw(self, canvas, palette):
  return random.choice([self.on, self.off]).draw(canvas, palette)

class Select(Widget):
 def __init__(self, *args, **kwargs):
  super(Select, self).__init__(*args, **kwargs)
  self.conds = self.args[0]
  self.opts = [Sprite(x) for x in self.args[1]]
  assert len(self.opts) - 1 == len(self.conds)
  for o in self.opts:
   assert o.w == self.opts[0].w
   assert o.h == self.opts[0].h
  self.w = self.opts[0].w
  self.h = self.opts[0].h

 def draw(self, canvas, palette):
  return random.choice(self.opts).draw(canvas, palette)

 def generate(self, hpos, vpos):
   res = []
   base = textwrap.dedent("elsif %s then\n %s\n")
   for c, o in zip(self.conds, self.opts[:-1]):
    res.append(base % (c,o.generate(hpos, vpos)))
   res.append("else\n %s\n" % self.opts[-1].generate(hpos, vpos))
   res.append("end if;")
   return ''.join(res)[3:]

 def serialize(self):
  d = {}
  for o in self.opts:
   d.update(o.serialize())
  return d

 def setOffsets(self, offsets):
  for o in self.opts:
   o.setOffsets(offsets)

class Digit(Widget):
 def __init__(self, *args, **kwargs):
  super(Digit, self).__init__(*args, **kwargs)
  self.digits = []
  self.var = self.args[0]
  for i in xrange(10):
    self.digits.append(Sprite("digit%d" % i))
  self.w = self.digits[0].w
  self.h = self.digits[0].h

 def draw(self, canvas, palette):
  return random.choice(self.digits).draw(canvas, palette)

 def generate(self, hpos, vpos):
  assert self.diff is not None, "Run buildMemory first!"
  var = "to_unsigned(to_integer(%s), 12)" % self.var
  return '''output <= Std_logic_vector((%s * %d) + %s + %d + (%d*%s)); select_mem <= '0';''' % (vpos, self.w, hpos, self.base, self.diff, var)

 def serialize(self):
  d = collections.OrderedDict()
  for v in self.digits:
    d.update(v.serialize())
  return d

 def setOffsets(self, offsets):
  self.base = offsets["digit0"]
  self.diff = offsets["digit1"] - offsets["digit0"]
  for d in self.digits:
    d.setOffsets(offsets)



class Sprite(Widget):
 def __init__(self, *args, **kwargs):
  super(Sprite, self).__init__(*args, **kwargs)
  name = self.args[0]
  self.key = name
  self._image = Image.open("sprites/" + name + ".png")
  if(self._image.mode != 'P'):
   raise ValueError("Not indexed image: %s, mode: %s" % (self.key, self._image.mode))
  self.image = ImageTk.PhotoImage(self._image)
  self.w = self.image.width()
  self.h = self.image.height()
  self.offset = None

 def draw(self, canvas, palette):
  return [canvas.create_image(self.image.width()/2, self.image.height()/2, image=self.image)]

 def generate(self, hpos, vpos):
  assert self.offset is not None, "Run buildMemory first!"
  return '''output <= Std_logic_vector((%s * %d) + %s + %d); select_mem <= '0';''' % (vpos, self.w, hpos, self.offset)

 def serialize(self):
  if len(self._image.tobytes()) != self.w * self.h:
   raise ValueError("Image.tobytes on %s didn't work as expected :(" % self.key)
  return {self.key: [ord(x) for x in self._image.tobytes()]}

 def setOffsets(self, offsets):
  self.offset = offsets[self.key]

 def __str__(self):
  return "Sprite " + self.args[0]

class Graph(Widget):
 def __init__(self, *args, **kwargs):
  super(Graph, self).__init__(*args, **kwargs)
  a = self.args
  self.w = self.args[0]
  self.h = 1
  self.index = self.args[1]
  self.neg = not self.args[2]
  self.color = self.args[3]

 def draw(self, canvas, palette):
  ret = []
  for i in xrange(self.w):
   if random.choice([True, False]):
    ret.append(canvas.create_line(i, 1, i, 1, fill=palette[self.color]))
  return ret

 def generate(self, hpos, vpos):
  mask = Bin(self.index, 3)
  return '''output(10 downto 0) <= std_logic_vector(%s); index <= "%s"; output(11) <= '%s'; select_mem <= '1';''' % (hpos, mask, 1 if self.neg else 0)
