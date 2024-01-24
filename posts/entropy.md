+++
title = "Information Entropy"
date = "2023-07-22"
modified = "2024-01-18"
tags = ["cryptography","codes","entropy","information-theory"]
toc = true
+++

Entropy serves as a fundamental metric for quantifying the information produced
by a data source. This concept, primarily developed and explored by Shannon
around 1948, forms the cornerstone of **information theory**. This field
underpins the development of modern techniques in error correction, data
compression, and cryptographic systems.

Consider a random variable `X`. The entropy of `X` quantifies the uncertainty
associated with the outcomes of `X`. It is intrinsically linked to the notion of
**information content**. Indeed, these terms are frequently used synonymously.
For any data source, a higher entropy signifies greater informational content in
each data sample.

Moreover, the entropy of a data source provides insights into the potential
for compressing its information. In practical terms, entropy can be regarded
as the converse of **redundancy**, indicating the extent to which data can be
efficiently encoded.

## Random Variable Information

If `X` is a data source that yields symbols of an alphabet and `x ∈ X` is a
particular instance of `X` (an event), we can model `X` as a random variable
by assigning a probability value `p(X = x)` to each event `x ∈ X`.

From now on, for conciseness, we are going to alias `p(X = x)` with `p(x)`.

When analyzing the entropy of a data source `X`, its probability distribution
`p` is assumed to be known.

We want to quantify the **information** gained from the observation of a
particular instance `x` of the variable `X`.

When a particular instance `x` is observed, if `p(x)` is small then the
information gain associated with the event for an observer is high. In contrast,
if `p(x)` is high then the event doesn't provide a lot of new information
because the event was already expected to happen.

The information gained by observing an event `x` is thus some kind of inverse of
`p(x)`, in particular it is defined as:

    I(x) = log₂(1/p(x))

The `log₂` is used because we are reasoning in terms of bits of information.

For instance:

    p(x) = 1/2  →  I(x) = 1    (one bit of information, i.e. true/false)
    p(x) = 1/8  →  I(x) = 3

The logarithm has some nice properties we rely on, we want that the information
provided by two independent events `x` and `y` to be equal to the sum of the
information they independently yield:

    I(x,y) = log₂(1/p(x,y)) = log₂(1/(p(x)p(y)))
           = log₂(1/p(x)) + log₂(1/p(y)) = I(x) + I(y)


## Entropy

The entropy of a data source modeled as a random variable `X` is defined as the
**expected value** of the information `I` defined as `x ∈ X` varies:

     H(X) = E[I(x)] = ∑ₓ p(x)·log₂(1/p(x))   for x ∈ X with p(x) ≠ 0

Given that the more an event is unlikely and the more information its
observation yields, entropy can be equivalently defined as the measure of the
average uncertainty associated to an event of a random variable (data source).

The entropy grows with the number of possible events.

The closer `X` is to the **uniform distribution** the greater is the entropy,
and if all the elements have the same probability of being observed, then
this is the situation where on average we are mostly surprised to observe one
specific event.

The opposite case is when the probability is concentrated on a small set of
elements. The surprise factor associated with high probable events is low and
thus the overall `H(x)` value is lowered.

**Proposition**

- `H(X) = 0` iff `X` deterministically yields one single element.
- `H(X) = log₂(|X|)` iff `X` has a uniform distribution.

*Proof* (one way only)

If `X` deterministically yields the element `k` then `p(k) = 1`:

    H(X) = p(k)·log₂(1/p(k)) = log₂1 = 0

If `X` is uniform then `p(x) = 1/|X|` for every `x`:

    H(X) = ∑ₓ 1/|X|·log₂(|X|) = |X|·1/|X|·log₂(|X|)
  
**Proposition**. For any random variable `X`

    0 ≤ H(X) ≤ log₂(|X|)

*Proof*

The left-hand trivially follows the entropy definition.

The right-hand side intuitively follows the fact that we have max entropy when
`X` has a uniform distribution. For a formal proof we need to resort to the
Jensen's inequality. For a concave function `f`:

    E[f(Y)] ≤ f(E[Y])

