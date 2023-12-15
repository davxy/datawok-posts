+++
title = "[DRAFT] Public Key Cryptography Introduction"
date = "2019-05-11"
tags = ["cryptography"]
draft = true
+++

A revolutionary idea published [^1] around 1977 by *Diffie* and *Hellman*
affecting both confidentiality (encryption) and non-repudiation (signature)
services.

The idea is that each peer has two keys instead of a shared one, one **public**
and one **secret**. 

The two keys usage depends on the context.

For encryption:
- public key can be used by anyone to encrypt;
- secret key is used by the key owner to decrypt.

For signature:
- secret key is used by the key owner to sign;
- public key can be used by anyone to verify.

In these notes we'll focus on the encryption service.

Requirements:
- A key set `K = { (pub, sec) }`, subset of `K_pub ⨯ K_sec`.
- A family of injective functions from plaintext to ciphertext sets
  `F = { fₖ: M → C }`.
  Computing `fₖ` only requires the `pub` component of the key.
  There is one `fₖ` function for each key `k`. 

Computational requirements:
1. Elements of `K` are *easy* to compute.
2. Encryption function `f` is *easy* to compute.
3. Decryption function `f⁻¹` is generally *hard* to compute
4. Decryption function `f⁻¹` is *easy* to compute if some additional
   information is known (the secret key `sec`).

A function that satisfies both 2 and 3 is called a **one-way** function (easy to
compute but hard to invert).

A function that satisfies 2, 3 and 4 is called a **one-way trapdoor** function.
The trapdoor is typically related to the current state of knowledge, or in other
words something that is considered hard today may not be so hard in the future.


## One Way Functions

Mathematically, these functions are generally based on functions that works
with integers. Is thus first required to encode both plaintext and ciphertext
to integers.

### Discrete Logarithm

If `p` is a prime number, then we define the **modular exponential** function
over `Zp* = {1, .., p-1}` as:

    exp: Zp* → Zp*
    exp(x) = gˣ mod p, for x ∈ Zp*

Where `g` is a *primitive root* for the group `Zp*` (aka group generator).

The `exp` is bijective and one-way.

The inverse function is called **discrete logarithm**, and as a function is
often written as `ind`:

    ind(y) = log_g(y) mod p

Or in simpler terms `ind(y) = x` *iff* `gˣ mod p = y`

Today, given a value `y` and a generator `g` there are no efficient algorithms
to find the value `x` such that `gˣ mod p = y`. Note that here we are talking
about discrete logarithm (with exponentiation computed in modular arithmetic).

This one-way function is used by some well known cryptographic schemes:
- *ElGamal* encryption and digital signature
- *Diffie-Hellman* secret sharing

### Integer Factorization

Given two natural numbers `x` and `y` we define the scalar product as:

    mul: N ⨯ N → N
    mul(x,y) = x·y mod p, with x,y ∈ N

The inverse function is one that takes a number `z` and gives back two
non-trivial (`≠ 1`) numbers `x` and `y` such that `x·y = z`.

The inverse function is called **factorization**.

Today, each known factorization algorithm doesn't have polynomial complexity and
basically are just clever optimizations of the brute-force approach.

This one-way function is used by a well known scheme:
- *RSA* encryption and digital signature

To be fair there exists an efficient theoretical algorithm, **Shoor algorithm**,
that allows efficient factorization of prime numbers. This algorithm requires a
quantum computer, something that we don't have today.


## Encryption

Given a one-way trapdoor `f`:

- Encrypt: `E(pub, m) = f(pub, m) = c`
- Verify : `D(sec, c) = f⁻¹(sec, c) = m`


## Digital Signature

Given a one-way function `f`, one technique to digitally sign a message `m` is
to apply the decryption function with the `sec` key, to verify the signature
we can apply the encryption function with `pub` key.

    sign:       D(sec, m) = s
    verify:     E(pub, s) = m

The details depend on the specific scheme, and this direct usage of the
encryption scheme is not possible for some schemes. There are schemes designed
to be only used as digital signature primitives.

If we only require authentication then there are more lightweight schemes based
on hash functions (e.g. HMAC or CMAC).

---

[^1]: The fundamental principles of public key cryptography had been proposed
earlier by James H. Ellis in 1970 at the Government Communications Headquarters
(GCHQ) in the United Kingdom. However, their work was kept classified until
1997, so it was not widely known.
