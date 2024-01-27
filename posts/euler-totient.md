+++
title = "Euler's Totient"
date = "2017-08-19"
modified = "2023-12-11"
tags = ["mathematics","number-theory"]
+++

Given a natural number `n`, the Euler `φ` function, also known as Euler's
*Totient*, applied to `n` represents the number of positive numbers less than
`n` that are coprime to `n`.


## Prime Power

**Proposition**. For a prime number `p` and a natural number `n`:

    φ(pⁿ) = pⁿ·(1-1/p)

*Proof*

Create a list of the numbers less than `pⁿ` and count how many numbers in the
list are not relatively prime to `pⁿ`.

Because `p` is prime we are counting the multiples of `p` that are less than
`pⁿ`. There are `pⁿ⁻¹` such multiples, they are:

    { 0·p, 1·p, 2·p, ..., pⁿ⁻²·p }

Thus, among the first `pⁿ` numbers, `pⁿ - pⁿ⁻¹ = pⁿ·(1 - 1/p)` are coprime with
`pⁿ`.

∎

**Corollary**. If `p` is prime then `φ(p) = p - 1`.

*Proof*. Trivially follow the previous proposition for `n = 1`.


## Product of Primes

For two primes `p` and `q`

    φ(p·q) = φ(p)·φ(q)

*Proof*

Given two primes `p` and `q`, the elements `x < p·q` such that `(x, p·q) ≠ 1` are:

- `A = { 0 }`
- `B = { p, 2·p, 3·p, ..., (q-1)·p }`
- `C = { q, 2·q, 3·q, ..., (p-1)·q }`

The 3 sets are disjoint.

That is, if `i·p = j·q  →  q|(i·p)  →  q|i` (because `p` is prime) and this is
impossible because `i < q`.

Follows that:

    φ(p·q) = |Z_(p·q)| - (|A| + |B| + |C|)
           = p·q - (1 + p-1 + q-1) = p·q - p - q + 1
           = (p-1)·(q-1) = φ(p)·φ(q)

∎


## Product of Coprimes

**Proposition**. If `a` and `b` are coprime then `φ(a·b) = φ(a)·φ(b)`

*Proof*

See [CRT](/posts/chinese-remainder-theorem/#eulers-totient-proof) applications.


## General Formula

The generic closed form formula for the sequence is:

    φ(n) = n · ∏ (1 - 1/pᵢ)

With `{pᵢ}` the primes in the factorization of `n`.

*Proof*

From the above propositions and the *fundamental theorem of arithmetic*:

    φ(n) = φ(∏ pᵢ^eᵢ) = ∏ φ(pᵢ^eᵢ) = ∏ pᵢ^eᵢ·(1 - 1/pᵢ) = n·∏(1 - 1/pᵢ)


## Some values for the function

As can be easily seen from the table and the graph, the function is not monotonic.

| n  | φ(n) |
|----|------|
|  1 |  1   |
|  2 |  1   |
|  3 |  2   |
|  4 |  2   |
|  5 |  4   |
|  6 |  2   |
|  7 |  6   |
|  8 |  4   |
|  9 |  6   |
| 10 |  4   |
| 11 | 10   |
| 12 |  4   |
| 13 | 12   |
| 14 |  6   |
| 15 |  8   |
| 16 |  8   |
| 17 | 16   |
| 18 |  6   |
| 19 | 18   |
| 20 |  8   |
| 21 | 12   |
| 22 | 10   |
| 23 | 22   |
| 24 |  8   |
| 25 | 20   |
| 26 | 12   |
| 27 | 18   |
| 28 | 12   |
| 29 | 28   |
| 30 |  8   |
| 31 | 30   |
| 32 | 16   |
| 33 | 20   |
| 34 | 16   |
| 35 | 24   |
| 36 | 12   |
| 37 | 36   |
| 38 | 18   |
| 39 | 24   |
| 40 | 16   |
| 41 | 40   |
| 42 | 12   |
| 43 | 42   |
| 44 | 20   |
| 45 | 24   |
| 46 | 22   |
| 47 | 46   |
| 48 | 16   |
| 49 | 42   |
| 50 | 20   |
| 51 | 32   |
| 52 | 24   |
| 53 | 52   |
| 54 | 18   |
| 55 | 40   |
| 56 | 24   |
| 57 | 36   |
| 58 | 28   |
| 59 | 58   |
| 60 | 16   |
| 61 | 60   |
| 62 | 30   |
| 63 | 36   |
| 64 | 32   |
| 65 | 48   |
| 66 | 20   |
| 67 | 66   |
| 68 | 32   |
| 69 | 44   |


![plot](/companions/euler-totient.png)

References
----------

- [Modular Arithmetic Basics](/posts/modular-arithmetic)
- [Chinese Remainder Theorem](/posts/chinese-remainder-theorem/#eulers-totient-proof)
- Sequence [A000010](https://oeis.org/A000010) in the OEIS
- [Wikipedia](https://en.wikipedia.org/wiki/Euler_totient_function)
