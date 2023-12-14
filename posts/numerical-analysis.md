+++
title = "Numerical Analysis with Python and Octave"
date = "2019-09-29"
tags = ["mathematics","programming","python","linear-algebra"]
+++

Under the name *Numerical Analysis* identifies the study of numerical methods
for the resolution of complex problems.

The numerical methods are algorithms executable by a machine, that allows a
usually approximate, resolution of complex physical and mathematical issues.

The evaluation of a numerical method is mainly done on the basis of two key
features:
- *Accuracy*: how much the results obtained from the application of the
  resolution method are accurate.
- *Effectiveness*: computational cost of the method. That is, the time necessary
  to the method to terminate with an acceptable result.

These two evaluation criteria give rise to what can be defined as the
analysis of the solvability of a problem. Indeed, is not only necessary to
have a method that is able to solve a problem, but the method should be able to
return reliable results in a useful time. Otherwise, the method used, provided
it works, is completely ineffective.

As an example, consider the problem of weather forecasts. Why are, very often,
long-term forecasts completely incorrect? The reason is that the numerical
calculation method complexity for this problem strongly increases with time.
To get answers within acceptable terms (it would be useful to have an answer
about the tomorrow weather before tomorrow evening!) many factors necessary
for a punctual evaluation are not considered, in this way the resolution time
decreases but, obviously, at the expenses of results accuracy.

This short book goes through the foundation problems and resolutions methods
that are usually targeted by an undergraduate academic course.

All the numerical methods are accompanied by both a Python and an Octave
implementation.

- Book [Download](/companions/numeric-analysis.pdf)
- Source code @ [github](https://github.com/davxy/numeric)
- Linear algebra refresher [post](/posts/linear-algebra).
