+++
title = "RSA Cipher"
date = "2017-09-25"
modified = "2023-12-13"
tags = ["cryptography"]
toc = true
+++

## First Attempt

Let's first try to build a scheme directly from the *Fermat's Little Theorem*.

Given a prime number `p` and a message `m < p`, we choose two numbers `e` and
`d` such that `e·d ≡ 1 (mod p-1)`.

- Encryption: `c = mᵉ mod p`
- Decryption: `m = cᵈ mod p`

*Proof*. `cᵈ = m^(e·d) ≡ m^(e·d mod p-1) = m (mod p)` ∎

### Attack

Assuming that the couple `e`, `n` is the public key.

Because `e·d ≡ 1 (mod p-1)` then `1 = e·d + (p-1)·y`

With the *Euclidean's algorithm* we can easily find the "secret" `d`.

The weakness can be addressed by replacing the modulo `p` with a composite
number `n`. The attacker now requires using the *Euler's theorem* and thus to
find `φ(n)` by factoring `n`. When the prime factors of `n` are big enough this
is believed to be a hard problem.


## RSA Scheme

Given two big prime numbers `p` and `q`, we set the modulo `n = p·q`.

The keys should satisfy the following property:

    e·d ≡ 1 (mod φ(n))

In other words, `(e, φ(n)) = 1`.

- Encryption: `c = mᵉ mod n`
- Decryption: `m = cᵈ mod n`

*Proof*.

If `(m,n) = 1` then thesis immediately follows from Euler's theorem:

    cᵈ = m^(e·d) ≡ m^(e·d mod φ(n)) = m (mod n)

If `(m,n) ≠ 1` then we should have `(m,p) ≠ 1` or `(m,q) ≠ 1` but not both
otherwise `m = p·q·k = 0 (mod n)`, which is not possible.

When `(m,q) ≠ 1`, then `m` must be equal to some multiple of `q`.
Let's assume `m = q·x` and `(m,p) = 1`, then

      m^[(p-1)·(q-1)·z] ≡ 1 (mod p)
    → m^[(p-1)·(q-1)·z] = 1 + p·k

For the key choice criteria:

    e·d ≡ 1 (mod φ(n))  →  e·d = 1 + φ(n)·z = 1 + (p-1)·(q-1)·z

Then

    m^(e·d) = m^[1 + (p-1)·(q-1)·z] = m·m^[(p-1)·(q-1)·z] = m·(1 + p·k)
            = m + m·p·k = m + (q·x)·(p·k) = m + (q·p)(x·k) = m + n·w
            ≡ m (mod n)

∎

Even though in practice, generating a message not in `Zₙ*` is very unlikely, the
cipher works anyway.

The probability of having a message with `(m,n) = 1` is `φ(n)/n`.

The *Euler's Totient* is:

    φ(n) = n·(1-1/p)·(1-1/q)

The more `p` and `q` are big the more `1/p` and `1/q` are close to `0`, thus:

    φ(n) ≈ n

This is also good for the overall security as, if a number `m` is not coprime
with `n`, because `n = p·q` and `m = p·k` or `q·k` (but not both) with `k` less
than the other prime, then `(m,n) = p` or `(m,n) = q`.

In case of a known plaintext attack scenario, to factor `n`, an attacker just
has to use the *Euclid's algorithm* to find the two secret factors.


## Security Considerations

The security of the RSA cipher mostly relies on the hardness of integer
factorization.

While there are no known efficient algorithms for factoring large integers,
the security of the cipher is not guaranteed. Advances in computer hardware,
mathematics, and cryptography could potentially render the RSA cipher vulnerable
to attacks in the future.

If an attacker can factor the modulus, then he can easily compute the decryption
exponent and decrypt any message encrypted with the public key.

Additionally, bad implementations can brick even the strongest of the ciphers.

### Analytical Attacks

The possible attack types can be classified by the end goal and sorted by
complexity (most complex first):
1. Determine the factors `p` and `q`
2. Determine the totient `φ(n)`
3. Determine the secret key `d`
4. Determine the plaintext `m`

The complexity difference between the attacks is just polynomial.
Thus, for example, if we have an algorithm to solve problem 1 then we can
easily solve all the other problems as well.

Since today the factorization problem is considered hard, an attacker may be
inclined trying to directly solve problem 4.

Can be proven that the first three problems are equivalent.

#### 1 solves 2

If we know `p` and `q` then `φ(n) = (p-1)·(q-1)`

#### 2 solves 1

