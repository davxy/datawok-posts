+++
title = "Modular Arithmetic Basics"
date = "2021-06-04"
modified = "2023-12-09"
tags = ["number-theory","mathematics"]
toc = true
+++

## Primes Factorization

**Euclid's Theorem**. Primes are infinite.

*Proof*. Let's assume that the set of primes `P = {p₁, ..., pₙ}` is finite and
let `k = ∏ pᵢ`. If the factorization of `k+1` contains one prime `pᵢ ∈ P` then
`pᵢ|k+1`. Since `pᵢ|k` then `pᵢ|(k+1-k)=1`, which is impossible. Follows that
`k+1` is a new prime or is divisible by a prime not in `P`.

**Fundamental Theorem of Arithmetic**

Every integer `n ≥ 1` can be uniquely written as the product of primes.
That is, `n = ∏ pᵢ^eᵢ` with `eᵢ ∈ N` and `pᵢ ∈ P`.

*Proof*. Trivial, by induction.

## GCD and LCM

The greatest common divisor (`gcd`) is defined as:

    gcd(a,b) = max { d > 0: d|a and d|b }

With `a` and `b` not both zero.

*Property*. For any integer `a ∈ Z`, `gcd(a,0) = |a|` (should be positive)

The least common multiple (`lcm`) is defined as:

    lcm(a,b) = min { m > 0: a|m and b|m }

Given two integers `a` and `b` lets write both of them as the product of all the
primes `pᵢ ∈ P` that appear at least in one of the factorization of the numbers:

    a = ∏ pᵢ^eᵢ
    b = ∏ pᵢ^kᵢ

The two products may differ only for some of the exponents values. Some
exponents can be zero if such prime doesn't appear in the factorization of the
number according to the *fundamental theorem of arithmetic*.

Then we can define both the `gcd` and `lcm` as:

    gcd(a,b) = ∏ pᵢ^min{eᵢ,kᵢ)
    lcm(a,b) = ∏ pᵢ^max{eᵢ,kᵢ}

