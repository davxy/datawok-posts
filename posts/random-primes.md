+++
title = "Random Primes Generation"
date = "2023-01-16"
modified = "2023-12-12"
tags = ["cryptography","number-theory"]
toc = true
+++

Generating random primes and testing their primality is essential for many
cryptographic algorithms. In this post, we'll explore methods for generating and
testing prime numbers.


## What is this about

We want to develop an algorithm that generates a prime in the range
`[2ᵏ⁻¹, 2ᵏ-1]`, with `k` the number of bits required to represent the
prime.

Approach:
1. generate of a `k` bits random integer in the interval;
2. test for primality.

During the random generation observe that for sure the most significant and
least significant bits are set to `1` (primes are odd). The intermediate
positions are randomly filled.


## Termination

The algorithm probabilistically terminates, and we can give an upper bound
estimation to the number of iterations. Given

    π(n) = number of primes less than n

The **Prime Number Theorem** gives an asymptotic estimation for the number of
primes less than a number `n`:

    π(n) ≈ n/ln(n)

In other words the probability to randomly pick a prime in the set of the first
`n` numbers is:

    π(n)/n ≈ 1/ln(n)

This probability steadily decreases, but is always greater than `0`.

With our random algorithm the probability to get a `2ᵏ` bits prime on first
attempt is thus:

    π(2ᵏ)/(2ᵏ) ≈ 1/ln(2ᵏ) = 1/[k·ln(2)]

More exactly, since we are ignoring all even numbers, this probability should
be doubled.

Note that for simplicity, we are intentionally ignoring the fact that we don't
pick the numbers in the range `[0, 2ᵏ⁻¹ - 1]`. In practice, we search in the
upper half of the possible numbers.

The event to extract a prime can be associated to a *Bernoulli*'s variable that
has a success probability `p = 2/[k·ln(2)]`.

### Expected number of attempts

**Proposition**. Given a *Bernulli* experiment with success probability `p`
(`q = 1-p`), the number of attempts before observing a success is on average `1/p`.

*Proof*

Let `Y` be the number of attempts before a success in a Bernulli experiment.

The probability of a success after the `k` attempts is:

    Pr(Y = k) = qᵏ⁻¹·p

The expected value of `Y`, i.e. the expected number of attempts before observing
a success is:

    E[Y] = ∑ k·Pr(Y = k)
         = 1·p + 2·q·p + 3·q²·p + 4·q³·p + ... + n·qⁿ⁻¹·p
         = p·(1 + 2·q + 3·q² + 4·q³ + ...+ n·qⁿ⁻¹)

Multiplying both sides by `q`:

    q·E[Y] = p·(1·q + 2·q² + 3·q³ + 4·q⁴ + ... + n·qⁿ)

Subtracting `q·E[Y] = (1-p)·E[Y]` from `E[Y]`

    p·E[Y] = p·(1 + q + q² + ... + qⁿ⁻¹ + n·qⁿ)

    E[Y] = 1 + q + q² + ... + qⁿ⁻¹ + n·qⁿ

The above contains an infinite geometric series with rational `q < 1` and thus
converges to `1/(1-q) = 1/p`. The last addend `(n·qⁿ)` approaches `0` as `n → ∞`.

We can finally assert that `E[Y] = 1/p`

∎

On average, the number of attempts before observing a success is thus given by
`1/p = k·ln(2)/2`.

        k | ≈ attempts
    ------|------------
      100 |   34
     1000 |  346
    10000 | 3465


## Deterministic Primality Testing

A naive approach to check if a number `n` is prime is an exhaustive search for a
prime factor up to `√n`.

A composite number should have at least one divisor `x` less than or equal `√n`.
If not, then it has at least two divisors `x` and `y` greater than `√n`. Follows
the impossible condition: `n ≥ x·y > √n·√n = n`.


## Probabilistic Primality Testing