Setting `Y = 1/p(X)` and `f(Y) = log₂(Y)`:

    E[log₂(1/p(X))] = H(X) ≤ log₂(E[1/p(X)]) = log₂(|X|)

Which follows from `E[1/p(X)] = ∑ₓ p(x)·1/p(x) = ∑ₓ 1 = |X|`

∎

Example. `X` is the result of throwing a `6` faces die.
  
Fair die: `p(x) = 1/6`, for all `x ∈ X`

    H(X) = -[p(1)·log₂(p(1)) + ... + p(6)·log₂(p(6))]
         = -[1/6·log₂(1/6) + ... + 1/6·log₂(1/6)]
         = -6·1/6·log₂(1/6) = log₂6 ≈ 2.58

Unfair die: `p(5) = 1` and `p(x) = 0, ∀ x ≠ 5`

    H(X) = -p(5)·log₂(p(5)) = -1·log₂1 = 0

Biased die: `p(1) = 1/2` and `p(x) = 1/10, ∀ x ≠ 1`

    H(X) = -[p(1)·log₂(p(1)) + p(2)·log₂(p(2)) + ... + p(6)·log₂(p(6))]
         = -[1/2·log₂(1/2) + 5/10·log₂(1/10)]
         = 1/2 + 1/2·log₂10 = (1 + log₂10)/2 ≈ 2.16

Note that `2^2.58 ≈ 6` are the total number of possible events `|X|`.

Max entropy corresponds to the power of `2` that gives back the number of
possible outcomes in a uniform distribution.


## Joint Entropy

Given two random variables `X` and `Y`, the couple `(X,Y)` is still a random
variable. Follows that we can compute `H(X,Y)`.

The values of `(X,Y)` are distributed according to the joint probability
distribution `p(X,Y)`:

    H(X,Y) = -∑ₓᵧ p(x,y)·log₂(p(x,y))

As for any other probability distribution, `∑ₓᵧ p(x,y) = 1`.

Note that since `p(X,Y) = p(Y,X)` then `H(X,Y) = H(Y,X)`.
          

## Conditional Entropy

The intuitive meaning of `H(X|Y)` is the average residual uncertainty for `X`
after that an event of `Y` has been observed.

Let `X` and `Y` be two random variables. The conditional probability of `X`
given `Y` is written as `p(X|Y)` and is defined as the probability of an event
of `X` to happen after that an event of `Y` has been observed.

The conditional probability `p(X|Y)` is still a probability distribution, but
generally defined on a sub set of elements of the whole set `X`.

Computing the conditional entropy `p(X|Y=y)` is just a matter of using
conditional probabilities for the single events of `X` given the event `Y = y`:

    H(X|Y=y) = -∑ₓ p(x|y)·log₂(p(x|y))

Remember, for a conditional probability distribution `∑ₓ p(x|y) = 1`
(Note that we sum just over all possible `x`, `y` is fixed).

Now we define the expected entropy of `X` after the observation a generic event
`y ∈ Y`:

    H(X|Y) = ∑ᵧ p(y)·H(X|Y=y)
           = ∑ᵧ [p(y) · -∑ₓ p(x|y)·log₂(p(x|y))]
           = -∑ₓᵧ p(y)·p(x|y)·log₂(p(x|y))
           = -∑ₓᵧ p(x,y)·log₂(p(x|y))

Example:

- `X = {1,..,6}` outcome of a fair die roll;
- `Y = 0` if the outcome is even and `Y = 1` if is odd.

Given the event `Y = 0`, then the new probability distribution for `X` is:

    p(X=2|Y=0) = p(X=4|Y=0) = p(X=6|Y=0) = 1/3
    p(X=1|Y=0) = p(X=3|Y=0) = p(X=5|Y=0) = 0
    
    H(X|Y=0) = -3·1/3·log₂(1/3) = log₂3 ≈ 1.58

The same value is obtained for `Y = 1`.

Thus, as expected, in the fair die roll removing half of the possibilities
reduces the entropy by one bit.

    H(X|Y=0) = H(X|Y=1) ≈ log₂3

    → H(X|Y) = 1/2·H(X|Y=0) + 1/2·H(X|Y=1) ≈ log₂3 = 1.58

