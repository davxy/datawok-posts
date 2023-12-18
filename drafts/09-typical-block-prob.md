+++
title = "Probability of Typical Blocks"
date = "2023-08-20"
modified = "2023-08-20"
tags = ["cryptography", "draft"]
draft = true
+++

The letters of an alphabet `A`, when used in the context of a structured
language, are driven by a known probability distribution. We can thus model `A`
as a random variable.

To consider the dependencies between consecutive letters, we can consider the
probabilities of blocks of `n` letters. The probability of a block is
empirically computed using a "long enough" text. The entropy is then computed
for this distribution `H(Aⁿ)`.

Finally, to get the median entropy per single letter we divide the value by `n`.

Approximations for English alphabet:
- order `1` (single letters): `H(A) ≈ 4,26`
- order `2` (digrams): `H(A²)/2 ≈ 3`
- order `n` (for `n → ∞`): `H(Aⁿ)/n ≈ 1.5`


## Typical Block Definition

If we're using a block cipher with block length `n` then in practice this is
equivalent using an alphabet of length `|A|ⁿ`.

1. Blocks spread probabilities. For each alphabet element we switch to a
   distribution that is a lot more similar to the uniform distribution.
2. Blocks not only tend to have the same probabilities, but these probabilities
   are also small.

The more `n` is big the more the probability of each block instance is small. In
particular, it decreases exponentially regardless of the probability driving the
underlying language. The exact decrease law is still driven by the entropy of
the language we started with.

**Definition**. We say that a block `σ ∈ Aⁿ` is **typical** if within the block
the frequency of the letters is aligned to the known fixed distribution in
a language.

In other words, in a typical block we have that `∀ x ∈ A, freq(x) ≈ m·p(x)`,
with `p(x)` the probability of the letter `x` in the language distribution.

For example, given `A = {0,1}`, `Pr(0) = 1/2`, `Pr(1) = 1/2` and `m = 1000`.
A block of `1000` zeros is not typical since we expect that `freq(0) ≈ 500`.

### Typical Block Probability

The probability of a typical block is very small and decreases exponentially
with `m`.

**Proposition**. For a fixed typical block instance `σ` of length `m` we expect
its probability to be:

    p(σ) ≈ ∏ p(x)^(m·p(x)), for x ∈ A

*Proof*

For a particular block instance `β` (typical or not) the single elements `βᵢ`
are extracted randomly, thus are independent

    p(β) = p(β₁,..,βₘ) = p(β₁)·..·p(βₘ)

Note that the extraction probability of the single element `βᵢ` is still driven
by the probability of the underlying language.

The factors containing the same alphabet letter are grouped together

    = p(x)·..·p(x)·p(y)·..·p(y)·...

The number of times `β` contains the symbol `x` is `freq(x)`

    = p(x)^freq(x) · p(y)^freq(y) · ...

If `β` is a typical block, we have that `freq(x) ≈ m·p(x)`

    = p(x)^(m·p(x)) · p(y)^(m·p(y)) · ...

∎

### Typical Block Probability using Entropy

Given `H(A)` the (constant) entropy of the probability distribution of letters
in the alphabet `A` driven by the language

    H(A) = -∑ p(x)·log2(p(x)), ∀ x ∈ A

**Proposition**. For all typical blocks `σ`:

    p(σ) ≈ 2^(-m·H(A))

*Proof*

We already proven that:

    p(σ) ≈ ∏ p(x)^(m·p(x))

Given that `log(x·y) = log(x) + log(y)`, and `log(x^y) = y·log(x)`

    log2[p(σ)] ≈ log2[ ∏ p(x)^(m·p(x)) ] = ∑ log2[p(x)^(m·p(x))]
               = ∑ m·p(x)·log2(p(x)) = m·∑ p(x)·log2(p(x))
               = -m·H(A)

Follows that `p(σ) ≈ 2^(-m·H(A))`

∎

The proposition highlights how increasing the block length the probability of
a typical block decreases exponentially regardless the constant `H(A)`.

For example, using the English language (`H(A) ≈ 1.5`) and `m = 10`.
A typical block probability is `2^(-10·H(A)) ≈ 1/32768`.


## Implications to Cryptanalysis

The formula allows quantifying how is difficult to make frequency analysis on
block.

Given `σ` a typical block of `m` characters.

    λ = p(𝜎) ≈ 2^(-m·H(A))

If we have a ciphertext with `k ≥ m` characters. We divide the ciphertext in
blocks of length `m`, and then we try to make a frequency analysis.

Obviously typical blocks will be the majority of the blocks that were encrypted,
thus our frequency analysis will mostly observe typical blocks.

By extracting random blocks of length `m`, on average, before seeing the typical
block `𝜎` we need to extract `1/λ ≈ 2^(m·H(A))` blocks.

In conclusion, we can say that the frequency analysis complexity grows
exponentially, regardless of `H(A)`.
