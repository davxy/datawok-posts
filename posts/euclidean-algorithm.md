+++
title = "Euclidean Algorithm"
date = "2017-04-16"
modified = "2023-12-10"
tags = ["number-theory","mathematics"]
toc = true
+++

A fundamental and efficient algorithm to compute the greatest common divisor
(`gcd`) of two integer numbers.

Given two integers `a` and `b`, the algorithm comes in two flavors:
- **basic**: yields the `gcd(a,b)`;
- **extended**: yields two integers `x` and `y` such that `gcd(a,b) = a·x + b·y`

As a notational shortcut from now on we'll write `(a,b)` instead of `gcd(a, b)`.

## Classic Euclidean Algorithm

### Basic

Assuming `a > b`:

    d | a  →  a = d·x
    d | b  →  b = d·y

    →  d | (a - b) = d·(x - y)

The procedure is iterated while `a ≥ b·q`, with `q > 0` an integer such that
`a < b·(q + 1)`

    b = d·y  →  b·q = d·y·q  →  d | b·q
    →  d | (a - b·q) = d·(x - y·q)

If `q` is the bigger integer such that `a ≥ b·q` then the above is saying that
`d` divides the remainder of `a` divided by `b`. In other words `d | (a mod b)`

The described procedure is equivalent to the following lemma:

