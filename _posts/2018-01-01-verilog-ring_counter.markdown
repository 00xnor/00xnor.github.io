---
layout: post
date:   2018-01-01 00:00:00 -0800
group: Logic Design
title:  Ring counter
permalink: /verilog/ring_counter/
published: true
comments: false
---

{% highlight verilog %}
module ring_counter( 
  input clk, rst,
  output reg [3:0] count
);
always @ (posedge clk or negedge rst)
if      (rst == 1'b0)   count <= 4'b0001;
else                    count <= {count[2:0],count[3]}; 
endmodul
{% endhighlight %}
