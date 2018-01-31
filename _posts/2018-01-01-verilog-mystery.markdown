---
layout: post
date:   2018-01-01 00:00:00 -0800
group: Verilog
title:  Mystery
permalink: /verilog/mystery/
published: true
comments: false
---

{% highlight verilog %}
module mystery (
  input [2:0] in, 
  output [7:0] out
);
assign out = 1'b1 << in;
endmodule
{% endhighlight %}