More efficient algorithms to check for primality are **Montecarlo** algorithms.
Which means probabilistic algorithms that always terminate but may produce
an incorrect result with a certain probability.

Given a *Montecarlo* primality test algorithm `A`:

    A(n) = 'true' if n is probably prime, 'false' if is compsite

If `A` returns `true` the error probability `ε` (meaning that `n` is composite)
is related to the algorithm `A`.

    p(n is composite | A(n) = true) = ε

When `n` is probably prime then the algorithm `A` can be re-executed and the
more it returns `true` the more likely is that `n` is indeed prime.

If the runs are independent, then the probability that the algorithm *fails* `k`
times in a row is thus `εᵏ`.

If, during the various runs, `A` returns `false` once then we can immediately
stop and assert that the number is composite.

    p(n is composite | A(n) = false) = 1

In other words the algorithm produces only false negatives, never false positives.

### Naive Approach

Extract a random number `x ∈ [2, n-1]` and compute `gcd(x,n)`.

    A(n) = 'true' if gcd(x,n) = 1 else 'false'

A **witness** is a number that allow `A` to decide that `n` is not prime.

In this case `ε`, the probability that `gcd(x,n) = 1` when `n` is not prime, is
equal to the probability of choosing `x` coprime with `n`. In other words the
probability of choosing `x ∈ Zₙ*` with `|Zₙ*| = φ(n)`.

    ε ≈ φ(n)/n = n·∏(1 - 1/pᵢ)/n = ∏(1 - 1/pᵢ)

With `pᵢ` the primes in the factorization of `n`.

The more `ε` is small the higher is the probability to find a witness.

If the prime factors are all *big* then with this test `ε ≈ 1`. This means that
even though `n` is not prime it is very unlikely to choose a number (a witness)
that is not coprime with `n`.

In case of RSA we have two big primes `p` and `q`, so given `n = p·q` there is a
very low probability to end up choosing a multiple of `p` or `q` during our
primality test. In this case the probability to choose a witness is 
`1 - ε = (p + q - 1)/n`, which tends to zero.

With this test we can't fix an error probability `ε` below an upper bound `< 1`.

Probabilistically `ε = φ(n)/n ≈ 1`, that is `φ(n)` is typically very close to
`n`. Follows that we have to find a better algorithm to find a witness.

### Fermat Test

Extends the naive approach by applying the *Fermat's little theorem* to a
candidate.

**Fermat's Little Theorem**. Given a prime number `p` and a number `x` such that
`(x,p) = 1`, then `xᵖ⁻¹ ≡ 1 (mod p)`

Given a candidate `n`, the idea is to randomly choose `1 < x < n-1` and compute
`xⁿ⁻¹ mod n`. If the result is not `1` then for sure `n` is not prime, thus
we return false.

The result follows because if `n` is prime and `x < n` then for sure `(x,n) = 1`
and the *Fermat's little theorem* must hold.

Note that we are not going to test `1` and `(n-1)` as the Fermat expression
returns `1` for all `n` and for all odd `n`, respectively. The test is always
successful for such values, regardless of `x`:
- For `x = 1`: `1ⁿ⁻¹ ≡ 1 (mod n) ∀ n`
- For `x = n-1`: if `n = 2·k + 1` → `n-1 = 2·k` for some `k`.
  Thus`(n-1)ⁿ⁻¹ ≡ (-1)²ᵏ mod n ≡ 1 (mod n)`

If `xⁿ⁻¹ ≡ 1 (mod n)`, then `n` may be prime with a certain error probability `ε`.

**Fermat Witness**. `x ∈ Zₙ` with `1 < x < n-1` and `xⁿ⁻¹ ≢ 1 (mod n)`.

Because the number of `x` such that `(x,n) = 1` is generally close to `n`, our
algorithm must perform well in `Zₙ*`. That is, in general we're going to search
for a witness in `Zₙ*`.