Follows that:

    a·b = gcd(a,b)·lcm(a,b)`

From now on, if the context is not ambiguous, as a shortcut we'll use the
popular notation `gcd(a,b) = (a,b)`.

**Definition**. Two integers `a` and `b` are coprime if `(a,b) = 1`.

## Division Theorem

For every integer `a` and non-zero integer `b > 0` there exist unique `q` and
`r` such that:

    a = b·q + r  with  0 ≤ r < b

Existence Proof.

Let `R = { r: r = a - b·q ≥ 0 }`, the set is not empty since `b·q` can be made
arbitrary small by taking a negative `q`. For the *well ordering principle*
there is min `r₀`. Also, `r₀ < b` because if instead `r₀ ≥ b`, then we can
define `r₁ = r₀ - b ≥ 0` and thus `r₀` was not the min.

Uniqueness Proof.

If `a = b·q' + r'` then (assuming `r ≥ r'`) `0 ≤ r - r' = b·(q' - q) ≤ r < b`.
Dividing both sides by `b` we have that `0 ≤ (q - q') < 1`.
Follows that `q - q' = 0`, thus that `q = q'` and consequently `r = r'`.

From the division theorem follows that `q` and `r` are functions of `a` and `b`.

These functions have quite popular names:
- `q = a div b` is the integer division operation result;
- `r = a mod b` is the integer modulo operation result.

The functions images also have very well known names:
- `q` is the division *quotient*
- `r` is the division *reminder*

## Congruence Classes

By definition, `a` is congruent to `b` modulo `n > 0` if `a mod n = b mod n`.

Common alternative notations for `a` congruent to `b` modulo `n` are
`a ≡ b (mod n)` or `a ≡ₙ b`.

Fixed `n > 0` then `Zₙ = { 0, ..., n-1 }` is the set of all the possible
remainders modulo `n`.

**Proposition**. `a ≡ b (mod n)` iff `n | (a - b)`

*Proof*

```
⇒   r = a - n·q₁ = b - n·q₂
    → a - b = n·(q₁ - q₂)
    → n | (a - b)

⇐   n | (a - b)
    → a - b = n·q + r, with r = 0
    → given that should exist unique q₁, r₁, q₂, r₂ such that
      a = n·q₁ + r₁ and b = n·q₂ + r₂
    → a - b = n·(q₁ - q₂) + (r₁ - r₂)
    → r = r₁ - r₂ = 0 → r₁ = r₂
```

∎

Congruence between remainder classes is an **equivalence relation**.
That is, reflexive, symmetric, transitive properties hold.

Elements in `ℤ` that are equivalent according to the congruence relation are
said to belong to the same **equivalence class**.

For example, if `a = n·q₁ + r` and `b = n·q₂ + r` then both `a` and `b` are in
the congruence class `[r]ₙ`.

If `a = n·q + r`, the set of elements in the same congruence class `[r]ₙ` are
defined as:

    [r]ₙ = { r + k·n, ∀ k ∈ Z }

The set of all the congruence classes modulo `n` is:

    Z/n = { [0]ₙ, [1]ₙ, ... , [n-1]ₙ }, with |Z/n| = n

### Set of representatives

A **complete** set of representatives refers to a specific selection of integers
chosen to represent all the different congruence classes in `Z/n`. Each congruence
class is represented by one and only once element.

Each representative can be chosen by using a different criterion, what is
important is that there is only one representative for each class.

Given a modulo `n` and a number `a`, if `r` is the integer division reminder of
`a` divided `n`, then `r` is the smallest positive value in the class `[r]ₙ` and
is often taken as the **representative** for the whole congruence class.

    Zₙ = { 0, 1, .. , n-1 }, with |Zₙ| = n

Nevertheless, in some cases makes sense to work with representatives chosen
using different criteria (e.g. bigger or negative numbers).

**Proposition**. If `{ a₁, .. , aₙ }` is a complete set of representatives,
then for any integer `b`, `{ a₁+b, .. , aₙ+b }` is a complete set of
representatives.

*Proof*

If not, then `aᵢ+b ≡ aⱼ+b (mod n)` and thus `aᵢ ≡ aⱼ (mod n)`, contradicting
the hypothesis.

∎

**Proposition**. If `{ a₁, .. , aₙ }` is a complete set of representatives for
`Zₙ`, then `{ a₁·b, .. , aₙ·b }` is a complete set of representatives iff
`(b,n) = 1`.

*Proof*

If `(b,n) = 1` and `aᵢ·b ≡ aⱼ·b (mod n)` then there exists the inverse of `b`
modulo `n`. Thus follows that `aᵢ ≡ aⱼ (mod n)`, contradicting the hypothesis.

Conversely, if `(b,n) = d`, with `1 < d < n`, then there exists a non-zero value
`z = n/d < n` such that `b·z ≡ 0 (mod n)` (note: `b` and `z` are both non-zero and
their product is `0` mod `n`, these are called **zero-divisors**).
In this case the set `{ a₁·b, .., aₙ·b }` cannot be a set of representatives
since if `0` is equal to some `aᵢ·b` then now there are two elements congruent
to `0` modulo `n` (namely `0·b` and `z·b`).

∎

Note that from the previous proof follows that if `p` is prime then `Zᵨ` doesn't
have zero-divisors and the property always hold for all `b`.

## Homomorphism

Consider the set of integers equipped with the operation sum `(Z, +)` and the
set of reminders modulo `n` equipped with the operation modular sum `(Zₙ, +ₙ)`.

The modulo operation is an homomorphism between these two sets.

That is, given `a, b ∈ Z` and setting `f(x) = (x mod n) ∈ Zₙ`.

    f(a + b) = f(a) +ₙ f(b)

    (a + b) mod n = (a mod n) +ₙ (b mod n)

*Proof*

    a mod n = r₁ = a - n·q₁
    b mod n = r₂ = b - n·q₂
    → r₁ + r₂ = a + b - n·(q₁ + q₂)
    → r₁ + r₂ ≡ a + b (mod n)

The same holds for the product:

    f(a · b) = f(a) ·ₙ f(b)

    (a · b) mod n = (a mod n) ·ₙ (b mod n)

*Proof*

    a mod n = r₁ = a - n·q₁
    b mod n = r₂ = b - n·q₂
    → r₁·r₂ = a·b - a·n·q₂ - b·n·q₁ + n²·q₁·q₂
    → r₁·r₂ ≡ a·b (mod n)

From now on, for simplicity, we'll write `+ₙ` as `+` and `·ₙ` as `·` both
followed by the `(mod n)` postfix to make the reduction modulo `n` explicit.


## Modular Arithmetic Properties

1. `a ≡ b (mod n)` iff `a+k ≡ b+k (mod n)`, for any integer `k`

*Proof* (→)

    a = q₁·n + r  and  b = q₂·n + r
    → a + c = q₁·n + (r + c)  and  b + c = q₂·n + (r + c)
    → a + c ≡ b + c ≡ r + c (mod n)

2. If `a ≡ b (mod n)` then `a·k ≡ b·k (mod n)`, for any integer `k`

The proof is quite similar to the previous. But the converse holds iff `(k,n) = 1`.

3. If `a ≡ b (mod n)` then `aᵏ ≡ bᵏ (mod n)`, for any integer `k`

*Proof* (from property 2)

    a ≡ b (mod n) → a² ≡ b·a (mod n) and a·b ≡ b² (mod n) → a² ≡ b² (mod n)
    The thesis follows by induction.

4. It is not the case that if `a ≡ b (mod n)` then `k^a ≡ k^b (mod n)`

Counter example: `3 ≡ 8 (mod 5)` but `2^3 ≢ 2^8 (mod 5)`

5. Cancellation law for addition.

    `a + c ≡ b + c (mod n)`  →  `a ≡ b (mod n)`

*Proof*: Additive inverse always exist and follows from property 1.

6. Cancellation law for multiplication holds iff `(c, n) = 1`.

Counter example: `4·8 ≡ 9·8 (mod 10)` but `4 ≢ 9 (mod 10)`.

7. If `(a,m) = 1` and `(a,n) = 1)` then `(a,m·n) = 1)`

*Proof* (using the Extended Euclidean Algorithm)

    a·s + m·t = 1` and `a·h + n·k = 1
    → a·(a·s·h + s·n·k + m·h·t) + m·n·t·k = 1
    → (a,m·n) = 1


## Multiplicative Inverse

**Proposition**. The multiplicative inverse of `a` modulo `n` exists iff `(a,n) = 1`.

*Proof*

(⇒)

Assume that `x` is the inverse of `a`, i.e. `a·x ≡ 1 (mod n)`.
Then we can write `1 = a·x + n·y`.
If `d|a` and `d|n` → `d | a·x` and `d | n·y` → `d | a·x + n·y` → `d|1`.
This can hold only if `d = 1`.

(⇐)

If `(a,n) = 1` then using the extended Euclidean algorithm we can write
`1 = a·x + n·y ≡ a·x (mod n)`. Thus, `x` is the inverse of `a` modulo `n`.

∎

**Proposition**. When the inverse exists is unique modulo `n`.

*Proof*. If `x` and `y` are both inverses of `a ∈ Zₙ` then
`a·x ≡ 1 (mod n)` → `y·a·x ≡ y (mod n)` → `x ≡ y (mod n)`

∎


## Algebraic Structures

Given `c ∈ Zₙ`:
- **additive inverse** always exists and is `n - c`
- **multiplicative inverse** exists iff `gcd(c,n) = 1`

For example, in `Z₁₀`:

    (1,10) = 1  →  1⁻¹ = 1
    (3,10) = 1  →  3⁻¹ = 7  →  3·7 = 21 ≡ 1 (mod 10)
    (7,10) = 1  →  7⁻¹ = 3  →  3·7 = 21 ≡ 1 (mod 10)
    (9,10) = 1  →  9⁻¹ = 9  →  9·9 = 81 ≡ 1 (mod 10)

We define `Zₙ*` as the set of numbers in `Zₙ` with multiplicative inverse:

    Zₙ* = { x ∈ Zₙ: gcd(x,n) = 1 }

For example, `Z₁₀* = { 1, 3, 7, 9 }`

`Zₙ*` is a **group** with respect to the product.

Closure: If `a, b ∈ Zₙ*` then `a·b = c ∈ Zₙ*`

*Proof*.

    a·b = c  →  (a·b)·(b⁻¹·a⁻¹) = c·(b⁻¹⋅a⁻¹) = c·k ≡ 1 (mod n)
    Follows that k = b⁻¹·a⁻¹ is the inverse of c and thus c ∈ Zₙ*

Note that in general `Zₙ*` **is not** a group with respect to the addition.
(For example, `1 + 3 = 4 ∉ Z₁₀*`).

If `p` is a prime number then `Zᵨ* = Zᵨ\{0}` is an abelian group with
multiplication and `Zᵨ` is an abelian group with addition.
That is `(Zᵨ*, ·)` and `(Zᵨ, +)` are both abelian groups.

Because in `Zᵨ` the distributivity of multiplication over addition holds then
`Zᵨ` is a **finite field**.

All known finite fields are `Z_(pᵏ)`, with `k ≥ 1` and `p` a prime number.
If `k > 1` then the field is called an **extension field** and its elements
are polynomials.

## Further readings

- [Euclidean algorithm](/posts/euclidean-algorithm)
- [Chinese remainder theorem](/posts/chinese-reminder-theorem)
- [Euler's totient](/posts/euler-totient)
- [Fermat's little theorem and Euler's theorem](/posts/fermat-euler-theorems)
- [Number theory and Abstract Algebra](/posts/number-theory) notes.
- **Fast Modular Exponentiation**
