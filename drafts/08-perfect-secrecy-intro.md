+++
title = "Introduction to Unconditional Security"
date = "2023-08-30"
modified = "2023-08-30"
tags = ["cryptography", "draft"]
toc = true
draft = true
+++

Unconditional security, a concept pioneered by *Claude Shannon* in 1949,
embodies cryptographic systems immune to cryptanalysis, even with unlimited
computational power.

Shannon's groundbreaking work laid the foundation for designing information
safeguards that persistently ensure confidentiality, regardless of evolving
technological landscapes.


## Unconditional Security Foundations

We define the following **aleatory variables**:
- `M` taking values from plaintext set.
- `C` taking values from ciphertext set.
- `K` taking values from key set.

Each variable has a known probability distribution: `p(M)`, `p(K)`, `p(C)`.

- `M` and `K` are independent variables.
- `C` is function of `M` and `K`, i.e. `C = E(K, M)`
- If we fix a message `m ∈ M` then the value of `c ∈ C` depends only on `k ∈ K`.
  But this alone doesn't imply that `M` and `C` are independent variables.

Even if `M` and `K` are independent, the function `E` may generate a `c ∈ C`
which may be more or less dependent on `m ∈ M`.

From now on, when is clear from the context, we're going to write `p(M = m)` as
`p(m)`, the same applies for `C` and `K` variables.

**Unconditional Secrecy**. For Shannon, a cipher is **perfect** if for all
`m ∈ M` and `c ∈ C`: `p(M=m|C=c) = p(M=m)`.

That is, observing the value of `c` doesn't leak any information about `m`, in
other words `M` and `C` are independent variables.

Note that this doesn't say anything about the probability distribution of `M`.
If some plaintext is more probable of being used its probability remains the
same.

**Proposition**. In a perfect a cipher `|M| ≤ |K|`

*Proof*

We know that for every cipher (perfect or not) for injectivity requirement of
encryption function `|M| ≤ |C|`.

If for absurd (in a perfect cipher) `|K| < |M|`, then `|K| < |C|`

If we fix a message `m`, such that `p(m) > 0`, then we have that there exist a
ciphertext `c'` for which it doesn't exist any key `k` such that `E[k, m] = c'`,
and thus `0 < p(m) ≠ p(m|c') = 0`. The cipher can't be perfect. 

∎

**Corollary**. In a perfect cipher `|K| ≥ |C|`.

Note that is not required to have `|M| = |C|`. Even if `M < C` we can still
associate each message to each plaintext as far as `|K| ≥ |M|`.


## One Time Pad (Vernam Cipher)

The OTP cipher is defined over:
- Alphabet `A = { 0, 1 }`
- Plaintext `M ⊆ A*`
- Ciphertext `C ⊆ A*`
- Keyspace `K ⊆ Aⁿ`

With `A*` the set of binary strings with length less than or equal `n` and `Aⁿ`
the set of binary strings of length `n`.

As usual, there is a known probability distribution `p(M)`, we can't do anything
about it (e.g. if `m ∈ M` is an English text then it will follow the known
distribution for English letters).

For `p(K)` we can instead choose the probability distribution, obviously we're
going to use the uniform random distribution: `p(k) = 1/2ⁿ`.

Encryption and decryption procedures are defined as bitwise xor of the input
binary string with the key binary string:

    Eₖ(m) = m ⊕ k = c
    Dₖ(c) = c ⊕ k = m

Even though different elements of `M` have different probabilities these don't
influence the ciphertext probabilities that are driven only by the key uniform
distribution.

For example:

    |K| = 2⁴, M = { 0101, 1010 }, p(M = 0101) = 3/4, p(M = 1010) = 1/4

Regardless of the value of `m`, the ciphertext `c` has the same probability to
be one of the `2⁴` possible values.

**Proposition**. OTP is unconditionally secure:

    p(m|c) = p(m).

*Proof*

For Bayes theorem:

    p(m|c) = p(c|m)·p(m)/p(c)

For a fixed pair of `c` and `m`, in OTP there exists a unique key `k` such that
`Eₖ(m) = c`. Follows that for a fixed `m` the probability that it encrypts to
`c` is equal to the probability to choose `k`:

    p(c|m) = p(k) = 1/2ⁿ
        
To compute `p(c)`:

    p(c) = p(c,m₁) + .. + p(c,mₙ)
         = p(c|m₁)·p(m₁) + .. + p(c|mₙ)·p(mₙ)
         = 1/2ⁿ · (p(m₁) + .. + p(mₙ))
         = 1/2ⁿ

∎

### Reusing the Key

If we want to preserve the perfect-secrecy property for different messages
encryption then we must choose a new key:

    c₁ = m₁ ⊕ k
    c₂ = m₂ ⊕ k
    c₁ ⊕ c₂ = m₁ ⊕ m₂

For example, if we know `m₁` and `c₁`, then `p(m₁|c₂) = 0`, regardless of `p(m₁)`.

Reusing the key, also makes OTP extremely weak as it easily
[leaks information](https://crypto.stackexchange.com/questions/59/taking-advantage-of-one-time-pad-key-reuse)
e.g. with pictures or using **crib-dragging** attack.


## Latin Squares

Latin squares are tables constructed such that in every row and column there are
the same set of elements. For example:

        ⌈ 1 2 3 ⌉
    E = | 3 1 2 |
        ⌊ 2 3 1 ⌋

Given a Latin square of size `N⨯N` we define the sets `K`, `M` and `C` with a
size of `N`. We also need to assign an index `i` to each element of the sets,
that is, we are going to consider them as ordered sets. The sets are ordered
independently.

To encrypt an element `m ∈ M` with a key `k ∈ K` we use the encryption table `E`
using `k` and `m` as row and column indices respectively:

    E(k,m) = c,  (example: E(2,1) = 3)

The decryption table `D` is easily derived from the encryption table:

    E(1,1) = 1, E(1,2) = 2, E(1,3) = 3
    D(1,1) = 1, D(1,2) = 2, D(1,3) = 3

    E(2,1) = 3, E(2,2) = 1, E(2,3) = 2
    D(2,3) = 1, D(2,1) = 2, D(2,2) = 3

    E(3,1) = 2, E(3,2) = 3, E(3,3) = 1
    D(3,2) = 1, D(3,3) = 2, D(3,1) = 3

        ⌈ 1 2 3 ⌉
    D = | 2 3 1 |
        ⌊ 3 1 2 ⌋

**Proposition**. The Latin square cipher is a perfect cipher.

In practice, a Latin square is a generalized OTP where the encryption function
may not be driven by the xor operation.

The one time pad is a particular Latin square where the association between the
cipher elements is driven by the xor function. In a general Latin square this
association is completely arbitrary.

Follows the Latin square for OTP with key length 2:

            00 01 10 11
          +------------
       00 | 00 01 10 11        0 1 2 3
       01 | 01 00 11 10   <=>  1 0 3 2
       10 | 10 11 00 01        2 3 0 1  
       11 | 11 10 01 00        3 2 1 0

As far as the key (the row index) is chosen randomly the ciphertext and the
plaintext are independent, and thus we can apply the same proof used for OTP.