Given `φ(n)` we can easily find `p` and `q`

      φ(n) = (p-1)·(q-1) = p·q - p - q + 1 = n - p - q + 1  (note: q = n/p)
           = n - p - n/p + 1
    → φ(n)·p = p·n - p² - n + p
    → p² + p(φ(n) - n - 1) + n = 0

Solving for p we find two roots who correspond to `p` and `q`.

#### 2 solves 3

First compute `φ(n) = (p-1)·(q-1)`. Then, given that `e·d = 1 (mod φ(n))`
and public exponent `e` is known, is just a matter of applying the Extended
Euclidean Algorithm to compute the inverse `d`.

#### 3 solves 1 (probabilistic)

Given `d` we use a probabilistic algorithm that gives `p` and `q`.

1. Randomly choose `x ∈ Zₙ`.
2. If `x = gcd(x, n) > 1` then we found a non-trivial factor of `n`, we
   return `(p=x, q=n/x)`. This event has negligible probability.
3. Decompose `e·d - 1 = s·2ʳ` with `s` odd (`e·d` is odd, see lemma below).
4. Compute the sequence:

    - `x₀ = xˢ mod n = x^(s·2⁰) mod n`
    - `x₁ = x₀² mod n = x^(s·2¹) mod n`
    - ...
    - `xᵣ = xᵣ₋₁² mod n = x^(s·2ʳ) mod n = x^(e·d - 1) mod n`

    For key choice of RSA:

    `(e,φ(n)) = 1 → e·d + φ(n)·t = 1 → e·d - 1 = φ(n)·t ≡ 0 (mod φ(n))`

    Thus: `x^(ed - 1) ≡ x⁰ = 1 (mod n)`

    Starting from a `x₀ ≠ 1`, at some point we must find `xᵢ ≠ 1` such that
    `xᵢ² ≡ 1 (mod n)`. If `xᵢ = -1` we repeat the procedure with another `x`.

    `xᵢ² - 1 = (xᵢ-1)·(xᵢ+1) ≡ 0 (mod n)  →  n | (xᵢ-1)·(xᵢ+1)`

    The factors of `n` can't all be in the first factor, because otherwise
    `n | (xᵢ-1)` and thus `xᵢ ≡ 1 (mod n)` (Similarly for `xᵢ+1`).

    This means that some factors are in `(xᵢ-1)` and some others in `(xᵢ+1)`.
    So `gcd(n, xᵢ-1)` should return some non-trivial factor of `n`: `p` or `q`.

**Lemma**: `e·d` is odd.

*Proof*. Given that `φ(n) = (p-1)·(q-1) = (2·x)·(2·y) = 2·z` and that `(e,φ(n)) = 1`
then `e` must be odd and the same for `d`. Thus, `e·d` is odd.

#### 3 solves 4

If we have `d` then we can then easily find `m` using the decryption procedure.

#### 4 doesn't solve 3 (conjecture)

Can we find `d` if we know an algorithm to find `m` without knowing the key?

This is known as the **RSAP** (RSA Problem) and in practice here we're asking if
RSA is resistant to a **chosen ciphertext attack**.

There is a conjecture that postulates that this problem is as hard as the
factorization problem. If not, RSA would be broken.


### Side Channel Attacks

These attacks are using techniques which targets physical aspects of the cipher.

Some attack vectors:
- *timing*
- *power consumption*
- *injected faults*

