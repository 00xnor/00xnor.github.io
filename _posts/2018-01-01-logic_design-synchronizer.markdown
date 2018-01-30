---
layout: post
date:   2018-01-01 00:00:00 -0800
group: Logic Design
title:  Synchronizer
permalink: /logic_design/synchronizer/
published: true
comments: false
---


{% highlight verilog %}
module synchronizer (sync_row, row, clk, rst);
input           clk, rst;
input   [3:0]   row;
output reg      sync_row;
reg             async_row;

always@(negedge clk or posedge rst)
begin 
if (rst)
begin 
async_row <= 0;
sync_row  <= 0;
end 
else 
begin 
async_row <= (row[0] || row[1] || row[2] || row[3]);
sync_row  <= async_row;
end
end
endmodule 
{% endhighlight %}