For a biased die where `p(X=1) = 1/2` and `p(X=x) = 1/10`, `∀x ≠ 1`

    H(X) = 1/2·log₂2 + 5·1/10·log₂10 ≈ 2.16

We set `Y=0` iff `X=1` and `Y=1` otherwise. The events are equally probable.
    
    p(X=1|Y=0) = 1 and p(X≠1|Y=0) = 0
    → H(X|Y=0) = p(X=1|Y=0)·log₂(1/p(X=1|Y=0)) = 1·log₂1 = 0

In this case knowing the outcome of `Y` completely determine `X`.

    p(X=1|Y=1) = 0 and p(X=x|Y=1) = 1/5, ∀ x ≠ 1  
    → H(X|Y=1) = ∑ₓ p(X=x|Y=1)·log₂(1/p(X=x|Y=1)) = 5·1/5·log₂5 ≈ 2.32

The overall conditional entropy is thus:

    H(X|Y) = 1/2·H(X|Y=0) + 1/2·H(X|Y=1) = 1/2·0 + 1/2·log₂5 ≈ 1.16

In this case knowing that the outcome is `>1` lowers the entropy by `1` bit.

This last example shows that removing one bit of entropy doesn't necessarily
mean the exclusion of half of the possible events. Instead, it means the
exclusion of one or more possible events whose probabilities sum to `1/2`.

Even though is absolutely possible that `H(X|Y=y) ≥ H(X)`, in general:

    H(X|Y) ≤ H(X)

This last statement will be proven later after the introduction of mutual
information and Kullback-Leibler divergence.

### Chain Rule

    H(X,Y) = H(Y) + H(X|Y)

Proof.

    H(X,Y) = -∑ₓᵧ p(x,y)·log₂p(x,y)
           = -∑ₓᵧ p(x,y)·log₂(p(y)·p(x|y))
           = -∑ₓᵧ p(x,y)·[log₂p(y) + log₂p(x|y)]
           = -∑ₓᵧ p(x,y)·log₂p(y) + -∑ₓᵧ p(x,y)·log₂p(x|y) 
           = -∑ᵧ p(y)·log₂p(y) + -∑ₓᵧ p(x,y)·log₂p(x|y) 
           = H(Y) + H(X|Y)
∎

Example for the die roll with `Y = 0` iff `X` is even and `Y = 1` otherwise:

    H(X,Y) = H(X) + H(Y|X) = log₂6 + 0 = log₂6
    H(Y,X) = H(Y) + H(X|Y) = log₂2 + log₂3 = log₂6

Follows that, when possible, it is always convenient to compute the conditional
probability that has a zero value (i.e. the one where the conditioned variable
value is completely determined by the other).

**Corollary**. When `Y` is a function of `X` (`X` completely determines `Y`)
then `H(X,Y) = H(X)`.

Proof: `H(X,Y) = H(X) + H(Y|X) = H(X) + 0 = H(X)`

**Proposition**. `H(X,Y) ≤ H(X) + H(Y)`.

Easily proven because `H(Y|X) ≤ H(Y)` and `H(X|Y) ≤ H(X)`. We have the equality
only when `X` and `Y` are independent.

    H(X,Y) = H(X) + H(Y|X) ≤ H(X) + H(Y)

All these properties can be generalized to an arbitrary number of variables.

### Residual Possibilities Bound
 
Given `|Xᵧ| = |{x: p(x|y) > 0}|` the number of events of `X` that are possible
after the observation of the event `Y = y`. Then:

    E[|Xᵧ|] ≥ 2^H(X|Y)

Proof.

    0 ≤ H(X|Y=y) ≤ log₂(|Xᵧ|)

(This is quite natural given that: `0 ≤ H(X) ≤ log₂(|X|)`)

Taking the average values over `Y`:

    0 ≤ ∑ᵧ p(y)·H(X|y) ≤ ∑ᵧ p(y)·log₂(|Xᵧ|)

Using the *Jensen's Inequality* for concave functions:

    0 ≤ H(X|Y) ≤ E[log₂(|Xᵧ|)] ≤ log₂(E[|Xᵧ|])

And thus:

    1 ≤ 2^H(X|Y) ≤ E(|Xᵧ|).

∎
 
