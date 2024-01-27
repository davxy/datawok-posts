+++
title = "Chinese Remainder Theorem"
date = "2017-10-02"
modified = "2023-12-11"
tags = ["cryptography","number-theory"]
+++

The Chinese Remainder Theorem (CRT) is a mathematical theorem that provides an
efficient way to solve systems of linear congruences.

Specifically, it states that given a set of integers that are pairwise coprime
and a set of remainders modulo those integers, there exists a unique solution,
modulo the product of the integers, to the system of congruences.

The theorem has practical applications in cryptography. For example, to optimize
RSA secret key operations and to construct threshold secret sharing schemes.


## Theorem

Given `m = m₁·m₂·...·mₖ`, with `(mᵢ,mⱼ) = 1` for all `i ≠ j`.

And a system of `k` equations:

    x ≡ a₁ (mod m₁)
    ...
    x ≡ aₖ (mod mₖ)

The system has a unique solution `x ∈ Zₘ`.

*Existence* (by construction)

By hypothesis, `mᵢ|m` and `(m/mᵢ,mᵢ) = 1` then `m/mᵢ` has multiplicative
inverse modulo `mᵢ`.

    cᵢ = m/mᵢ · [(m/mᵢ)⁻¹ mod mᵢ]

    x = ∑ aᵢ·cᵢ , for i in 1...k

If `i = j` then `cᵢ mod mⱼ = 1` else `cᵢ mod mⱼ = 0`. Follows that:

    x mod m₁ = a₁·1 + a₂·0 + ... + aₖ·0 = a₁
    ...
    x mod mₖ = a₁·0 + a₂·0 + ... + aₖ·1 = aₖ

∎

*Uniqueness*

Assume there are two solutions `x₁` and `x₂`, then `∀ i in 1..k`:

    x₁ mod mᵢ = aᵢ  → x₁ = mᵢ·w + aᵢ
    x₂ mod mᵢ = aᵢ  → x₂ = mᵢ·k + aᵢ
    → x₁ - x₂ = mᵢ·(w - k) → mᵢ|(x₁ - x₂)

Given that `(mᵢ,mⱼ) = 1` and both `mᵢ|(x₁ - x₂)` and `mⱼ|(x₁ - x₂)` then
`(mᵢ·mⱼ)|(x₁ - x₂)`.

Follows that `(m = m₁·m₂⋅...·mₖ)|(x₁ - x₂)` and thus `x₁ ≡ x₂ (mod m)`.

∎

Note: it is important when computing the solution `x` to **don't** reduce `m/mᵢ`
modulo `mᵢ`, just the inverse.


## Arithmetic

Given that there is a unique solution, the transformation to *vectored form*
is a bijection, and thus we are allowed to perform computations in the vectored
form and go back to the normalized form when finished.

A value `a ∈ Zₘ` is first **uniquely** mapped into the smaller components:

    a ↔ (a₁, ... , aₖ) = (a mod m₁, ... , a mod mₖ)

Then we operate over the smaller components without loosing any information.

For example, if we want to add or multiply two values `a` and `b` in `Zₘ`:

    a ↔ (a₁, ..., aₖ) = (a mod m₁, ..., a mod mₖ)
    b ↔ (b₁, ..., bₖ) = (b mod m₁, ..., b mod mₖ)

We operate on the single components, and finally we map back to obtain `a+b`
and `a·b` modulo `m`.

    a+b ↔ (a₁+b₁, ..., aₖ+bₖ) = (a+b mod m₁, ..., a+b mod mₖ)
    a·b ↔ (a₁·b₁, ..., aₖ·bₖ) = (a·b mod m₁, ..., a·b mod mₖ)

The result holds because the modulo operation is homomorphic with respect to
both the operations when applied between the sets `Zₘ` and `Zₘᵢ`:

    (a·b mod m) mod mᵢ = (a mod mᵢ · b mod mᵢ) mod mᵢ

And the uniqueness of the solution imposed by the CRT

Doesn't matter if we first reduce the result modulo `m` and then modulo `mᵢ`, given that:

    z = m·q + r = m₁·..·mₖ·q + r
    → (z mod m) mod mᵢ = r mod mᵢ
    and also
    → z mod mᵢ = r mod mᵢ

In the end, via the CRT we've found the unique solution `x = a+b ∈ Zₙ` such that:

    x mod mᵢ = (a mod mᵢ + b mod mᵢ) mod mᵢ

### Example

    m₁ = 9, m₂ = 10, m = 90