Generally, composite numbers have a fairly high number of Fermat's witnesses,
but unfortunately there are some composite numbers that doesn't have any
witness (*Carmichael numbers*). Follows that there is no upper bound to the
error probability.

Note that if `(x,n) ≠ 1` then `xⁿ⁻¹ ≢ 1 (mod n)`.

*Proof*: if `xⁿ⁻¹ ≡ 1 (mod n)` then `x·xⁿ⁻² ≡ 1 (mod n)`. Follows that
`x` have an inverse modulo `n`, but this is not possible as `(x,n) ≠ 1`.

#### Carmichael Numbers

A composite number `n` which satisfies `xⁿ⁻¹ ≡ 1 (mod n)` for all integers
`x` which are relative prime to `n`.

In other words, excluded the (small set of) numbers that are not relative prime
to `n`, `n` doesn't have any Fermat witness.

A Carmichael number is thus a number for which the Fermat's theorem always holds
even if it is composite.

Using *Euler's theorem*, we can assert that if `φ(n)|(n-1)` then `xⁿ⁻¹ ≡
x^[(n-1) mod φ(n)] ≡ 1 (mod n)` for any `x`. Thus, in this case `n` would be a
Carmichael number.

[*Lehmer's totient problem*](https://en.wikipedia.org/wiki/Lehmer%27s_totient_problem).
Lehmer conjectured in 1939 that there are no composite numbers with this property.

But this is not a necessary condition, as for all known Carmichal numbers `φ(n)∤(n-1)`.

**Theorem**. There are Carmichael numbers.

*Proof*. We prove that `561 = 3·11·17` is a Carmichael number (the first indeed)
by proving that `∀ x` if `(x,561) = 1` then `x⁵⁶⁰ mod 561 = 1`.

Using the Little Fermat theorem corollary, for each prime factors `pᵢ` of `561`,
we can easily check that:

    x⁵⁶⁰ ≡ x^(560 mod (pᵢ-1)) ≡ x^[(3·11·17 - 1) mod (pᵢ-1)] ≡ 1 (mod pᵢ)

Thus, using the CRT, `x⁵⁶⁰` can be represented as `(1, 1, 1)`.

    m = 3·11·17 = 561

    c₁ = (11·17) · [(11·17)⁻¹ (mod 3)] = 187·1 = 187
    c₂ = (3·17) · [(3·17)⁻¹ (mod 11)] = 51·8 = 408
    c₃ = (3·11) · [(3·11)⁻¹ (mod 17)] = 33·16 = 528

    X = ∑ (xᵢ·cᵢ) = 1·187 + 1·408 + 1·528 = 1123 ≡ 1 (mod 561)

The solution modulo `m` is unique and thus `x⁵⁶⁰ ≡ 1 (mod 561)`.

∎

Given that the majority of numbers less than `n` are relative prime to `n`,
follows that is very hard to find a witness for Carmichael numbers. That is, we
have to be lucky enough to pick `x` such that `(x,n) ≠ 1`.

Carmichael numbers can be tabulated up to an upper bound. But this is limited
and indeed there relatively *small* pre-built tables.

### Miller-Rabin Test

Extends the Fermat test by applying the quadratic remainders' property to
a candidate.

#### Quadratic remainders

**QR Theorem**. Given a prime number `p` and `x < p`, then:

    x² ≡ 1 (mod p) iff x ≡ ±1 (mod p)

Proof: 

    (←) if `x ≡ ±1 (mod p)` then obviously `x² ≡ 1 (mod p)`

    (→) if x² ≡ 1 (mod p) → (x² - 1) ≡ (x - 1)·(x + 1) ≡ 0 (mod p)
    → p | (x - 1)·(x + 1)  →  (because p is prime)  →  p | (x - 1) or p | (x + 1)
    If p | (x - 1)  →  x - 1 ≡ 0 (mod p)  →  x ≡  1 (mod p)
    If p | (x + 1)  →  x + 1 ≡ 0 (mod p)  →  x ≡ -1 (mod p)

The theorem says that if `p` is prime, `x` is its self inverse iff `x ≡ ±1 (mod p)`.

Reformulating the theorem to apply it to our primality test:

    if x² ≡ 1 (mod p) and x ≢ ±1 (mod p) then p can't be prime

Example. `3² ≡ 1 (mod 8)` and `3 ≢ ±1 (mod 8)`, thus `8` can't be prime.

If `∃ x` such that `x² ≡ 1 (mod p)` then `1` is a **quadratic residue** modulo
`p`.

The theorem gives us another tool to search for a witness.

    A(x,n) = Miller-Rabin predicate

#### Miller-Rabin predicate

Given an odd prime candidate `n`, we decompose `n-1` into its odd and even
factors:

    (n - 1) = m·2ʳ , with m odd

We compute a sequence `{xᵢ}` for `i = 1..r`

    x₀ = x^(m·2⁰) mod n
    ...
    xᵢ = x^(m·2ⁱ) mod n
    ...
    xᵣ = x^(m·2ʳ) mod n = xⁿ⁻¹ mod n

Note that the last element of the sequence `xᵣ` is equal to `xⁿ⁻¹`,
thus if `n` successfully passes the Fermat's test then `xᵣ = 1`.

If `n` is prime, then for the QR theorem we have that if `xᵢ = 1` then
`xᵢ₋₁ ≡ ±1 (mod n)`.

If `x₀ ≡ ±1` then we can immediately return that it is probably prime.
Indeed, if `x₀ = ±1` then for any `i > 0` we have `xᵢ = 1` and thus none of the
`xᵢ` values is a witness.

If `x₀ ≢ ±1` then at some point we must find `xᵢ ≡ 1`. In this case `n` may be
prime for QR theorem only if `xᵢ₋₁ ≡ -1`, otherwise is composite.

The predicate thus returns false (composite) if:

    x₀ ≢ ±1 and ∀i in [1,..,r-1] xᵢ ≢ -1

The error probability `ε` is the probability to choose `x` that is not a Rabin
witness for a composite number `n`. In other words we found `xᵢ = -1` in the
sequence.

**Theorem**. Every odd composite number `n` has at least `(3/4)·n` Rabin witnesses.

The probability of not choosing a witness during the test run is thus `ε < 1/4`.

Note that there is an easier to prove, companion theorem that shows that there
are at least `n/2` Rabin witness.

Miller-Rabin test also gives a proof of *compositeness* represented by the
sequence `x₀...xₖ`.

### Factorization attempt

The factorization problem is an independent problem, thus **in general**
primality testing doesn't help a lot here. But there is an exception.

If we find a non-trivial root of `1` modulo `n`, for the QR theorem we know that
`n` can't be prime.

    x ≢ ±1  ∧  x² ≡ 1 (mod n)
    →  x² - 1 ≡ (x-1)(x+1) ≡ 0 (mod n)  →  n | (x-1)(x+1)

The factors of `n` should thus be in the product `(x-1)(x+1)`.

They cannot all be in the first factor, otherwise `n | (x-1) → x = 1 (mod n)`.
And this can't be true by hypothesis. A similar result applies to `(x+1)`.

This means that some factors of `n` are in `(x-1)` and some others are in `(x+1)`.

Thus, `(n, x-1)` and `(n, x+1)` should return some non-trivial factor of `n`.

The Carmichael numbers are the ones that are really vulnerable since are the
ones that are mostly caught by the QR theorem of Miller Rabin.

**Quadratic Sieving** is a factorization method which leverage this weakness.


## References

- [Carmichael Numbers OEIS](https://oeis.org/A002997)
- Fast Rust implementation using `num-bigint` and `rayon` [here](https://github.com/davxy/crypto-hacks/tree/main/miller-rabin)
