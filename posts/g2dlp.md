+++
title = "G2DLP Algorithm Analysis"
date = "2016-01-27"
tags = ["algorithms","cryptography"]
+++

We discuss an algorithm to generate efficiently all the paths of a
two-dimensional lattice with a given number of turns.

The algorithm was first proposed by Ting Kuo, associate professor of the
University of Technology and Science in Takming (Taiwan), and in this paper
we will go further with an in depth complexity analysis, implementation and
experimental results.

The algorithm performances are then compared against a naive generation
approach.

Finally, two potential applications of such kind of counting techniques are
presented.

The discussed algorithms are all accompanied by a modern and reusable
C++ implementation.

## Introduction

Given a 2D point lattice, i.e. a grid of points, in this work we will study
an efficient way to generate all the paths between two arbitrary points with a
given number of turns, that is the paths where the direction of the path changes
a given number of times.

In literature, there are plenty of algorithms and theoretical results about
lattice paths generation, but not too many that restrict the enumeration to the
paths with a given number of turns.

The motivations to be interested in such counting problems touch a very
different set of disciplines such as probability, statistics, cryptography,
scheduling, commutative algebra, etc.

The problem of turn enumeration of lattice paths was attacked in many ways.
However, there is a uniform approach which is able to handle all these problems,
which is by encoding paths in terms of two-rowed arrays.

Actually this is the way in which Narayana, who probably was the first to count
paths with respect to their turns, used to see turn enumeration problems.

This study goes from a fairly rigorous complexity analysis to experimentation.

## Companion Material

- [Complete work](/companions/g2dlp/g2dlp-analysis.pdf)
- [Companion sources](/companions/g2dlp/g2dlp.tar.gz)
- Ting Kuo original paper [here](http://www.mdpi.com/1999-4893/8/2/190)
