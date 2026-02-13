---
layout: post
date:   2026-01-28 00:00:00 -0800
group: Tech
title: Analog Accuracy
permalink: /analog_accuracy/
published: true
comments: false
---

---

|:-|
| <span style="font-size: 16px;"> For workloads executing on analog compute fabrics, power can be slashed by orders of magnitude at the expense of computational accuracy. While the benefit is clear, the value of this trade-off is less so, as it depends critically on **how fabric noise impacts solution accuracy**. </span> |
| <span style="font-size: 16px;"> This page describes an evaluation approach that extends average precision (AP) by quantifying the effects of analog computing in the context of image segmentation models. The primary objective of these models is object localization (**figuring out where it is**) and classification (**figuring out what it is**). To evalute a model, its detections (DT) are compared against validation dataset's ground truths (GT). At its core, AP relies on a standard binary classification process with four outcomes. </span> |
{:.about_table4}

$$
\begin{array}{c|cc}
& \text{DT: } 1 & \text{DT: } 0 \\ \hline
\text{GT: } 1 & \text{TP ↑} & \text{FN ↓} \\
\text{GT: } 0 & \text{FP ↓} & \text{TN ↑}
\end{array}
$$

|:-|
| <span style="font-size: 16px;"> Add noise, and this process gets trickier. The variability in the outcomes creates the need for additional considerations that go beyond the standard AP metric. These considerations help pinpoint solution pain points and decide on the value of the power vs. computational accuracy tradeoff. </span> |
{:.about_table4}

---

|-:|
|  <span style="font-size: 22px;">  Standard AP for a Single Class: 🐕‍🦺🦮🐩🐕🐶 </span> |
{:.about_table4}

|:-|
| <span style="font-size: 16px;"> Let's say there's a total of 50 dogs in the entire validation dataset spread across 100 images. Naturally, a trained model would generate low scores for images with no dogs, high scores for images with dogs, and medium scores for images with similar-looking animals. </span> |
| <span style="font-size: 16px;"> The plot below represents a typical evaluation run with two distinct but overlapping distributions. The scores range from <span style="font-size: 16px; color: #a82a2a; "> **0.00 to 0.60** </span> for images with no dogs and from <span style="font-size: 16px;  color: #2b31fb; "> **0.35 to 1.00**</span> for images with dogs. In a standard binary classification process, the scores would be classified using a single threshold. But for a comprehensive evaluation, they are classified using a set of thresholds to account for tradeoffs that can be made. And even though the middle region is where the action takes place, classification is performed across the entire scale. </span> |
{:.about_table4}

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

![dogs_no_dogs](../images/dogs_no_dogs.gif){:.image-center}

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

|:-|
| <span style="font-size: 16px;"> To provide a concise numerical example, the predictions are clustered at 10 confidence scores and coupled with an intersection over union (IoU) level in the table below (left). This allows a full sweep of the scale with only 11 evaluation thresholds, resulting in 11 binary classifications (right). Each classification yields a (TP, FP, FN, TN) set and is reduced to recall $$ (R) $$ and precision $$ (P) $$ ratios. The 11 precision ratios are further condensed into a single $$ AP $$ value using an appropriate measure of central tendency (MoCT). This process is performed across 10 IoU thresholds resulting in 10 $$ AP_{dog\ @\ IoU} $$ values which are then averaged to get the final $$ AP_{dog} = \frac{1}{10} \sum AP_{dog\ @\ IoU} $$. </span> |
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
| <span style="font-size: 16px;"> As an example, the following MoCT can be used to compute $$ AP_{dog} $$ where $$ P_i $$ and $$ R_i $$ are precision and recall at threshold $$ i $$ and $$ R_{i-1} = 0 $$. Plugging in the numbers from the table yields 0.987 @ IoU 0.5. And for the sake of completeness, to get the final $$ AP_{dog} $$, assume that $$ AP_{dog,\ IoU} $$ drops by 0.100 as IoU threshold tightens $$ ↑ $$. </span> |
{:.about_table4}

$$ \text{ (1)}\   AP_{dog\ @\ IoU(0.50)} = \sum_{i=1}^{11} P_i*(R_{i}-R_{i-1}) = 0.987 \\ . \\ . \\ . \\ \text{(10)}\   AP_{dog\ @\ IoU(0.95)} = \sum_{i=1}^{11} P_i*(R_{i}-R_{i-1}) = 0.087 $$

---

$$ AP_{dog} = \frac{1}{10} \sum_{IoUs} AP_{dog\ @\ IoU} = 0.537 $$ 

---

|:-|
| <span style="font-size: 16px;"> The metric addresses localization and classification using calculations across IoUs and confidence thresholds, and is deemed sufficient for evaluating image segmentation models. </span> |
{:.about_table4}






---

|-:|
|  <span style="font-size: 22px;"> Analog AP </span> |
{:.about_table4}

