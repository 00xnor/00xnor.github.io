---
layout: post
date:   2018-01-01 00:00:00 -0800
group: Python
title:  Useful examples
permalink: /python/useful_examples/
published: true
comments: false
---

{% highlight python %}
import sys, itertools as itt


#-----------------------------------------------------------------------------------------------
def main():
  print('#------------------ list iterator ------------------')
  a = ['one', 'two', 'three']
  for i, x in enumerate(a):
      print('i={} x={}'.format(i, x))


  print('#------------------ dict iterator ------------------')
  m = {'one': 1, 'two': 2, 'three': 3, 'four': 4}
  for k, v in m.items():
      print('k={} v={}'.format(k, v))


  print('#------------------ zipping ------------------')
  a = [1, 2, 3]
  b = ['a', 'b', 'c']
  z = zip(a, b)
  for i in z: print(i)

  print('#------------------ transposing ------------------')
  z = zip(*zip(a,b))
  for i in z: print(i)


  print('#------------------ grouping ------------------')
  group_adjacent = lambda a, k: zip(*([iter(a)] * k))
  for i in group_adjacent(a, 1): print(i)


  print('#------------------ n grouping ------------------')
  def n_grams(a, n):
      z = (itt.islice(a, i, None) for i in range(n))
      return zip(*z)
  a = [1, 2, 3, 4, 5, 6]
  b = n_grams(a, 3)
  for i in b: print(i)
  b = n_grams(a, 4)
  for i in b: print(i)


  print('#------------------ dict invert ------------------')
  m = {'a': 1, 'b': 2, 'c': 3, 'd': 4}
  for k, v in m.items(): print('k={} v={}'.format(k, v))
  mi = dict(zip(m.values(), m.keys()))
  for k, v in mi.items(): print('k={} v={}'.format(k, v))


  print('#------------------ list flattening ------------------')
  a = [[1, 2], [3, 4], [5, 6]]
  b = sum(a, [])
  print(b)


  print('#------------------ sets ------------------')
  A = {1, 2, 3, 3}
  B = {3, 4, 5, 6, 7}
  print('A: {}'.format(A))
  print('B: {}'.format(B))
  C = A | B
  print('A | B: {}'.format(C))
  D = A & B
  print('A & B: {}'.format(D))
  E = A ^ B
  print('A ^ B: {}'.format(E))
  F = A - B
  print('A - B: {}'.format(F))


  print('#------------------ permutations ------------------')
  for p in itt.permutations([1, 2, 3, 4]):
      print(' '.join(str(x) for x in p))


  print('#------------------ combinations ------------------')
  a = [1, 2, 3, 4]
  for p in itt.chain(itt.combinations(a, 2), itt.combinations(a, 3)):
      print(p)
  for subset in itt.chain.from_iterable(itt.combinations(a, n) for n in range(len(a) + 1)):
      print(subset)


  print('#------------------ comprehensions ------------------')
  a_list = [1, '4', 9, 'a', 0, 4]
  squared_ints = [ e**2 for e in a_list if type(e) == type(int()) ]
  print(squared_ints)


  print('#------------------ filter out ints ------------------')
  x = filter(lambda e: type(e) == type(int()), a_list)
  for i in x: print(i)


  print('#------------------ filter out and square ------------------')
  b = map(lambda e: e**2, filter(lambda e: type(e) == type(int()), a_list))
  for i in b: print(i)  

  pass



#-----------------------------------------------------------------------------------------------
if __name__ == '__main__': main()

{% endhighlight %}

