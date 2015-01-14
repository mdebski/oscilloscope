def Bin(n, l):
     return bin(n)[2:].rjust(l, '0')

clk = 40.96

b = 12
n = 2**b

def gen(k):
 res = []
 for i in xrange(n):
  b = ((i*k) % n) < k/2
  res.append(b)
 return res

def gen(k):
 res = []
 for i in xrange(n):
  b = ((i*k) % n) < k
  res.append(b)
 return res


def fmt(bs):
 return ''.join(['#' if b else ' ' for b in bs])

def min_diff(bs):
 m = len(bs)
 last_pos = -len(bs)
 for i, b in enumerate(bs + bs):
  if b:
   m = min(m, i-last_pos)
   last_pos = i
 return m

def max_diff(bs):
 m = 0
 last_pos = 0
 for i, b in enumerate(bs + bs):
  if b:
   m = max(m, i-last_pos)
   last_pos = i
 return m

def to_freq(ticks):
 return ticks * clk / n

def dist_to_freq(ticks):
 return clk/ticks

def freq(bs):
 return float(sum(bs)) / len(bs)

def skew(i):
 return dist_to_freq(min_diff(gen(i))), dist_to_freq(max_diff(gen(i)))