|:-|
| <span style="font-size: 16px;"> Analog computing brings noise into the picture, making computation results variable. The variability starts at the fabric, affecting fundamental linalg operations like matrix-vector multiplication (MVM), and propagates all the way to confidence score generation. As a result, evaluation becomes inherently more statistical, requiring not only a measure of central tendency but also a measure of variability (MoV). </span> |
| <span style="font-size: 16px;"> A segmentation model is a computational graph, but conceptually can be viewed as a composition of layers with linalg ops. Confidence score generation, therefore, is a function of the composition of these ops. And since the fundamental ops are noisy, the score varies as well. Symbolic shorthand: </span> |
{:.about_table4}


$$ S = f(img) \qquad → \qquad  f = f_{L} ∘ f_{L−1} ∘ ⋯ ∘ f_{1} $$

$$ X_{noise} \sim N(\mu, \sigma^2) \qquad op^{noisy} = op + X_{noise} \qquad → \qquad f_{l}^{noisy} \sim N(op_i + \mu, \sigma^2) $$

$$ S = f^{noisy}(img) \qquad → \qquad \tilde{S} \sim D_{pushforward} $$


|:-|
| <span style="font-size: 16px;"> The key is that the score becomes a variable drawn from a pushforward of the noise distribution through the layers. In other words, for the same input image, each forward pass draws a new realization of the score. Below is a visual representation of the varying scores generated by an analog fabric for N images. </span> |
{:.about_table4}


<span style="font-size: 16px; color: #a82a2a; "></span> 

![variable_scores](../images/variable_scores.gif){:.image_center}

|:-|
| <span style="font-size: 16px;"> To measure the variability, $$ AP_{dog} $$ is computed repeatedly over many time points or PVT corners (snapshots of the animation above), resulting in a set of $$ APs $$. These data points are then treated as any other statistical data: plot and choose appropriate MoCT and MoV to represent them. </span> |
| <span style="font-size: 16px;"> With the standard $$ AP $$, however, there's a risk of misclassifying random outcomes as true positives and true negatives when they match the ground truth. To tease out these seemingly positive effects, I recommend a modification to the classification process: compare noisy detections against a combination of digital detections and ground truths. This modification makes evaluation more rigorous, **prioritizing average consistency over occasional performance**. </span> |
{:.about_table4}

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

$$
\begin{array}{c|cc}
\text{GT} & \text{digital DT} & \text{noisy DT} & \text{classification} & \text{comment} \\ \hline
\ 1 & \text{1} & \text{1} & \text{TP}\\
\ 1 & \text{1} & \text{0} & \text{FN} & \text{anticipated negative effect}\\
\ 1 & \text{0} & \text{1} & \text{TP → FP} & \text{(!) positive effect as a random event}\\
\ 1 & \text{0} & \text{0} & \text{FN}\\
\ 0 & \text{1} & \text{1} & \text{FP}\\
\ 0 & \text{1} & \text{0} & \text{TN → FN} & \text{(!) positive effect as a random event}\\
\ 0 & \text{0} & \text{1} & \text{FP} & \text{anticipated negative effect}\\
\ 0 & \text{0} & \text{0} & \text{TN}\\
\end{array}
$$

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

|:-|
| <span style="font-size: 16px;"> The modified classification, repeatedly computed $$ AP $$, and additional MoCT and MoV that accounts for variability together constitute analog AP. </span> |
{:.about_table4}

---

|-:|
|  <span style="font-size: 22px;"> Sensitivity Analysis </span> |
{:.about_table4}

|:-|
| <span style="font-size: 16px;"> Analog AP is a dense metric; some effects of analog computing may be buried or averaged out. A sensitivity analysis on individual images or object types can prove useful in uncovering solution pain points that are not easily detected by analog AP. </span> |
| <span style="font-size: 16px;"> Below is an example of such analysis that sweeps across a noise parameter. Modeled by a normal distribution, the error caused by noise is added to MVM performed by the computing fabric. The animation below increases error's standard deviation from 0.001 to 0.135 and tracks IoUs and confidence scores for two objects: a small blurry bird on the left and a large clear bird on the right. </span> |
{:.about_table4}

$$ X_{error} \sim N(\mu, \sigma^2) \qquad S = f^{noisy}(img) \qquad → \qquad \tilde{S} \sim D_{pushforward} $$


|:-|
| <span style="font-size: 16px;"> The generated plot uncovers a few key effects of analog noise. First, object localization is hardly affected by higher noise levels: the blue lines representing IoUs wobble around their initial levels. Second, the red lines representing confidence scores are concave down and steadily decreasing, reducing the confidence in proportion to noise levels. Though, the confidence is reduced across other classes as well and this does not cause mispredictions. And third, harder-to-detect objects (smaller, blurry, overlapping) are more susceptible to noise, dropping below detection thresholds sooner. </span> |
{:.about_table4}

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

![birds_no_birds](../images/birds_no_birds.gif){:.image_center}

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

|:-|
| <span style="font-size: 16px;"> Analog AP, coupled with the sensitivity analysis, helps transform qualitative observations into quantifiable, defensible conclusions, and ultimately decide on **the value of the power vs. computational accuracy tradeoff**. And given the huge potential for power savings, it's possible that some degree of analog computing will find its way into AI accelerators. </span> |
{:.about_table4}


|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

---

|-:|
| <span style="font-size: 1px;"> . </span> |
{:.about_table4}