**Lemma (Euclid's algorithm)**. Given `b ≥ 1`, `(a,b) = (b, a mod b)`

    d|a  ∧  d|b  ↔  d|b  ∧  d|(a mod b)

*Proof*

(⇒) `d|a  ∧  d|b`

    a = d·x  and  b = d·y
    a mod b = a - b·q ,  for max{q: a - b·q ≥ 0}
    a - b·q = d·(x - y·q)  →  d | (a mod b)

(⇐) `d|b  ∧  d|(a mod b)`

    b = d·y
    d|(a mod b) = a - b·q  →  a - b·q = d·x
    → a = d·x + q·b = d·x + q·d·y = d·(x + q·y)  →  d|a

∎

Note that if `b > a` then `(a, b) = (b, a mod b) = (b, a)`.
That is, in this case the first algorithm step has the effect of a swap.

By repeating the procedure, since the second number steadily decreases, we'll
inevitably reach the point where it is zero. And `(k, 0) = k`.

Example:

    a = 3³·5·11² = 16335
    b = 2·3·5²·7 = 1050

    (16335, 1050) = (1050, 16335 mod 1050) =
    (1050, 585) = (585, 1050 mod 585) =
    (585, 465) = (465, 585 mod 465) =
    (465, 120) = (120, 465 mod 120) =
    (120, 105) = (105, 120 mod 105) =
    (105, 15) = (15, 105 mod 15) =
    (15, 0) = 15


### Extended (EEA)

**Theorem**. *Bezout*'s Identity

Given two integers `a` and `b` with `b ≥ 1` and `d = (a,b)` there exist two
integers `x` and `y` such that `d = a·x + b·y`.

*Existence Proof*.

Consider the set `S` of all integers that can be written as `a·x + b·y`.
`S` is non-empty since it contains numbers like `a·1 + b·0 = a`,
`a·0 + b·1 = b` and `0`. For the *well ordering principle* let `d = a·s + b·t`
be the smallest positive number in `S`.

- `d` is a common divisor. For the division algorithm `a = d·q + r`, with
  `0 ≤ r < d`. Then `r = a - d·q = a - (a·s + b·t)·q = a·(1 - s·q) + b·t·q`.
  As `r = a·z + b·w` then `r ∈ S`. And because `d` is the smaller positive
  number, then `r = 0`.

- `d` is the `gcd(a,b)`. If `c` is any common divisor, since `d = a·s + b·t`
  then `c` divides `d` and thus `d` is the `gcd`.

*Construction Proof*.

Using the Euclid's algorithm, we set `r₀ = a` and `r₁ = b`

    r₀ = q₁·r₁ + r₂                 (r₀, r₁) = (r₁, r₀ mod r₁) = (r₁, r₂)
    r₁ = q₂·r₂ + r₃                 (r₁, r₂) = (r₂, r₁ mod r₂) = (r₂, r₃)
    r₂ = q₃·r₃ + r₄                 (r₂, r₃) = (r₃, r₂ mod r₃) = (r₃, r₄)
    ...
    rₙ₋₂ = qₙ₋₁·rₙ₋₁ + rₙ
    rₙ₋₁ = qₙ·rₙ + 0                (rₙ₋₁, rₙ) = (rₙ, 0)
    
    d = (rₙ, 0) = rₙ

Extended:

    r₀ = a
    r₁ = b
    r₂ = r₀ - q₁·r₁
    r₃ = r₁ - q₂·r₂
    ...
    rₙ = rₙ₋₂ - qₙ₋₁·rₙ₋₁

We can thus write `rₙ` as a linear combination of `a` and `b`.

    r₀ = x₀·a + y₀·b ,  with x₀ = 1 and y₀ = 0
    r₁ = x₁·a + y₁·b,   with x₁ = 0 and y₁ = 1
    r₂ = r₀ - q₁·r₁ = x₂·a + y₂·b
    r₃ = r₁ - q₂·r₂ = x₃·a + y₃·b
    ...
    rᵢ = rᵢ₋₂ - qᵢ₋₁·rᵢ₋₁ =
       = [xᵢ₋₂·a + yᵢ₋₂·b] - qᵢ₋₁·[xᵢ₋₁·a + yᵢ₋₁·b] =
       = [xᵢ₋₂ - qᵢ₋₁·xᵢ₋₁]·a + [yᵢ₋₂ - qᵢ₋₁·yᵢ₋₁]·b =
       = xᵢ·a + yᵢ·b
    ...
    rₙ = ... = a·xₙ + b·yₙ = d

∎

Note that:

    xᵢ = xᵢ₋₂ - qᵢ₋₁·xᵢ₋₁
    yᵢ = yᵢ₋₂ - qᵢ₋₁·yᵢ₋₁

**Corollary**. EEA can be used to compute multiplicative inverse.

*Proof*. If `1 = a·x + b·y` then `1 ≡ a·x (mod b)`, thus `x` is the
multiplicative inverse of `a` modulo `b`.

Example. Compute the inverse of `60` modulo `17`:

    r₀ = 60
    r₁ = 17

    r₂ = 60 - 3·17 = 9  (q₁ = 3)
    r₃ = 17 - 1·9  = 8  (q₂ = 1)
    r₄ =  9 - 1·8  = 1  (q₃ = 1)
    r₅ =  8 - 8·1  = 0  (q₄ = 8)

    → r₄ = (60, 17) = 1

    x₀ = 1
    x₁ = 0
    x₂ = x₀ - q₁·x₁ = 1 - 3·0 = 1
    x₃ = x₁ - q₂·x₂ = 0 - 1·1 = -1
    x₄ = x₂ - q₃·x₃ = 1 - 1·(-1) = 2

    The inverse is thus 2: 60·2 mod 17 = 1


## Binary Euclidean Algorithm

Stein's algorithm ([HAC 14.4](https://cacr.uwaterloo.ca/hac/)), also known
as the *binary GCD algorithm* (uses simpler arithmetic operations than the
conventional Euclidean algorithm; it replaces division with arithmetic shifts,
comparisons, and subtraction.

### Basic

The algorithm reduces the problem of finding the `gcd` of two **non-negative**
numbers `a` and `b` by repeatedly applying these identities:

1. `(0, a) = a` and `(b, 0) = b`;
2. `(2·a, 2·b) = 2·gcd(a, b)`;
3. `(2·a, b) = (a, b)`, if `b` is odd;
4. `(a, b) = (|a − b|, min(a, b))`, if `a` and `b` are both odd

Note that the last identity is a single step of the classic Euclidean algorithm.

Pseudo Code

    g = 1
    while a ≡ b ≡ 0 (mod 2) do:
        a = a/2, b = b/2, g = 2·g
    while a ≠ 0 do:
        while a ≡ 0 (mod 2) do:
            a = a/2
        while b ≡ 0 (mod 2) do:
            b = b/2
        t = |a - b|/2
        if a ≥ b then:
            a = t
        else:
            b = t
    return g·b

### Extended 

The classic EEA algorithm has the drawback of requiring relatively costly
multiple-precision divisions to compute the quotients. The following algorithm
eliminates the divisions at the expense of more iterations.

Pseudo Code

    g = 1
    while a ≡ b ≡ 0 (mod 2) do:
        a = a/2, b = b/2, g = 2·g
    u = a, v = b
    A = 1, B = 0, C = 0, D = 1
    while u ≠ 0 do:
        while u is even do:
            u = u/2
            if A ≡ B ≡ 0 (mod 2) then:
                A = A/2, B = B/2
            else:
                A = (A + b)/2, B = (B - a)/2
        while v is even do:
            v = v/2
            if C ≡ D ≡ 0 (mod 2) then:
                C = C/2, D = D/2
            else:
                C = (C + b)/2, D = (D - a)/2
        if u ≥ v then:
            u = u - v, A = A - C, B = B - D
        else:
            v = v - u, C = C - A, D = D - B
    a = C, b = D
    return (g·v, a, b)


## Python Code

### Basic Euclid's Algorithm

```python
    def euclid_gcd(a, b):
        while b != 0:
            a, b = b, a % b
        return a
```

### Recursive EEA

Given:

    gcd, x1, y1 = EEA(b, a mod b)

Such that `gcd = b·x1 + (a mod b)·y1` then:

    gcd = b·x1 + (a - b·q)·y1 = b·x1 + a·y1 - b·q·y1 = a·y1 + b·(x1 - q·y1) = a·x2 + b·y2

```python
    def extended_euclidean(a, b):
        if b == 0:
            return a, 1, 0

        gcd, x1, y1 = extended_euclidean(b, a % b)
        x2 = y1
        y2 = x1 - (a // b) * y1
        return gcd, x2, y2
```

### Non-recursive EEA

```python
    def extended_euclidean(a, b):
        x0, y0, x1, y1 = 1, 0, 0, 1
        while b != 0:
            q = a // b
            a, b = b, a - q * b
            x0, x1 = x1, x0 - q * x1
            y0, y1 = y1, y0 - q * y1
        return a, x0, y0
```

### Modular Inverse

Computes the inverse of `a` modulo `b` assuming that `(a,b) = 1`.

```python
    def inverse(a, b):
        x0, x1 = 1, 0
        while b != 0:
            q = a // b
            a, b = b, a - q * b
            x0, x1 = x1, x0 - q * x1
        return x0
```


## References

- Simple C [implementation](https://github.com/davxy/cry/blob/master/src/mpi/mpi_inv.c) of modular inverse
- [Handbook of Applied Cryptography](https://cacr.uwaterloo.ca/hac/)
