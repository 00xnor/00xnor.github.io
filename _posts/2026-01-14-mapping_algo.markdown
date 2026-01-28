---
layout: post
date:   2026-01-14 00:00:00 -0800
group: Tech
title: Mapping Algorithm for Distributed Computing
permalink: /mapping_algo/
published: true
comments: false
---


---

|:-|
| <span style="font-size: 16px;"> For workloads executing on distributed compute fabrics, performance is often limited by data movement rather than computation. As a result, efficient execution depends critically on how the workload is partitioned and **placed across hardware resources**. </span> |
| <span style="font-size: 16px;"> This page describes an algorithm I developed ([**code**](https://github.com/00xnor/mapping_algo){:target="_blank"}) for distributed systems that maps a task graph onto a hardware connectivity graph. The task graph captures computation and communication dependencies, while the hardware graph represents compute elements and their physical interconnects. The algorithm automatically explores a large search space through an iterative process and converges to communication-efficient task assignments while respecting dependency constraints.  </span> |
| <span style="font-size: 16px;"> Based on [**Ant Colony Optimization**](https://en.wikipedia.org/wiki/Ant_colony_optimization_algorithms){:target="_blank"}, the algorithm sends out a group of ants to explore possible paths through the hardware graph. Initially, paths are selected randomly, but over iterations selection becomes biased towards more efficient paths. To guide path selection, top-performing ants leave trails where they travel. And to avoid local minima, the trails that aren’t reinforced by top runners gradually fade away. Over time, the system converges on good solutions without exhaustively exploring every possibility. </span> |
{:.about_table4}

---

![mapping](../images/linear_mapping.gif){:.image_right}

|-:|
| <span style="font-size: 16px;"> The animation features a linear graph being mapped onto a mesh, showing how the algorithm finds one of the **optimal** solutions. Linear graphs are well-suited for developing mapping intuition because the optimal solutions are known. In fact, the mapping for such graphs can be entirely rule-based, following the obvious up/down/left/right/stair/snake patterns. </span> |
| <span style="font-size: 16px;"> However, today's most prominent workloads are rarely linear. Regardless of what the term **workload** brings to mind—be it hyperscale/orchestration level, multi-agent, neural-network, or micro-op level like decomposition of conv2d into im2col and gemm—it is often a non-linear graph like the one below. Mapping patterns for such graphs aren't obvious, especially when the mapping space is constrained. </span> |
{:.about_table6}

---

![mapping](../images/graph.png){:.image_left}

|-:|
| <span style="font-size: 16px;"> Consider mapping this non-linear task graph onto the smallest mesh it can fit into, a 4x4. Having a tight space means that every mapping decision directly impacts subsequent ones. This interdependence makes it challenging to construct a direct solution and apply it generally. </span> |
| <span style="font-size: 35px;  color: #FF5733; "> ------------------------------------ </span> |
| <span style="font-size: 16px;"> More guided than a brute force search, yet not nearly as stringent as a direct solution is the iterative method. It integrates a **heuristic with stochastic elements** to navigate the search space and find satisfactory solutions, including optimal. And sometimes very quickly with proper biasing. But even without nuanced biasing, it's only a matter of time until a good solution emerges. </span> |
{:.about_table7}


---

|-:|
|  <span style="font-size: 22px;">  Don't Give Bad Randomness a Chance </span> |
{:.about_table4}


|:-|
| <span style="font-size: 16px;"> The iterative mapping employs <span style="font-size: 16px;  color: #a82a2a; "> **Ants** </span> to search for an optimal path. Each <span style="font-size: 16px;  color: #a82a2a; "> **Ant** </span> starts at a specific location in the hardware graph (e.g. top-left corner in the animation above) and is given a number of choices on where to go next. Before hopping to the next location, the <span style="font-size: 16px;  color: #a82a2a; "> **Ant** </span> assigns a task to the current location and removes it from the task graph marking it as complete. Each <span style="font-size: 16px;  color: #a82a2a; "> **Ant** </span> keeps hopping until all tasks from the task graph are gone. </span> |
| <span style="font-size: 16px;"> This entire process represents an algorithm's iteration—a single <span style="font-size: 16px;  color: #a82a2a; "> **Ant Colony** </span> run. Once the run is complete, the algorithm determines the top performer. During the very first run, the <span style="font-size: 16px;  color: #a82a2a; "> **Ants** </span> are unbiased. This means one happens to <span style="font-size: 16px;  color: #a82a2a; "> **randomly** </span> find a more efficient path than the others. Just like in any competition, the winner gets to brag about how it did it: “I started in the top left, moved right, then down…” You get the idea. Having listened to the winner, the next <span style="font-size: 16px;  color: #a82a2a; "> **Ant Colony** </span> run becomes slightly biased towards the <span style="font-size: 16px;  color: #a82a2a; "> **randomly** </span> chosen path. This is good randomness though, as it produced the best result so far. </span> |
| <span style="font-size: 16px;"> To keep producing improvements, the <span style="font-size: 16px;  color: #a82a2a; "> **heuristic** </span> ought to maintain  just the right conditions for randomness to work its magic: providing guidance but also allowing deviaton. Here's how this is done in practice: </span> |
| <span style="font-size: 16px;">  </span> |
{:.about_table4}



{% highlight python %}
# Ant's path is constructed by randomly choosing hops.
# Initially, the probabilities are uniformly distributed.
choices =       [c1, c2, ..., cN]
probabilities = [p1, p2, ..., pN]
# After normalization:
[p1, p2, ..., pN] = 1/N

# After an iteration, hops in the top performer's
# path (e.g., c1, c2) receive a probability boost.
choices =       [c1,     c2,     ..., cN]
probabilities = [p1 + x, p2 + x, ..., pN]
# After normalization:
[p1, p2, ..., pN] = [p1 + x, p2 + x, ..., pN]/sum(P)

# Since the first path was chosen randomly,
# the boost shouldn't be excessive.
# A simple model with pheromone deposit and 
# evaporation will do:
deposit = AntHeuristicParams.PHERONOME_DEPOSIT
rate = AntHeuristicParams.PHERONOME_EVAPORATION_RATE
x = deposit + (1 - rate)*current_pheromone 

# Using deposit = 1.0 and evaporation rate = 0.247:
# The boost for for hops in the top performer's path:
x = 1.0 + (1 - 0.247)*1.0 = 1.753
# The boost for other hops:
x = (1 - 0.247)*1.0 = 0.753

# In addition to keeping history of previous choices, 
# path selection is also guided by the energy and time that 
# it takes to travel a path. As part of the heuristic, 
# both components depend on the Manhattan distance
# between nodes in the hardware connectivity graph:
e_route = AntHeuristicParams.ENERGY_ROUTE_ONE_BYTE
e_link = AntHeuristicParams.ENERGY_LINK_ONE_BYTE
energy_per_byte = (dist + 1)*e_route + dist*e_link
n_bytes = dag.edges[edge]['weight']
energy_per_transfer = n_bytes*energy_per_byte
tau = 1/energy_per_transfer

t_compute = dag.nodes[node]['weight']
t_communicate = dag.edges[edge]['weight']*dist
time_total = t_compute + t_communicate
phi = 1/time_total 

# Weights alpha and beta adjust the importance of 
# energy and time components respectively:
p = (tau**alpha)*(phi**beta)

# Example calculation with dist=3, n_bytes=1024:
# (plugging in 1 femtojoule per byte for communication
# and a 128-bit bus @ 200MHz for communication):
n_bytes = 1024
dist = 3
e_route = 1
e_link = 1
energy_per_byte = (3 + 1)*1 + 3*1 = 7
energy_per_transfer = 1024*7 = 7168
tau = 1/7168 = 0.000139509
t_compute = 290
t_communicate = 320*3 = 960
time_total = 290 + 960 = 1250
phi = 1/1250 = 0.0008
p = (0.000139509**0.2)*(0.0008**0.2) = 0.0407

# After adding pheromone bias:
# Top performer edges:
p = 0.0407 + 1.753 ≈ 1.7937
# Others:
p = 0.0407 + 0.753 ≈ 0.7937

# The final probabilities after the first iteration 
# (example for a 4x4 mesh / 240 edges and
# a 19-edge graph from the above):
sum_all = 1.7937*19 + 0.7937*221 ≈ 209.49
prob_top = 1.7937 / 209.49 ≈ 0.856%
prob_other = 0.7937 / 209.49 ≈ 0.379%

# In other words, the edges in the top performer's
# path are only about half a percent likelier to be 
# chosen in the next iteration (0.856-0.379=0.477%).

# Sanity check:
19*0.856% + 221*0.379% ≈ 100%

# The algorithm simply iterates from here.
{% endhighlight %}


![mapping](../images/non_linear_mapping.gif){:.image_right}

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table6}

|-:|
| <span style="font-size: 35px;  color: #686a68; "> --------------------------------- </span> |
| <span style="font-size: 16px;"> The result found by the algorithm for the task graph above is 25 hops. Given the constraints—fixed location for the first and last tasks [0 & 15] and the smallest possible mesh for this graph [4x4]—the algorithm quickly finds a good solution that is only 6 hops away from the optimal (unconstrained) one. </span> |
| <span style="font-size: 35px;  color: #686a68; "> --------------------------------- </span> |
{:.about_table6}

|-:|
| <span style="font-size: 1px;"> .  </span> |
{:.about_table6}


---

|-:|
|  <span style="font-size: 22px;"> Guide The Algorithm </span> |
{:.about_table4}

|-:|
| <span style="font-size: 16px;"> The random component is what helps the algorithm explore new possibilities. Tweaking probabilities and seeing how the search evolves can be really engaging. To get the most out of this, I’d suggest using a live plot to watch the convergence in action. </span> |
| <span style="font-size: 16px;"> The number of individual edges and probabilities is typically quite large. Tuning them one by one is rather challenging and essentially not much different than rule-based mapping. Much more manageable is working with edges when they are grouped. Below is an example where the edges are grouped by Manhattan distance (bin 1=shortest, bin 16=longest). This makes it easier to see what type of edges the algo values as it iterates. </span> |
| <span style="font-size: 16px;"> Once a pattern emerges, further bias can be applied to whole groups of edges instead of individual ones. For example, a uniform distribution means the algorithm values all edge lengths equally. But if the graph is linear, it makes sense to favor short edges much more than long ones. A function like radioactive decay can help achieve that: **y=exp(-edge_length)** can be mixed into the heuristic. It makes longer paths exponentially less likely to be chosen, essentially steering the algorithm towards more efficient paths. The animation below shows this first-order steering process. </span> |
| <span style="font-size: 1px;"> .  </span> |
{:.about_table4}

![biasing](../images/biasing.gif){:.image-center}

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

|-:|
| <span style="font-size: 16px;"> It goes without saying that for complex graphs, such first-order steering may not be nuanced enough. But as with many things tech, it's more of a tradeoff between computer time and human time. A bit of guidance goes a long way. </span> |
{:.about_table4}

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

---

