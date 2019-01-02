---
layout: post
date:   2018-01-01 00:00:00 -0800
group: Python
title: Python
permalink: /python/
published: true
comments: false
---

{% highlight python %}
import sys, itertools as itt


#------------------------------------------------------------------------------
def main():
  print('grouping')
  a = [1, 2, 3, 4, 5, 6]
  group_adjacent = lambda a, k: zip(*([iter(a)] * k))
  for i in group_adjacent(a, 2): print(i)
  for i in group_adjacent(a, 3): print(i)

  print('n-grouping')
  a = [1, 2, 3, 4, 5, 6]
  def n_grams(a, n):
      z = (itt.islice(a, i, None) for i in range(n))
      return zip(*z)
  for i in n_grams(a, 3): print(i)
  for i in n_grams(a, 4): print(i)

  print('filter out and square')
  a = [1, '4', 9, 'a', 0, 4]
  b = map(lambda e: e**2, filter(lambda e: type(e) == type(int()), a))
  for i in b: print(i)  
  pass


#------------------------------------------------------------------------------
if __name__ == '__main__': main()
{% endhighlight %}

