+++
title = "Birthday Paradox"
date = "2023-03-29"
modified = "2023-12-15"
tags = ["cryptography","probability"]
toc = true
+++

The birthday paradox is a surprising statistical phenomenon that shows how even
in a small group, it's very likely that two people share the same birthday.

In this blog post, we'll explore the math behind the paradox and its practical
applications in computer science and cryptography.

## The Paradox

As a flagship example, it states that in a group of just 23 people, there is a
50% change that two of them will share the same birthday.

This probability, which seems quite high, may come as a surprise to many,
however it can be easily explained by the principles of probability.

The paradox is a classical example of how probability can lead to seemingly
counterintuitive conclusions and is a great illustration of how probability
can be used in everyday life.

### Probability

The probability of the Birthday Paradox is computed by considering the number
of possible pairs of people in a group and the probability that any of these
people will have **different** birthdays.

To calculate the probability that any two people in a group of `n` will have
different birthdays, we can use the formula:

    p(different birthdays) = 365/365 ⋅ 364/365 ⋅ ... ⋅ (365-n+1)/365
                           = 365! / [(365-n)!⋅365ⁿ]
    
To find the probability that at least two people in the group will have
the same birthday, we can take 1 minus the probability that they all have
different birthdays

    p(same birthday) = 1 - p(different birthdays)

Some results:

  |  n |  p(n) |
  |----|-------|
  | 10 | 0.117 |
  | 20 | 0.411 |
  | 23 | 0.507 |
  | 40 | 0.891 |
  | 70 | 0.999 |


## Generalized Problem

Given a year of `d` days we want to determine the smaller number `n` such that
the probability of a birthday coincidence is at least `50%`.

In other words n is the minimal integer such that:

    1 - (1-1/d)⋅(1-2/d)..(1-(n-1)/d) ≥ 1/2

Which is equivalent to:

    (1-1/d)⋅(1-2/d)..(1-(n-1)/d) ≤ 1/2

As an approximation, `∏ (1 - i/d) ≈ 1/2` for:

    n ≈ ⌈√(2·d·ln(2))⌉

This approximation is derived using the *Taylor* expansion of the exponential
function and is valid for large `d`.

*Proof*

    ∏ (1 - i/d) ≈ exp[ ln( ∏ (1 - i/d) ) ] = exp[ ∑ ln(1 - i/d) ]

Taylor expansion for `ln(1 - x)` around `x = 0` which is `ln(1-x) ≈ -x`.

    ∑ ln(1- i/d) = -∑ i/d = -n·(n-1)/(2·d)

    → ∏ (1 - i/d) ≈ exp[ -n·(n-1)/(2·d) ]

Equate to `1/2` which is the target value

    exp[ -n·(n-1)/(2·d) ] ≈ 1/2
    → -n·(n-1)/(2·d) ≈ ln(1/2) = -ln(2)
    → n²-n ≈ 2·d·ln(2)

For large enough `n` we can omit the subtraction

    → n² ≈ 2·d·ln(2)
    → n ≈ √(2·d·ln(2))
    
∎

Note that the classical birthday problem is an instance of this problem with
`d = 365` and gives as a result `n = 23`.

### Collision Probability

Given `n` items drawn from a set of `d` elements, we look for the probability
`p(n)` that at least two numbers are equal.

The generic formula is derived using the same argument given in the previous
section:

    p(n) = 1 - (1-1/d)⋅(1-2/d)..(1-(n-1)/d)

Conversely, `n(p)` denotes the number of items drawn from a set of `d` elements
to obtain a probability `p` that at least two numbers are the same, then:

    n(p) ≈ √(2·d·ln(1/(1-p)))

The proof of this formula is similar to the one given in the previous section
for `p = 1/2`.

When applied to hash functions this is the expected number of `N`-bit hashes
that can be generated before getting a collision with probability `p`.

Surprisingly, for `p = 1/2` this is not `O(2ᴺ)`, but rather only `O(√(2ᴺ))`.

There are a number of attacks to crypto systems which leverages this fact.


## Attack

The birthday paradox can be particularly insidious if the hash is used as a
primitive building block for a more complex scheme which heavily relies on the
collision resistance property of some hash function.

For example, if an attacker discovers two messages `m₁` and `m₂` such that
`H(m₁) = H(m₂)`, he can submit `m₁` to the victim in order to have it signed,
thus obtaining a signature for `H(m₁)`, but this is a valid signature for
`H(m₂)` as well.

If the number of possible outputs of `H` is `2ᴺ`, a technique to find a
collision is:
- Construct `k = 2^(N/2)` variants of a legit message `m₁`.
- Use the same technique to construct `k` variants of a malicious message `m₂`.
- Construct two sets of digests: `A = {H(m₁ᵢ)}`, `B = {H(m₂ᵢ)}`.
- Search for any item in `A ∩ B`.

The variants can be constructed with a technique which generates messages
with changes which are not detectable from a typical renderer. For example
insert the same number of spaces and backspaces after a word.

By inserting `100` spaces around the message the attacker can construct
`2^100` different variants.

The probability of a collision obviously depends on `k`.

Can be proven that

    Pr(A ∩ B ≠ ∅) ≥ 1/2 if k ≥ 2^(N/2)

The number of the elements in each set corresponds to the expected number
of elements to withdraw from a set of `2ᴺ` before observing a collision with
probability `1/2`.

As `|A ∪ B| ≥ 2^(N/2)` then the probability of finding a collision is still `≈
1/2` (**it doesn't double**). Thus, there is a good chance (`≥ 1/2`) to find a
collision for two elements which belong to different sets.


### Mitigations

To reduce birthday attack risk we have to choose a value for `N` that is
sufficiently large.

Hashes like MD5 (`N=128`) or sha1 (`N=160`) are not considered secure anymore.

Another way to counter this attack is to use a MAC (a keyed hash) which bounds
the output also to a secret key `k`.

In this way an attacker cannot pre-compute offline a table of collisions, as
they do not know the secret key used in the particular context.

As a final note, always keep in mind that for **pigeon-hole principle** if the
hash possible outputs are `k`, then after `k+1` extractions we're going to have
a collision with probability `1`.


## References

- Simple PoC in Rust [here](https://github.com/davxy/crypto-hacks/tree/main/birthday-paradox)
