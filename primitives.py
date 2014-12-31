import os
import re
import collections

import Tkinter as tk
from PIL import Image, ImageTk

class Bunch:
 def __init__(self, **kwds):
  self.__dict__.update(kwds)

def importPalette(filename):
 palette = []
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
   palette.append("#%02x%02x%02x" % (int(m.group(1)), int(m.group(2)), int(m.group(3))))
 return palette


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

 def show(self):
  for pos, widget in self.widgetMap.iteritems():
   print "Drawing: %s at %s" % (str(widget), str(pos))
   item = widget.draw(self.canvas, self.palette)
   self.canvas.move(item, pos[0], pos[1])
  self.root.mainloop()


class Widget(object):
 def __init__(self, *args, **kwargs):
  self.args = args
  self.kwargs = kwargs

 def draw(self, canvas, palette):
  raise NotImplementedError


class Constant(Widget):
 def draw(self, canvas, palette):
  a = self.args
  return canvas.create_rectangle(0, 0, a[0], a[1], fill=palette[a[2]])

 def __str__(self):
  a = self.args
  return "Constant %d W: %d, H: %d" % (a[2], a[0], a[1])

class Sprite(Widget):
 def draw(self, canvas, palette):
  name = self.args[0]
  self.image = ImageTk.PhotoImage(Image.open("sprites/" + name + ".png"))
  return canvas.create_image(self.image.width()/2, self.image.height()/2, image=self.image)

 def __str__(self):
  return "Sprite " + self.args[0]
