+++
title = "Error-Correction Codes"
date = "2023-07-27"
tags = ["codes", "draft"]
draft = true
+++

## Noisy Channels

### Discrete Memory-less Channel

A discrete memory-less channel can be defined as a triple:

    (X, Y, p(·|·))

Where `X = {x1,..,xm}` is a non-empty finite input alphabet, `Y = {y1,..,xn}` is
a non-empty finite output alphabet and `p(·|·)` is an `m⨯n` matrix (conditioned
probability matrix) of positive real numbers defined such that every row sums up
to `1`. The element `pij` represents the conditional probability `p(yj|xi)`

Intuitively `p(y|x)` defines the probability of observing `y` as output when the
input is `x`.

For a perfectly reliable channel `p(·|·)` is equal to the identity matrix with
`X = Y` or a permutation of its rows.

In this discussion, we assume that we know `p(·|·)`, in other words that we know
the law that drives the communication channel noise.

Given such a (quite strong) assumption, we're going to encode the input
introducing some redundancy in order to maximize the probability to recover the
information in the event of alterations.

The **reliability** of the channel defines its **capacity**, which goes from `0`
to `1`.

### Binary Symmetric Channel

`X = Y = {0, 1}` and `p(·|·)` is defined by the parameter `λ` as:

    p(·|·) =  p(0|0) = 1-λ, p(1|0) = λ
              p(0|1) = λ  , p(1|1) = 1-λ

Or using matrix indices:

    p(·|·) =  p00 = 1-λ, p01 = λ
              p10 = λ  , p11 = 1-λ

In practice `λ` defines the **noise** of the channel.

The worst case is when `λ` is equal to `1/2`. In this case the channel acts
as a perfect random generator since the output has `1/2` probability of being
changed.

When `λ` is `0` or `1` then the channel is perfectly reliable (if is `1` the
channel systematically flips the input bits thus the input can be reliably
recovered by inverting all the output bits).

The capacity of a BSC is `0` when `λ = 1/2` while is `1` when `λ = 0` or `1`.

### Noisy Typewriter

A kind of channel model not really used in practice:

    X = Y = { A, B, ..., Z }

    p(·|·) = p(A|A) = 1/2, P(B|A) = 1/2, P(C|A) = 0  , ... , P(Z|A) = 0
             p(A|B) = 0  , P(B|B) = 1/2, P(C|B) = 1/2, ... , P(Z|B) = 0
             ...

So, is we assign an index `i` to each symbol of `X`, the law that drives `p` is:

    p(j|i) = 1/2 , if j=i or j=i+1 % 26
           = 0   , otherwise

## Channel Capacity

**Mutual Information**: `I(X;Y) = H(X) - H(X|Y)`, represents how many bits of
information relative to `X` the observation of `Y` yields on average.

    H(X) = -∑ p(x)·log2(p(x))
    H(X|Y) = -∑ p(x,y)·log2(p(x|y))

Obviously `0 ≤ I(X;Y) ≤ H(X)`.

**Definition**. The capacity `C` of a channel `(X, Y, p(·|·))` is defined as the
positive real number

    C = max { I(X;Y) }, with (X,Y) = p(x)·p(y|x)

Max by considering all the possible input distributions for `X`.

The set of possible distributions over a set of `m` elements is a set of
probability vectors `R^m` that are non negatives and such that the sum of the
coordinates is `1`.

This set `{ I(X;Y) }` is closed and limited and thus has maximum according to
the Weierstrass theorem.

Given an input distribution `p(x)` and an output distribution `p(y)` we can
compute `I(X;Y)`, and we compute it for all the possible input distributions.
The one that yields the max is the one used to compute `C`.

Thus is the maximum information that may be yielded for `X` when observing `Y`.

Observing the value of the output variable `Y` we remove some entropy over the
input aleatory variable `X` depending on their probability distributions
dependence.

If the input `X = p(x)`:

  `(X,Y) = p(x,y) = p(x)·p(y|x)`

`p(y|x)` is a known number and comes from the channel `p(·|·)` matrix.

Note (not strictly required) `p(y)` can be computed using the marginal
probability, that is as:

    p(y) = ∑_x p(x,y) = ∑_x p(x)·p(y|x)

There are well known algorithms to find the distribution that maximize the
channel capacity.
A popular one is the [Blahut-Arimoto](https://en.wikipedia.org/wiki/Blahut-Arimoto_algorithm) algorithm.

If a channel has capacity `C` then we can transmit on the channel `C` bits of
information reliably.

