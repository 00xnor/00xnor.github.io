---
layout: post
date:   2023-04-01 00:00:00 -0800
group: Tech
title: Mapping Algorithm for Distributed Computing
permalink: /mapping_algo/
published: true
comments: false
---


---

|:-|
| <span style="font-size: 16px;"> For workloads executing on distributed compute fabrics, performance is often limited by data movement rather than computation. As a result, efficient execution depends critically on how the workload is partitioned and **placed across hardware resources**. </span> |
| <span style="font-size: 16px;"> This page demonstrates an algorithm I developed ([**code**](https://github.com/00xnor/mapping_algo){:target="_blank"}) for distributed systems that maps a task graph onto a hardware connectivity graph. The task graph captures computation and communication dependencies, while the hardware graph represents compute elements and their physical interconnects. The algorithm automatically explores a large search space through an iterative process and converges to communication-efficient task assignments while respecting dependency constraints.  </span> |
| <span style="font-size: 16px;"> Based on [**Ant Colony Optimization**](https://en.wikipedia.org/wiki/Ant_colony_optimization_algorithms){:target="_blank"}, the algorithm sends out a group of ants to explore possible paths through the hardware graph. Initially, paths are selected randomly, but over iterations selection becomes biased towards more efficient paths. To guide path selection, top-performing ants leave trails where they travel. And to avoid local minima, the trails that aren’t reinforced by top runners gradually fade away. Over time, the system converges on good solutions without exhaustively exploring every possibility. </span> |
{:.about_table4}

---

![mapping](../images/linear_mapping.gif){:.image_right}

|-:|
| <span style="font-size: 16px;"> The animation to the right features a linear graph being mapped onto a mesh, showing how the algorithm finds one of the **optimal** solutions. Linear graphs are well-suited for developing mapping intuition because the optimal solutions are known. In fact, the mapping for such graphs can be entirely rule-based, following the obvious up/down/left/right/stair/snake patterns. </span> |
| <span style="font-size: 16px;"> However, today's most prominent workloads are rarely linear. Regardless of what the term **workload** brings to mind—be it hyperscale/orchestration level, multi-agent, neural-network, or micro-op level like decomposition of conv2d into im2col and gemm—it is often a non-linear graph like the one below. Mapping patterns for such graphs aren't obvious, especially when the mapping space is constrained. </span> |
{:.about_table6}

---

![mapping](../images/graph.png){:.image_left}

|-:|
| <span style="font-size: 16px;"> Consider the following task graph for mapping onto the smallest mesh it can fit into, a 4x4. Having a tight space means that every mapping decision decision directly impacts subsequent ones. This interdependence makes it challenging to construct a direct solution and apply it generally. </span> |
| <span style="font-size: 35px;  color: #FF5733; "> ------------------------------------ </span> |
| <span style="font-size: 16px;"> More guided than brute force, yet not nearly as rigid as a direct solution is the iterative method. It integrates a **heuristic** with **stochastic elements** to navigate the search space and find satisfactory solutions, including optimal. And sometimes very quickly with proper biasing. But even without nuanced biasing, it's only a matter of time until a good solution emerges. </span> |
{:.about_table7}

|-:|
| <span style="font-size: 1px;"> .  </span> |
{:.about_table4}

|-:|
|  <span style="font-size: 22px;">  Heuristic and Randomness </span> |
{:.about_table4}

|-:|
| <span style="font-size: 1px;"> .  </span> |
{:.about_table4}

{% highlight python %}
# the heuristic integrates time, energy, 
# and distance components

# energy component
e_route = AntHeuristicParams.ENERGY_ROUTE_ONE_BYTE
e_link = AntHeuristicParams.ENERGY_LINK_ONE_BYTE
# manhattan distance
e_per_byte = (dist + 1)*e_route + dist*e_link
n_bytes = dag.edges[edge].get('weight', 1) # communication
e_per_transfer = n_bytes*e_per_byte
tau = 1/e_per_transfer 

# time component
time_route = dag.nodes[node]['weight'] # computation
time_link = dag.edges[edge]['weight']*dist
time_total = time_route + time_link
phi = 1/time_total 

# alpha: how much energy matters
# beta:  how much time matters
# the heuristic is calculated for each
# edge in the hardware graph
p = (tau**alpha)*(phi**beta)  

# at the end of each iteration, 
# pheromone is added to preferred edges 
# to reinforce good performance
# and removed from all edges 
# to avoid local minima
rate = AntHeuristicParams.PHERONOME_EVAPORATION_RATE
mesh.edges[edge]['phe'] = deposit + (1 - rate)*phe 

# the heuristic also integrates pheromone 
# to account for historically good results
p += edge['phe']

# the heuristic is turned into a
# probability of an edge being chosen
# (normalized across all edges)
norm_probs = np.divide(probs, sum(probs))

# finally, the ant chooses
# its next hop as follows
choice = np.random.choice(unvisited, 1, norm_probs)

# the algorithm just iterates from this point on
{% endhighlight %}


|-:|
| <span style="font-size: 1px;"> .  </span> |
{:.about_table4}

![mapping](../images/non_linear_mapping.gif){:.center-image}

|-:|
| <span style="font-size: 1px;"> .  </span> |
{:.about_table4}

---