For the die roll example of the previous section, `H(X|Y) = log₂3` and thus
`E[|Xᵧ|] ≥ 2^log₂3 = 3`.


## Mutual Information

**Definition**. The quantity `I(X;Y) = H(X) - H(X|Y)` is known as **mutual
information** between `X` and `Y` and represents how many bits of information
relative to `X` the observation of `Y` yields. Obviously `0 ≤ I(X;Y) ≤ H(X)`.

- `I(X;Y) = 0` when the two events are independent (`H(X|Y) = H(X)`).
- `I(X;Y) = H(X)` when the observation of `Y` completely determines the value of
  `X` (`H(X|Y) = 0`)

**Proposition**. `I(X;Y) = I(Y;X)`

*Proof*. For the chain rule:

    H(X,Y) = H(X) + H(Y|X)  →  H(Y|X) = H(X,Y) - H(X)
    H(Y,X) = H(Y) + H(X|Y)  →  H(X|Y) = H(X,Y) - H(Y)

    I(X;Y) = H(X) - H(X|Y) = H(X) - H(X,Y) + H(Y)
    I(Y;X) = H(Y) - H(Y|X) = H(Y) - H(X,Y) + H(X)

∎

Example for the die roll with `Y = 0` if `X` is even and `Y = 1` otherwise:

    I(X;Y) = H(X) - H(X|Y) = log₂6 - log₂3 = 1
    I(Y;X) = H(Y) - H(Y|X) = log₂2 - 0 = log₂2 = 1


## Kullback-Leibler Divergence

Also known as KL relative entropy, it provides a measure of how much two
probability distributions are different from each other.

Given two probability distributions `p` and `q` defined for the over the same
variable `X`, the Kullback-Leibler divergence measures some kind of distance
between the two distributions.

    D(p||q) = ∑ₓ p(x)·log₂(p(x)/q(x))  ∀x ∈ X

With the conventions that:

    0·log₂(0/q(x)) = 0      for q ≥ 0
    p(x)·log₂(p(x)/0) = +∞  for p > 0

The second condition is indeed a limitation, as the distance can be infinite
wherever `q(x) = 0` and `p(x) ≠ 0` for some `x`.

Note that it is not a distance in the strict mathematical sense of the term,
as triangle inequality doesn't hold and `D(p||q) ≠ D(q||p)`.

Theorem. **Gibbs Inequality**

    D(p||q) ≥ 0, with D(p||q) = 0 iff p = q

*Proof*

Given that `log₂x = logₑx/logₑ2`, we'll use `logₑ` instead of `log₂` as `logₑ2`
only scales the relation we want to prove by a constant factor.

Because `logₑx ≤ x - 1` for all `x > 0`, with equality iff `x = 1`, We have:

    D(p||q) = -∑ₓ p(x)·logₑ(q(x)/p(x)) ≥ -∑ₓ p(x)·(q(x)/p(x) - 1) 
                                       = -∑ₓ q(x) + ∑ₓ p(x) = 1 - ∑ₓ q(x)

In the sums we consider only the indexes for whom `p(x) > 0`, follows that some
non-zero `q(x)` values may have been excluded from the sums and thus
`0 ≤ ∑ₓ q(x) ≤ 1`. The thesis follows.

∎

`logₑx ≤ x - 1` can be easily proven using calculus to study the critical points
of the function `f(x) = x - logₑx - 1` (i.e. find local minima using derivative).

### Application to Hypothesis Testing

Hypothesis testing is a statistical technique where we are required to
choose between two hypotheses: `H₀` and `H₁` who correspond to two possible
distributions `p` and `q`.

Given a random variable `X` we want to decide if it follows the distribution
`p` or `q`, and thus to check which of the hypothesis is correct.

`H₀` is called **null hypothesis** and `H₁` is called **alternative hypothesis**.

A test *statistic* is a single value computed from a sample of data summarizing
some aspects of the sample and used to make inferences about the population.
Example statistics are the *mean*, *median* and *mode* of a dataset.

The hypothesis testing process involves computing a test statistic and
determining the corresponding *p-value*, which represents the probability of
observing a test statistic as extreme or more extreme than the one calculated,
assuming the null hypothesis is true.