To vectored form:

    a = 73 → (73 mod 9, 73 mod 10) = (1, 3)
    b = 84 → (84 mod 9, 84 mod 10) = (3, 4)

    a·b = x → (1·3 mod 9, 3·4 mod 10) = (3, 2)

Resolve the system:

    x = 3 (mod 9)
    x = 2 (mod 10)

Using the existence proof formula:

    x = 3 · 90/9 · [(90/9)⁻¹ mod 9] + 2 · 90/10 · [(90/10)⁻¹ mod 10]
      = 3·10·1 + 2·9·9 = 192 ≡ 12 (mod 90)

We've found that `a·b = 12 (mod 90)`


## Some Applications

### RSA CRT Speed-up

The technique is applicable to RSA when we know the modulus prime factors
`p` and `q`, thus it is generally applicable to the decryption and signing
procedures.

If we have a number `a ∈ Zₙ` then we map it to `(a mod p, a mod q)`.

We end up working with numbers having approximately half the digits of the
original number.

Instead of performing one single exponentiation modulo `n`, we perform two
exponentiation modulo `p` and `q`. For example, for digital signature if `d` is
the secret exponent:

    s₁ = mᵈ mod p = m^(d mod p-1) mod p
    s₂ = mᵈ mod q = m^(d mod q-1) mod p

Then write the following system of two equations:

    s ≡ s₁ (mod p)
    s ≡ s₂ (mod q)

According to the CRT the solution `s` to the system is unique and turns out to
be the value we want to compute (i.e. `mᵈ mod n`).

#### Performance analysis

The cost of multiplying two numbers with `k` bits is `≈ k²`.

Because the exponent has `k` bits, the cost to perform `mᵈ` using the square
and multiply algorithm is approximately the cost of performing `k` iterations
where each iteration has a cost of `k²` (we assume that we do a multiplication
on each iteration). Thus, the total cost is `≈ k³`.

By using the CRT optimization, we execute two modular exponentiation
`m^(d mod p-1) mod p` and `m^(d mod q-1) moq q`. Given that `p` and `q` have
approximately `k/2` bits the cost of each multiplication is `≈ (k/2)²`.
Since there are `k/2` iterations, the cost for performing one exponentiation
is thus `≈ (k/2)³ = k³/8`. As two exponentiation are required, the total
cost is `≈ k³/4`.

Using the CRT can thus result in a `4x` speedup.

### Euler's Totient Proof

Given two numbers `m₁` and `m₂` such that `(m₁,m₂) = 1` and `m = m₁·m₂`, we want
to prove that `φ(m) = φ(m₁)·φ(m₂)`.

This is equivalent proving that there exist a bijection from `Zₘ*` to `Zₘ₁* × Zₘ₂*`.

    f: Zₘ* → Zₘ₁* × Zₘ₂*

We define such function as:

    f(x) = (x mod m₁, x mod m₂)

Starting from a number `x ∈ Zₘ*` then `x mod mᵢ` is clearly in `Zₘᵢ`.
But we require that `x ∈ Zₘᵢ*`.

*Proof*

Since `x ∈ Zₙ*`, by hypothesis we know that `(x,m) = (x, m₁·m₂) = 1` and thus
`x` doesn't have any common factor with both `m₁` and `m₂`.

For Euclidean algorithm `1 = (x,mᵢ) = (mᵢ, x mod mᵢ)` and thus `x mod mᵢ ∈ Zₘᵢ*`.

*Injectivity*

Let `x₁`, `x₂` be two elements of `Zₘ*`.

If `f(x₁) = f(x₂) = (a₁, a₂)` then `x₁` and `x₂` are both solutions for the system:

        x ≡ a₁ (mod m₁)
        x ≡ a₂ (mod m₂)

For the CRT the solution `x ∈ Zₘ*` is unique, thus `x₁ = x₂`.

*Surjectivity*

For each `aᵢ ∈ Zₘᵢ*` for CRT there exist a unique solution `x ∈ Zₘ`.

Because `(mᵢ, aᵢ = x mod mᵢ) = 1` then for Euclidean algorithm `(x, mᵢ) = 1`.

`x` doesn't have any common factor with any `mᵢ` and thus doesn't have any
common factor with `m = m₁·m₂`. Follows that `x ∈ Zₘ*`.

∎

Iterating the procedure proves that `φ(∏ mᵢ) = ∏ φ(mᵢ)` when the `mᵢ`s are
pairwise coprime.


## References

- [RSA Cipher](/posts/rsa-cipher)
- [Euler's Totient](/posts/euler-totient)
