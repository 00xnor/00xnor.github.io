---
layout: post
date:   2026-01-28 00:00:00 -0800
group: Tech
title: Analog Inference 
permalink: /analog_inference/
published: true
comments: false
---

---

![sf_ride_seg](../images/sf_ride_seg.gif){:.center_gif}

---


|:-|
| <span style="font-size: 16px;"> For workloads executing on analog compute fabrics, power can be slashed by orders of magnitude at the expense of computational accuracy. While this tradeoff offers clear power benefits, its value depends critically on **how fabric noise impacts solution accuracy**. </span> |
| <span style="font-size: 16px;"> This page describes an evaluation approach that extends the standard [average precision](https://en.wikipedia.org/wiki/Evaluation_measures_(information_retrieval)#Average_precision){:target="_blank"} metric (AP) by quantifying the effects of analog computing in the context of image segmentation models. The primary task of these models is object detection, which combines object localization (**figuring out where it is**) and classification (**figuring out what it is**). Standard evaluation compares detections (DT) against ground truths (GT) from a validation dataset. At its core, AP relies on a traditional binary classification with four outcomes: </span> |
{:.about_table4}


$$
\begin{array}{c|cc}
& \text{DT: } 1 & \text{DT: } 0 \\ \hline
\text{GT: } 1 & \text{TP ↑} & \text{FN ↓} \\
\text{GT: } 0 & \text{FP ↓} & \text{TN ↑}
\end{array}
$$

|:-|
| <span style="font-size: 16px;"> Add noise, and classification gets trickier: outcomes become variable. Standard AP is not designed to capture this variability, nor does it prevent random positive effects from cancelling out systemic negative ones. This calls for an extension to account for these dynamics. </span> |
{:.about_table4}

---

|-:|
|  <span style="font-size: 22px;"> But First, a Warm-Up 🐕‍🦺🦮🐩🐕🐶 </span> |
{:.about_table4}

|:-|
| <span style="font-size: 16px;"> Let's say there's a total of 50 dogs in the entire validation dataset spread across 100 images. Naturally, a trained model would generate low scores for images with no dogs, high scores for images with dogs, and medium scores for images with similar-looking animals. </span> |
| <span style="font-size: 16px;"> The plot below represents a typical evaluation run with two distinct but overlapping distributions. The scores range from <span style="font-size: 16px; color: #a82a2a; "> **0.00 to 0.60** </span> for <span style="font-size: 16px; color: #a82a2a; "> **no dogs**</span> and from <span style="font-size: 16px;  color: #2b31fb; "> **0.35 to 1.00**</span> for <span style="font-size: 16px;  color: #2b31fb; "> **dogs**</span>. For a comprehensive evaluation, the scores are classified using multiple thresholds rather than a single one, to account for potential tradeoffs. And even though the middle region is where the action takes place, classification is performed across the entire scale, sweeping all the way from left to right. </span> |
{:.about_table4}



|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

![dogs_no_dogs](../images/dogs_no_dogs.gif){:.center_gif}

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

|:-|
| <span style="font-size: 16px;"> To provide a concise numerical example, I make up prediction scores, cluster them at 10 confidence scores, and couple with an intersection over union (IoU) level in the table below (left). This allows a full sweep of the scale with only 11 evaluation thresholds, resulting in 11 binary classifications (right). Each classification yields a (TP, FP, FN, TN) set and is reduced to recall $$ (R) $$ and precision $$ (P) $$ ratios. The 11 precision ratios are further condensed into a single $$ AP $$ value using an appropriate measure of central tendency (MoT). This process is performed across 10 IoU thresholds resulting in 10 $$ AP_{dog\ @\ IoU} $$ values which are then averaged to get the final $$ AP_{dog} = \frac{1}{10} \sum AP_{dog\ @\ IoU} $$. </span> |
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

$$
\begin{array}{c|cc}
\text{score} & \text{dogs} & \text{no dogs} & \text{IoU} \\ \hline
\text{0.95} & \text{1} & \text{0} & 0.85 \\
\text{0.85} & \text{3} & \text{0} & 0.80 \\
\text{0.75} & \text{10} & \text{0} & 0.75 \\
\text{0.65} & \text{25} & \text{0} & 0.70 \\
\text{0.55} & \text{8} & \text{1} & 0.65 \\
\text{0.45} & \text{2} & \text{4} & 0.60 \\
\text{0.35} & \text{1} & \text{17} & 0.55 \\
\text{0.25} & \text{0} & \text{23} & 0.55 \\
\text{0.15} & \text{0} & \text{4} & 0.55 \\
\text{0.05} & \text{0} & \text{1} & 0.55 \\
\end{array}
\qquad
\begin{array}{c|cc}
\text{threshold} & TP & FP & FN & TN & R_{i} & P_{i} & {i} \\ \hline
\text{1.00} & 0  & 0  & 50 & 50 & 0.00 & 1.00 & 1 \\
\text{0.90} & 1  & 0  & 49 & 50 & 0.02 & 1.00 & 2 \\
\text{0.80} & 4  & 0  & 46 & 50 & 0.08 & 1.00 & 3 \\
\text{0.70} & 14 & 0  & 36 & 50 & 0.28 & 1.00 & 4 \\
\text{0.60} & 39 & 0  & 11 & 50 & 0.78 & 1.00 & 5 \\
\text{0.50} & 47 & 1  & 3  & 49 & 0.94 & 0.98 & 6 \\
\text{0.40} & 49 & 5  & 1  & 45 & 0.98 & 0.91 & 7 \\
\text{0.30} & 50 & 22 & 0  & 28 & 1.00 & 0.69 & 8 \\
\text{0.20} & 50 & 45 & 0  & 5  & 1.00 & 0.53 & 9 \\
\text{0.10} & 50 & 49 & 0  & 1  & 1.00 & 0.51 & 10 \\
\text{0.00} & 50 & 50 & 0  & 0  & 1.00 & 0.50 & 11 \\
\end{array}
$$

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

|:-|
| <span style="font-size: 16px;"> As an example, the following MoT can be used to compute $$ AP_{dog} $$ where $$ P_i $$ and $$ R_i $$ are precision and recall at threshold $$ i $$ and $$ R_{i-1} = 0 $$. Plugging in the numbers from the table yields 0.987 @ IoU 0.5. And for the sake of completeness, to get the final $$ AP_{dog} $$, assume that $$ AP_{dog,\ IoU} $$ drops by 0.100 as IoU threshold tightens $$ (↑) $$. </span> |
{:.about_table4}

$$ \text{ (1)}\   AP_{dog\ @\ IoU(0.50)} = \sum_{i=1}^{11} P_i*(R_{i}-R_{i-1}) = 0.987 \\ . \\ . \\ . \\ \text{(10)}\   AP_{dog\ @\ IoU(0.95)} = \sum_{i=1}^{11} P_i*(R_{i}-R_{i-1}) = 0.087 $$

---

$$ AP_{dog} = \frac{1}{10} \sum_{IoUs} AP_{dog\ @\ IoU} = 0.537 $$ 

---

|:-|
| <span style="font-size: 16px;"> The metric addresses both localization and classification through calculations across IoUs and confidence thresholds, and is plenty **sufficient for evaluating image segmentation models**. But here comes the noise.</span> |
{:.about_table4}






---

|-:|
|  <span style="font-size: 22px;"> Seemingly Good Randomness </span> |
{:.about_table4}

|:-|
| <span style="font-size: 16px;"> Analog computing brings noise into the picture, making computation results inherently variable. This variability originates at the fabric level, affecting fundamental linalg operations like matrix-vector multiplication (MVM), and propagates all the way to confidence score generation. As a result, evaluation becomes inherently more statistical, requiring not only a measure of central tendency but also a measure of variability (MoV). </span> |
| <span style="font-size: 16px;"> Conceptually, a segmentation model can be viewed as a composition of layers with linalg ops. Confidence score generation is therefore a function of the composition of these ops. And since the fundamental ops are noisy, the resulting scores vary as well. Symbolic shorthand: </span> |
{:.about_table4}


$$ S = f(img) \qquad → \qquad  f = f_{L} ∘ f_{L−1} ∘ ⋯ ∘ f_{1} $$

$$ X_{noise} \sim N(\mu, \sigma^2) \qquad op^{noisy} = op + X_{noise} \qquad → \qquad f_{l}^{noisy} \sim N(op_i + \mu, \sigma^2) $$

$$ S = f^{noisy}(img) \qquad → \qquad \tilde{S} \sim D_{pushforward} $$


|:-|
| <span style="font-size: 16px;"> The key is that the score effectively becomes a random variable drawn from a pushforward of the noise distribution through the layers. In other words, for the same input image, each forward pass yields a new realization of the score. Below is a visual representation of this behavior, showing varying scores generated by an analog fabric for the same set of images. </span> |
{:.about_table4}


<span style="font-size: 16px; color: #a82a2a; "></span> 

![variable_scores](../images/variable_scores.gif){:.center_gif}

|:-|
| <span style="font-size: 16px;"> To capture variability, $$ AP_{dog} $$ is computed repeatedly over many time points or PVT corners (snapshots of the animation above), yielding multiple $$ APs $$. These data points are then treated as any other statistical data: plotted and summarized using appropriate measures of central tendency and variability. </span> |
| <span style="font-size: 16px;"> With standard $$ AP $$, however, there's a risk of misclassifying random outcomes as true positives and true negatives when they happen to match the ground truth. To tease out these seemingly positive effects, I recommend a modification to the classification process: compare noisy detections against a combination of digital detections and ground truths. This refinement makes evaluation more rigorous, **prioritizing average consistency over occasional performance**. </span> |
{:.about_table4}

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

$$
\begin{array}{c|cc}
\text{GT} & \text{digital DT} & \text{noisy DT} & \text{classification} & \text{comment} \\ \hline
\ 1 & \text{1} & \text{1} & \text{TP}\\
\ 1 & \text{1} & \text{0} & \text{FN} & \text{anticipated negative effect}\\
\ 1 & \text{0} & \text{1} & \text{TP → FP} & \text{(!) positive effect but random}\\
\ 1 & \text{0} & \text{0} & \text{FN}\\
\ 0 & \text{1} & \text{1} & \text{FP}\\
\ 0 & \text{1} & \text{0} & \text{TN → FN} & \text{(!) positive effect but random}\\
\ 0 & \text{0} & \text{1} & \text{FP} & \text{anticipated negative effect}\\
\ 0 & \text{0} & \text{0} & \text{TN}\\
\end{array}
$$

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

|:-|
| <span style="font-size: 16px;"> Together, the modified classification, repeatedly computed $$ AP $$, and additional MoT and MoV constitute what I simply call <span style="font-size: 16px; color: #a82a2a; ">**Analog AP**</span>. This metric enables direct evaluation of noise's impact on solution accuracy. </span> |
{:.about_table4}

---








|-:|
|  <span style="font-size: 22px;"> Yet, It Is a Summary Statistic </span> |
{:.about_table4}

|:-|
| <span style="font-size: 16px;"> <span style="font-size: 16px; color: #a82a2a; ">**Analog AP**</span> is a dense metric; some effects of analog computing may be buried or averaged out. A sensitivity analysis on individual images or object types can help uncover pain points that <span style="font-size: 16px; color: #a82a2a; ">**Analog AP**</span> might miss. </span> |
| <span style="font-size: 16px;"> Below is an example of such analysis, sweeping across a noise parameter. Modeled as a normal distribution, the error caused by noise is added to MVMs performed by the fabric. The animation increases error's standard deviation from 0.001 to 0.135, tacking IoUs and confidence scores for two objects: a small, blurry bird on the left and a large, clear bird on the right. </span> |
{:.about_table4}

$$ X_{error} \sim N(\mu, \sigma^2) \qquad S = f^{noisy}(img) \qquad → \qquad \tilde{S} \sim D_{pushforward} $$


|:-|
| <span style="font-size: 16px;"> The results reveal three key effects of analog noise. First, object localization is largely unaffected by higher noise levels: the blue IoUs lines just wobble around their initial levels. Second, confidence scores decrease steadily with noise, following a concave-down trajectory. Though, this alone does not cause mispredictions as the confidence drops across other classes as well. And third, harder-to-detect objects (smaller, blurry, overlapping) are more susceptible to noise, falling below detection thresholds sooner. </span> |
| <span style="font-size: 16px;"> The first two effects are likely discernible even in the dense metric, but the third one is easily buried due to varying object sizes and overlap conditions. </span> |
{:.about_table4}

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

![birds_no_birds](../images/birds_no_birds.gif){:.center_gif}

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

---

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}


|:-|
| <span style="font-size: 16px;"> Coupled with sensitivity analysis, <span style="font-size: 16px; color: #a82a2a; ">**Analog AP**</span> transforms observations into quantifiable, defensible conclusions, and ultimately **helps decide on the value of the power-accuracy tradeoff**. </span> |
{:.about_table4}

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

---


|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}