#### Log-Likelihood Ratio (LLR)

For each independent event `x ∈ X` we compute:

    LLR = log₂(p(x)/q(x))

For each event:
- If `LLR > 0` (`p(x)/q(x) > 1`), then the event `x` is more probable under `H₀`;
- If `LLR < 0` (`p(x)/q(x) < 1`), then the event `x` is more probable under `H₁`
- If `LLR = 0`, then is equally likely under `H₀` and `H₁`.

We then calculate the `LLR` empirical expected value as:

    E[LLR] = ∑ₓ freq(x)/|X| · log₂(p(x)/q(x)), ∀ x ∈ X

With `freq(x)` the empirical frequency of `x` in the sample.

- If `H₀` is true then `E[LLR]` converges to `∑ₓ p(x)·log₂(p(x)/q(x)) = D(p||q)` 
- If `H₁` is true then `E[LLR]` converges to `∑ₓ q(x)·log₂(p(x)/q(x)) =
                                         -∑ₓ q(x)·log₂(q(x)/p(x)) = -D(q||p)`

Follows that if `H₀` is true `E[LLR] ≥ 0` else `E[LLR] < 0`

Note that the test can fail:
- **False positive**: if we incorrectly reject `H₀`.
- **False negative**: if we incorrectly accept `H₀`. 

#### Chernoff-Stein Lemma

The decision error probability respects the following laws (`k = |X|`):
1. The false positive probability `𝛼` decreases asymptotically as `2^(-k·D(q||p))`
2. The false negative probability `𝛽` decreases asymptotically as `2^(-k·D(p||q))`

In both cases we assume that both `D(p||q)` and `D(q||p)` are less than `+∞`.

Because in general `D(p||q) ≠ D(q||p)` then `𝛼 ≠ 𝛽`.

Example with coin toss:

    p = {1/2, 1/2},  q = {3/5, 2/5}
    D(p||q) = 1/2·log₂(1/2·5/3) + 1/2·log₂(1/2·5/2) ≈ 0.029
    D(q||p) = 3/5·log₂(3/5·2/1) + 2/5·log₂(2/5·2/1) ≈ 0.093

    𝛼 ≈ 2^(-k·0.093) , 𝛽 ≈ 2^(-k·0.029)

Using these estimations we can arbitrarily lower the error probability,
for example:

    𝛼 ≈ 2^(-k·D(q||p)) < ε → k > -log₂ε/D(q||p)


## Cross Entropy

When we decide what is the optimal encoding for a data source `X` that we
empirically observed then we may end up using a distribution `q` that is not
equal to the real distribution driving the data source `p`.

Using the code determined by `q` when the real distribution is `p` gives us an
average encoding length for the symbols of the language:

    H(p||q) = ∑ₓ p(x)·|c(x)| ≈ ∑ₓ p(x)·log₂(1/q(x))

Where `|c(x)|` is the encoding length of the symbol `x`.

In general:
- `H(X; p||q)` is not an entropy value (in the strict sense)
- `H(X; p||q) ≠ H(X; q||p)`
- `H(X) ≤ H(X; p||q)`

The last statement proof is a corollary of Gibb's inequality:

    D(p||q) = ∑ₓ p(x)·log₂(p(x)/q(x)) = ∑ₓ p(x)·(log₂p(x) - log₂q(x))
            = ∑ₓ p(x)·log₂p(x) - ∑ₓ p(x)·log₂q(x) ≥ 0

    → ∑ₓ p(x)·log₂p(x) ≥ ∑ₓ p(x)·log₂q(x)
    → H(X) = -∑ₓ p(x)·log₂p(x) ≤ -∑ₓ p(x)·log₂q(x) = H(X; p||q)

**Linking Identity**:

    H(X; p||q) = H(X) + D(p||q)

*Proof*. Let's assume that `q(x) ≥ 0`.

    H(X; p||q) = ∑ₓ p(x)·log₂(1/q(x))
               = ∑ₓ p(x)·log₂(1/p(x) · p(x)/q(x))
               = ∑ₓ (p(x)·log₂(1/p(x)) + p(x)·log₂(p(x)/q(x)))
               = ∑ₓ p(x)·log₂(1/p(x)) + ∑ₓ p(x)·log₂(p(x)/q(x))
               = H(p) + D(p||q)


