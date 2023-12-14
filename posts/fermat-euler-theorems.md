+++
title = "Fermat's Little Theorem and Euler's Theorem"
date = "2017-07-23"
modified = "2023-12-11"
tags = ["mathematics","number-theory"]
toc = true
+++

Fermat's Little Theorem, a precursor to Euler's, provides a simple yet powerful
relationship between prime numbers and modular exponentiation.

Euler's Theorem generalizes this relationship to all integers, offering a
broader perspective on modular arithmetic.

Both theorems provide mathematical properties and tools that are key building
blocks for many cryptographic primitives and protocols.


## Fermat's Little Theorem

Given two numbers `a` and `p` such that `p` is prime and `(a,p) = 1`, then

    a^(p-1) ≡ 1 (mod p)

*Proof*.

First we need to prove equality of the sets:

    Zₚ* = { 1, 2, 3, ..., p-1 }

    X = { 1·a mod p, 2·a mod p, ... , (p-1)·a mod p }

*Proof* that `X ⊆ Zₚ*`:
  
Since `(a,p) = 1` and `(j,p) = 1`, for all `j ∈ Zₚ*`, using the EEA:

    1 = a·x + p·y
    1 = j·z + p·k
    →  1 = a·j·w + p·u  →  w is inverse of a·j modulo p 
    →  (a·j,p) = 1

For Euclidean algorithm: `1 = (a·j, p) = (p, a·j mod p)`.
Follows that `a·j mod p ∈ Zₚ*`.

*Proof* that `X = Zₚ*` by showing that if `a·i ≡ a·j (mod p)` then `i = j`:

    a·i ≡ a·j (mod p)
    → since (a,p) = 1 there exists the inverse of a modulo p
    → i ≡ j (mod p) and because both i, j < p follows that i = j

Because `X = Zₚ*` we can now write:

    (p-1)! = (a mod p)·(2·a mod p) · ... · ((p-1)·a mod p)
    → (p-1)! ≡ (a mod p)·(2·a mod p) · ... · ((p-1)·a mod p) (mod p)
             ≡ (a · 2·a · ... · (p-1)·a) (mod p)
             ≡ a^(p-1) · 1·2·(p-1) (mod p)
             ≡ a^(p-1) · (p-1)! (mod p)

Every factor in `(p-1)!` is invertible modulo `p`, thus the thesis follows.

∎

### Corollary

Given `a` and `p` with `p` prime and `(a,p) = 1`. Then, for any integer `k`

    aᵏ ≡ a^(k mod p-1) (mod p)

*Proof*

For the *division theorem*, there are unique `q` and `r` such that:

    k = (p-1)·q + r,  with r = k mod p-1

    aᵏ = a^[(p-1)·q + r] = a^[(p-1)·q] · aʳ

For the *Fermat's Little Theorem* `a^(p-1) ≡ 1 (mod p)`, then:

    aᵏ ≡ 1𐞥 · aʳ ≡ aʳ (mod p)

∎


## Euler's Theorem

Given `n ≥ 1` and `(a,n) = 1` then:

    a^φ(n) ≡ 1 (mod n)

With `φ(n)` the [Euler's *totient*](/posts/euler-totient) function, which counts
the number of elements in `Zₙ` that are coprime to `n` (`|Zₙ*|`).

*Proof*

Similarly to the *Little Fermat theorem*, first we need to prove the equality of
the sets:

    Zₙ* = { x₁, x₂, ..., x_φ(n) }

    X = { a·x₁ mod n, a·x₂ mod n, ..., a·x_φ(n) mod n }

*Proof* that `X ⊆ Zₙ*`:

Given that `(a,n) = 1` and `(xᵢ,n) = 1`

    1 = a·w + n·z
    1 = xᵢ·k + n·y = 1
    → 1 = a·xᵢ·u + n·q   (u is the inverse of a·xᵢ modulo n)
    → (a·xᵢ,n) = 1

For the Euclidean algorithm:

    1 = (a·xᵢ, n) = (n, a·xᵢ mod n)

Thus `a·xᵢ mod n ∈ Zₚ*`

*Proof* that `X = Zₙ*`:

    a·xᵢ ≡ a·xⱼ (mod n)
    → since (a,n) = 1 there exists the inverse of a modulo n
    → xᵢ ≡ xⱼ (mod n) and because both xᵢ, xⱼ < n follows that xᵢ = xⱼ

Because `X = Zₙ*` we can now write:

    x₁·...·x_φ(n) = (a·x₁ mod n)·...·(a·x_φ(n) mod n)

    → x₁·...·x_φ(n) ≡ (a·x₁ mod n)·...·(a·x_φ(n) mod n) (mod n)
                    ≡ (a·x₁ · ... · a·x_φ(n)) (mod n)
                    ≡ a^φ(n) · x₁·...·x_φ(n) (mod n)

Every `xᵢ` is invertible modulo `n`, thus `1 ≡ a^φ(n) (mod n)`.

∎

### Corollary

Given `a` and `n` with `(a,n) = 1`. Then, for any integer `k`:

    aᵏ = a^(k mod φ(n))  (mod n)

*Proof*

    k = φ(n)·q + r, with r = k mod φ(n)

    aᵏ = a^[φ(n)·q + r] = a^[φ(n)·q] · aʳ

For Euler's Theorem `a^φ(n) ≡ 1 (mod n)`, then:

    aᵏ ≡ 1𐞥 · aʳ ≡ aʳ (mod n)

∎

## References

- [Euler's totient](/posts/euler-totient)
- [Euclidean algorithm](/posts/euclidean-algorithm)
