+++
title = "Cryptographic Hash Functions"
date = "2023-10-20"
modified = "2023-10-20"
tags = ["cryptography", "draft"]
draft = true
+++


Intuitively, a **one-way** hash function `H(m)` is a compression function that
produces a fixed length result from an arbitrary long message.

The hash output `h = H(m)` is often called **message digest**.

First note that given an infinite number of inputs and a finite number of
possible outputs, for the **pigeonhole principle** there is at least one hash
output `h₀` and an infinite number of inputs `mᵢ` such that `H(mᵢ) = h₀`.

Cryptographic hash properties:
1. **Pre-image resistance**: given a hash `h` is computationally hard to find an
   input `m` such that `h = H(m)`.
2. **Second pre-image resistance**: given `m₁` is computationally hard to find
   `m₂` such that `H(m₁) = H(m₂)`.
3. **Collision resistance**: is computationally hard to find **any** `m₁` and
   `m₂` such that `H(m₁) = H(m₂)`

Finding a second pre-image can have serious security consequences, especially 
when the hash is used in the context of digital signatures.

Second pre-image resistance is also called **weak collision resistance**.

Collision resistance is generally considered to be the stronger property.
This is because here we don't give any bound on what the hash value should be.
This is also the measure used to evaluate a class of attack known as **birthday
attack**.

Note: (3) implies (2) implies (1)


## Merke-Damgard Construction

A popular approach to construct a cryptographic hash function using a
compression **function** `f` which takes as inputs two bit-strings with sizes
`b` and `h` and returns an output with size `h`.

The input message `m` is sliced in blocks of size `b`: `b₁..bₙ`, with the last
one optionally padded.

The hash output is recursively computed as:

    h₀ = iv
    h₁ = f(b₁, h₀)
    h₂ = f(b₂, h₁)
    ...
    hₙ = f(bₙ, hₙ₋₁)
  
With `iv` the initialization vector, a fixed public bit-string, typically part
of the algorithm definition.

The hash of the overall message `m` is thus `H(m) = hₙ`

Can be proven that if the compression function `f` is collision resistant then
`H` is collision resistant.

Thus, the primitive design in the end can be reduced in finding a function `f`
that is collision resistant. This is a simpler problem since takes as input
elements of a finite set.

Common algorithms that are using Merkle-Damgard design (less secure first):
- MD5: 128-bit digest (deprecated by NIST, very vulnerable to birthday attack)
- SHA1: 160-bit digest (deprecated by NIST)
- RIPEMD: 128/160/256/320-bit digest
- SHA2: 224/256/384/512-bit digest

### Example

Given a collision resistant compression function

    f: {0,1}²ᵐ → {0,1}ᵐ

We define a function

    g: {0,1}⁴ᵐ → {0,1}ᵐ
    g(x₁||x₂) = f(f(x₁)||f(x₂))

With `|x₁| = |x₂| = 2·m` and `x₁||x₂` the concatenation of the two strings.

We'll prove that if `f` is collision resistant then `g` is collision resistant
by proving that if `g` is not collision resistant then `f` is not collision
resistant.

*Proof*

If `g` is not collision resistant then we can find `x₁`, `x₂`, `x₁'`, `x₂'`
with `(x₁||x₂) ≠ (x₁'||x₂')` such that

    g(x₁||x₂) = g(x₁'||x₂')
    f(f(x₁)||f(x₂)) = f(f(x₁')||f(x₂'))

By hypothesis, we know that `x₁ ≠ x₁'` or `x₂ ≠ x₂'`, assume the first.

If `f(x₁) = f(x₁')` we already found a collision for `f`.

If `f(x₁) ≠ f(x₁')` then we have that (regardless of `f(x₂)` and `f(x₂')`)
`f(x₁)||f(x₂) ≠ f(x₁')||f(x₂')` thus we've found a collision for `f` in the
outer evaluation.

∎