## Other Properties

**Proposition**. Given `pₓᵧ = p(X,Y)`, `pₓ = p(X)`, `pᵧ = p(Y)`

    I(X;Y) = H(X) - H(X|Y) = D(pₓᵧ||pₓ·pᵧ)

Recall that:
- `I(X;Y) = 0` if `X` and `Y` are independent.
- `I(X;Y) = H(X)` is `X` is completely determined by `Y`.

*Proof*.

Starting from `D(pₓᵧ||pₓ·pᵧ)`, using the logarithm additive property and given
that `H(X,Y) = H(Y) + H(X|Y) → H(Y) - H(X,Y) = -H(X|Y)`

    D(pₓᵧ||pₓ·pᵧ) = ∑ₓᵧ pₓᵧ(x,y)·log₂[pₓᵧ(x,y)/(pₓ(x)·pᵧ(y))] =
                  = ... (some exapansions)
                  = H(X) + H(Y) - H(X,Y) = H(X) - H(X|Y)
                  = I(X;Y)
∎

**Proposition**. Observing an event, in general, doesn't increment the entropy
of another event.

    0 ≤ H(X|Y) ≤ H(X)

*Proof*

First inequality follows from `H(X|Y)` definition, a sum of positive quantities.
Second inequality proof: `H(X|Y) = H(X) - I(X;Y) = H(X) - D(pₓᵧ||pₓ·pᵧ) ≤ H(X)`.

∎

**Corollary**.

    H(X,Y) ≤ H(X) + H(Y)

*Proof*

    H(X,Y) = H(X) + H(Y|X) ≤ H(X) + H(Y)

∎

The equality holds when `X` and `Y` are independent.

**Corollary**.

    I(X;Y) ≥ 0

*Proof*. Follows because it is equal to `D(pₓᵧ||pₓ·pᵧ)` and the Gibbs
inequality. The equality to `0` holds when `pₓᵧ = pₓ·pᵧ`, i.e. when `X` and `Y`
are independent.

∎

Practical consideration. If we construct a compression code that operates
on *digrams*, but we don't know the exact distribution of the couples in the
language of choice, we may decide to approximate `pₓᵧ` with `pₓ·pᵧ`.

Because in a natural language `X` and `Y` are not independent, the encoding
in this case can't be optimal, and the extra bits used by our code are exactly
`D(pₓᵧ||pₓ·pᵧ)`.

*Example*. (somehow counterintuitive) Observation of an event which increments
the entropy

    X ∈ { 1,..,6}
    p(1) = 1-10⁻⁹ and p(k) = 1/5·10⁻⁹ for k ≠ 1
    H(X) ≈ 0 since it is very probable that X = 1

    If we find out that the result is one (not specified) z ≠ 1, then

    p(1|z) = 0
    p(x|z) = 1/5, for x≠1

    H(X|z) = -∑ p(x|z)·log₂p(x|z) = -5·1/5·log₂(1/5) = log₂5 ≈ 2.32
    → H(X|z) ≥ H(X)

**Important**. The proposition `H(X|Y) ≤ H(X)` is still valid since it refers to
the expected value over all the possible values of `Y` and not to the entropy of
`X` after one specific event `y ∈ Y`.


## Appendix - Jensen's Inequality

For any differentiable concave function `f` and random variable `X`

    E[f(X)] ≤ f(E[X])

*Proof*

For a concave function `f` and any `x` and `y`:

    (f(x) - f(y))/(x - y) ≤ f'(x) 
    → f(x) ≤ f(y) + f'(x)·(x - y)

Let `x = X` and `y = E[X]`. We can write

    f(X) ≤ f(E[X]) + f'(X)·(X - E[X])

This inequality is true for all `X`, so we can take the expected value on both
sides to get

    E[f(X)] ≤ f(E[X]) + f'(E[X])·E(X - E[X]) = f(E[X])

∎
    

## References

- Douglas Stinson, [Cryptography Theory and Practice](https://www.taylorfrancis.com/books/mono/10.1201/9781315282497/cryptography-douglas-robert-stinson-maura-paterson)