Probably, the most popular one is the **timing attack** introduced by the
[*Kocher*](https://link.springer.com/chapter/10.1007/3-540-68697-5_9) seminal
paper in 1996.

When using a naive implementation, the execution time may reveal some
information about the secret exponent.

Attack requisites:
- ability to choose the ciphertext to decrypt (chosen ciphertext);
- a local copy of the remote system to work with.

Side channels attacks are very concrete and effective, more than analytical
attacks, which today are assumed infeasible.

Mitigations:
- **Constant time execution**: all executions paths perform as the worst case.
- **Random delays**: insert random delays independent of the exponent.
- **Blinding**: decryption is not directly applied to the ciphertext.

#### Blinding

Steps:
- Choose a random blinding factor: `r ∈ Zₙ*`;
- Blind the ciphertext: `c' = rᵉ · c = (r·m)ᵉ`
- Decrypt the blinded ciphertext: `m' = c'ᵈ = (r·m)ᵉᵈ = r·m`
- Remove the blinding: `m =  r⁻¹·r·m`

Because we are decrypting a value not known to the attacker, he can't replicate
the operation in its local device copy.

Blinding the message introduces a performance degradation of approximately 10%.


## Padding

The described RSA cipher is known as **textbook** RSA and has some critical
flaws.

### Malleability

If an encrypted message is multiplied by a factor `zᵉ` then the corresponding
decrypted message will result multiplied by the factor `z`:

    c = mᵉ  →  c' = zᵉ·c = (z·m)ᵉ  →  m' = c'ᵈ = z·m

This property allows to an attacker to manipulate an encrypted message to
produce predictable results on the plaintext.

### Dictionary Attack

By definition in a public key cipher the attacker has always access to the
encryption key. 

If the attacker knows the whole set of possible plaintexts then he can then
construct a dictionary of all the ciphertexts using the public key.

When the attacker intercepts a ciphertext he can then easily infer what is the
corresponding plaintext using a dictionary lookup.

### Padding Schemes

One common solution to the above issues is to introduce some random factor as
padding to the original message. The recipient should be able to remove the
factor after decryption.

Popular padding schemes:
- **PKCS#1 v1.5**: specified in PKCS#1 v1.5 standard and probably the most popular.
- **OAEP** (Optimal Asymmetric Encryption Padding): specified in PKCS#1 v2.0.
- **PSS** (Probabilistic Signature Scheme): similar to OAEP but for digital signatures.


## Failures

Vulnerabilities that emerge in particular use cases of *textbook* RSA.

### Common Modulus Failure

Encrypt the same message `m` using the two different encryption keys but with
the same modulus `n`:

    c₁ = mᵉ¹ mod n
    c₂ = mᵉ² mod n

Let's assume that with high probability `(e₁,e₂) = 1`. An attacker can thus use
the EEA to compute `x` and `y` such that `e₁·x + e₂·y = 1`.

Finally, he can recover the plaintext:

    c₁' = c₁ˣ = m^(e₁·x)
    c₂' = c₂ʸ = m^(e₂·y)
    c₁'·c₂' = m^(e₁·x) · m^(e₂·y) = m^(e₁·x + e₂·y) ≡ m (mod n)

Note that if `y < 0` then `y = -a` for some `a > 0`. Then `c₂ʸ = (c₂⁻¹)ᵃ`and
thus in this case we also require that `(c₂,n) = 1`.


### Small Exponent Failure

Assume that the attacker intercepts the same message `m` encrypted with the same
small public exponent `e` but different moduli `n₁,..,nₑ`:

    c₁ = mᵉ mod n₁
    ...
    cₑ = mᵉ mod nₑ

Assume `(nᵢ, nⱼ) = 1`, if not then already found a factor for the modulus, and
thus we can trivially recover enough secrets to disclose the message.

The attacker writes a system of equations:

    x ≡ c₁ (mod n₁)
    ...
    x ≡ cₑ (mod nₑ)

Using the CRT the attacker recovers the unique solution `x ∈ Zₙ`, with `n = n₁·..·nₑ`.

Note that if `m < nᵢ ∀i` then `mᵉ < ∏ nᵢ = n`, and thus the attacker can simply
take the ordinary `e-th` root of `x` to recover `m`

    m = ᵉ√x

If instead `mᵉ ≥ n`, the result of the CRT will not be the exact `e-th` power
of `m` but a reduced form modulo `n`. In this case the attacker should compute
`x^(e⁻¹ mod φ(n)) (mod n)`, which is unfeasible as he doesn't know the single
factors of each `nᵢ`.

Padding prevents the attack as it:
- introduces randomness in each message, thus the messages will be different;
- increases the size of each `m`, and thus is very probable that `mᵉ ≥ n`.


## References

- [Euler's theorem](/posts/fermat-euler-theorems)
- [Chinese Remainder Theorem](/posts/chinese-remainder-theorem/#rsa-crt-speed-up) RSA optimization
- [Generation of big primes](/posts/random-primes)
- [Timing attack](/posts/timing-attack)
- [Simple RSA implementation](https://github.com/davxy/cry/blob/master/src/crypt/rsa.c) (no CRT)
- [Common modulus attack PoC](https://github.com/davxy/crypto-hacks/tree/main/rsa-fails)
- [CRT signature fault injection PoC](https://github.com/davxy/crypto-hacks/tree/main/rsa-fails)
- [Group operation timing attack PoC](https://github.com/davxy/crypto-hacks/tree/main/group-op-timing-attack)
- [Constant time](https://www.chosenplaintext.ca/articles/beginners-guide-constant-time-cryptography.html)
