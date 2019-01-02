---
layout: post
date:   2018-01-01 00:00:00 -0800
group: C
title:  C
permalink: /c/
published: true
comments: false
---

{% highlight c %}
#include "common.h"


//-----------------------------------------------------------------------------
static const uint8_t code[8] = { 
  0x48, 0x31, 0xC0, 0x48, 0x83, 0xC0, 0x0D, 0xC3 
};


//-----------------------------------------------------------------------------
int main(void)
{
  uintptr_t page_aligned_addr = (uintptr_t)code & ~(getpagesize() - 1);
  size_t length = ((uintptr_t)code - page_aligned_addr) + sizeof(code);
  
  mprotect((void *)page_aligned_addr, length, PROT_EXEC|PROT_WRITE|PROT_READ);
  printf("%d\n", ((int (*)(void))code)());
  
  return 0;
}
{% endhighlight %}

