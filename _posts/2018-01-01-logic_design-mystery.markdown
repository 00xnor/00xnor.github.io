---
layout: post
date:   2018-01-01 00:00:00 -0800
group: Logic Design
title:  Mystery
permalink: /logic_design/mystery/
published: true
comments: false
---

{% highlight verilog %}
module mystery (in, out);
input [2:0] in;
output [7:0] out;
assign out = 1'b1 << in;
endmodule
{% endhighlight %}

