+++
title = 'Discrete Logarithm'
date = '2023-03-29'
modified = '2023-12-14'
tags = ['cryptography','number-theory']
toc = true
+++

Discrete logarithm is a fundamental concept in modern cryptography, with
numerous applications in key exchange, digital signatures, and other
cryptographic protocols.

This post explores the basics of discrete logarithm, some important
cryptographic protocols derived from it and the most important attacks.


## Discrete Logarithm

Given `g` a generator for a cyclic group `G` with order `n`, the **modular
exponentiation** function is defined as a mapping from `Zₙ` to `G`.

    exp: Zₙ → G,    exp(i) = gⁱ

Where `gⁱ` represents the application of the group operation `i` times on `g`.

For example, if `G = Zₚ*` and the operation is the product then `gⁱ = ∏ₖ g mod p`,
for `k = 1..i` and `i ∈ Zₙ`

When applied to a generator of a cyclic group, `exp` is injective and surjective
(by definition of generator), we can thus define the inverse function.

The **discrete logarithm** function is defined as:

    ind: G → Zₙ,    ind(gⁱ) = i

Discrete logarithm is not a monotonic function, and currently we don't know any
efficient algorithm to compute it.

**Proposition**. Given `x, y ∈ G` and a generator `g` of order `n`:

    ind(x·y) = (ind(x) + ind(y)) mod n

This can be easily proven by considering that the group is cyclic and `g`
has a cycle with period `n` (i.e. `gⁱ = g^(i + k·n) ∀ k ∈ Z`).

For example, if `G = Zₚ*` and `n = φ(p)`

    ind(x) ≡ A (mod m), ind(y) ≡ B (mod p)

    → x = gᴬ mod p , y = gᴮ mod p
    → x·y ≡ gᴬ·gᴮ ≡ gᴬ⁺ᴮ ≡ g^[(A + B) mod φ(p)] (mod p)
    → ind(x·y) = (A + B) mod φ(p)

    → ind(x·y) = (ind(x) + ind(y)) mod φ(p)

### Notation

Based on what is the group operation, the practical details of the discrete
logarithm function changes, but the semantics is the same: how many times we
apply the group operation to the generator.

**Exponential notation** is used when the group operation is the multiplication
(e.g. multiplication of scalars in some prime group):

    x = g·..·g = gᵏ

**Multiplicative notation** is used when the group operation is the addition
(e.g. addition of points in some elliptic curve group):

    x = g+..+g = k·g

In both cases we write `ind(x) = k`.

To be abstract and generic, if not specifically required, the group operation
will not be specified, and exponential notation is used.

Where we have to manipulate a message `m` we assume the existence of a bijective
mapping from the *message domain* `M` to the group domain `G`. For example, we
may need to interpret `m` as a number in `Zₚ*` or as a point in an elliptic curve.

We also may need to map the output of an operation in `G` to a value in `n = |G|`.
In this case we define the abstract function `map_to_group_ord: G → Zₙ`.

For example:
- `G` is an elliptic curve and `a` a point: `map_to_group_ord(a) = a.x mod n`
- `G` is `Zₚ*` and `a` a scalar: `map_to_group_ord(a) = a mod n`

### Discrete Logarithm Problem

The **discrete logarithm problem (DLP)** is about finding the exponent to which
a given group element must be raised to obtain another given group element,
within a specific mathematical group.

The security of all the schemes in this post is attributed to the computational
hardness of solving the discrete logarithm problem and the lack of efficient
solution techniques.


## ElGamal Cipher

Setup:
- `G`: cyclic group with order `n`
- `g ∈ G`: generator for `G`
- `x ∈ Zₙ`: secret key
- `y ∈ G`: public key such that `y = gˣ`

Note that as a general rule we never choose as secret key `0` or `1` since
these are trivially identifiable (by definition of generator):

    g⁰ = 1 and g¹ = g

**Encryption**

Given a message `m ∈ G`, pick a random `k ∈ Zₙ*`.

    E = gᵏ     (ephemeral key)
    M = yᵏ     (masking key)
    c = M·m    (encrypted message)

The ciphertext is the tuple `(E, c)`.

**Decryption**

    M = Eˣ     (recovery of M using secret key)
    m = M⁻¹·c

To simplify a bit the decryption, we can first observe that if `(k,n) = 1`,
then `E = gᵏ` is another generator. Now, because, by definition of generator
`E⁰ = Eⁿ = 1` then `∀ x ∈ Z`, `Eⁿ⁻ˣ⁺ˣ = Eⁿ⁻ˣ·Eˣ = 1` which implies `E⁻ˣ = Eⁿ⁻ˣ`.

### Malleability

Given the ciphertext `(E, c = M·m)` the corresponding plaintext can be
predictably multiplied by a factor `z` by multiplying `c` by `z`.

    c' = z·c  →  m' = M⁻¹·c' = M⁻¹·z·c = M⁻¹·z·M·m = z·m


## ElGamal Signature

The scheme parameters are the same as the *ElGamal* cipher.

Given the message `m`, the secret key `x` and public key `y = gˣ`, pick a random
scalar `k` which is relatively prime with the group order `n`.

    R = gᵏ
    r = map_to_group_ord(R)
    s = (m - x·r)·k⁻¹ mod n

If `s = 0` we repeat with a different `k`.

The signature is the couple `(R, s)`.

**Verification**

Check if

     Rˢ·yʳ = gᵐ

*Proof*

    Rˢ = gᵏˢ = g^[k·(m - x·r)·k⁻¹] = g^(m - x·r)
    yʳ = gˣʳ
    → Rˢ·yʳ = g^(m - x·r + x·r) = gᵐ

The verifier can't discover the secret `x` as he first needs to recover `k`,
which imply finding the discrete logarithm for `r`.

The signer can't forge valid signatures without knowing the secret `x`.

### Existential forgery

Select `e ∈ Zₙ` and `v ∈ Zₙ*`.

Set `R = gᵉ·yᵛ` and `s = -r·v⁻¹`. Then the tuple `(r, s)` is a valid
signature for the message `m = e·s`.

This vulnerability is easily addressed by replacing `m` with `H(m)` in the
signature and verification procedures. With `H` a cryptographic hash function.

### Reusing random secret

If the same value `k` is used to sign different messages then the secret key `x`
can be easily recovered.

    s₁ = (m₁ - x·r)·k⁻¹ mod n
    s₂ = (m₂ - x·r)·k⁻¹ mod n
    s₁ - s₂ = (m₁ - m₂)·k⁻¹ mod n
    →  k = (m₁ - m₂)·(s₁ - s₂)⁻¹ mod n
    →  x = (m₁ - s₁·k)·r⁻¹ mod n

The only requirement is that both `s₁ - s₂` and `r` are in `Zₙ*`.


## Digital Signature Standard

Also known as **DSA** (Digital Signature Algorithm), is a slightly modified
version of *ElGamal* signature to address some of its weakness.

Setup:
- `G`: cyclic group with **prime** order `n`
- `g ∈ G`: a generator for `G`
- `x ∈ Zₙ`: secret key
- `y ∈ G`: public key such that `y = gˣ`
- `H`: a cryptographic hash such that `H(m) ∈ Zₙ`, for any message `m`

Given a message `m`, we pick a random scalar `k ∈ Zₙ*`.

    R = gᵏ
    r = map_to_group_ord(R)
    s = (H(m) + x·r)·k⁻¹ mod n

If `s = 0` we repeat with a different `k`.

The signature is the couple `(r, s)`.

**Verification**

    u = H(m)·s⁻¹ mod n
    w = r·s⁻¹ mod n

    V = gᵘ·yʷ
    v = map_to_group_ord(V)

    Valid if v = r

*Proof*

    gᵘ·yʷ = g^(u + x·w)

    u + x·w ≡ H(m)·s⁻¹ + x·r·s⁻¹ ≡ s⁻¹·(H(m) + x·r) ≡ s⁻¹·s·k ≡ k (mod n)

    → gᵘ·yʷ = r

DSA is more efficient than ElGamal signatures as:
- It uses smaller exponents and still provides the same security. It works with
  a group with prime order which in general provides the same security as one
  bigger group with non-prime order (see [Pohlig-Hellman](#pohlig-hellman-algorithm)
  attack).
- It produces signatures that are shorter as both `r` and `s` are in `Zₙ`.
  In ElGamal we send the full `R ∈ G` as we need it for verification.
- On verification, only two exponentiation in `G` are performed, in contrast to
  three with ElGamal.

### Reusing random secret

If the same value `k` used to sign different messages then the secret key `x`
can be easily recovered.

    s₁ = (H(m₁) + x·r)·k⁻¹ mod n
    s₂ = (H(m₂) + x·r)·k⁻¹ mod n
    s₁ - s₂ = (H(m₁) - H(m₂))·k⁻¹ mod n
    →  k = (H(m₁) - H(m₂))·(s₁ - s₂)⁻¹ mod n
    →  x = (s₁·k - m₁)·r⁻¹ mod n


## Schnorr Scheme

### Interactive Schnorr Protocol

A kind of interactive **zero-knowledge** proof used to prove knowledge of some
secret without revealing it.

In particular, in this context, it is used to prove knowledge of the discrete
logarithm of a value with respect to a public generator.

Setup:
- `G`: cyclic group with prime order `n`
- `g ∈ G`: a generator for `G`
- `x ∈ Zₙ*`: secret scalar
- `y ∈ G`: public group element such that `y = gˣ`


`P` wants to prove to `V` the knowledge of the discrete logarithm of `y`.

Protocol:
1. *Commitment*: `P` chooses a random secret scalar `k ∈ Zₙ*`, computes `r = gᵏ`,
   and sends it to `V`.
2. *Challenge*: `V` chooses a random value `c` and sends it to `P`.
3. *Response*: `P` computes `s = k + c·x mod n` and sends it to `V`.
4. *Verification*: `V` checks whether `gˢ = r·yᶜ`.

Verification Proof:

    gˢ = g^(k + c·x) = gᵏ·gˣᶜ = r·yᶜ

Security:
- To extract the secret `x`, `V` must compute `x = (s - k)·c⁻¹ mod n`.
  To do so, he must know the value of `k`, discrete log of `r`.
- `P` can't cheat as well. The only way to cheat is if he's able to know the
  value of `c` before committing the value `k`. In that case he can compute
  `r = gˢ·x⁻ᶜ` for an arbitrary value `s`.

### Non-Interactive Schnorr Protocol

The protocol can be made non-interactive by modifying the challenge step.

The challenge value is obtained from a technique known as
**[Fiat-Shamir Heuristic](https://en.wikipedia.org/wiki/Fiat-Shamir_heuristic)**.
In practice, is computed as the output of a cryptographic hash function.

    c = H(y || r)

### Schnorr Signature

If we also bind a message `m` to the challenge then we obtain a **Signature Scheme**:

    c = H(y || r || m)

### Reusing random secret

If the same value `k` used with two different challenges then the secret key `x`
can be easily recovered.

    s₁ = k + c₁·x mod n
    s₂ = k + c₂·x mod n
    s₁ - s₂ = (c₁ - c₂)·x
    →  x = (s₁ - s₂)·(c₁ - c₂)⁻¹ mod n


## Chaum-Pedersen DLEQ Scheme

`P` wants to prove to `V` that two public values `y₁ = gˣ` and `y₂ = hˣ` have
the same discrete logarithm with respect to the two generators `g` and `h`.

Setup:
- `G₁` and `G₂`: two cyclic groups with same prime order `n`
- `g ∈ G₁` and `h ∈ G₂`: generators of `G₁` and `G₂` respectively
- `x ∈ Zₙ*`: secret scalar
- `y₁, y₂ ∈ G`: public group element such that `y₁ = gˣ` and `y₂ = hˣ`

Protocol:
- *Commitment*: `P` chooses a random secret scalar `k` and sends to `V` the couple
  `r₁ = gᵏ` and `r₂ = hᵏ`.
- *Challenge*: `V` chooses a random scalar `c` and sends it to `P`.
- *Response*: `P` computes `s = k + c·x mod n` and sends it to `V`.
- *Verification*: `V` checks if `gˢ = r₁·y₁ᶜ` and `hˢ = r₂·y₂ᶜ`.

Note that the verification for the individual values is equal to the *Schnorr*
protocol, as a consequence `P` also prove knowledge of the secret and not just
equality.

The verification and security proofs are quite similar to the Schnorr protocol.

### Non-Interactive Chaum-Pedersen DLEQ Protocol

The idea is basically the same used for the *Schnorr* signature.

The challenge `c` is computed as:

    c = H(y₁ || y₂ || r₁ || r₂).


## Diffie-Hellman Key Exchange Protocol

The protocol is used to generate a shared secret between two parties `A` and
`B`.

Setup:
- `G`: cyclic group with order `n`
- `g ∈ G`: a generator for `G`
- `a ∈ Zₙ*`: `A` secret key
- `yₐ ∈ G`: `A`'s public key `yₐ = gᵃ`
- `b ∈ Zₙ*`: `B` secret key
- `yᵦ ∈ G`: `B`'s public key `yᵦ = gᵇ`

Protocol:
- `A` generates `a ∈ Zₙ` and sends to `B` the public `yₐ = gᵃ`
- `B` generates `b ∈ Zₙ*` and sends to `A` the public `yᵦ = gᵇ`
- `A` computes `k = yᵦᵃ`
- `B` computes `k = yₐᵇ`

The proof that the two parties gets the same `k` trivially follow the
commutativity of the exponent in exponentiation.

### Man in The Middle Attack

In a public network there can be a third actor `C` that performs a DH protocol
instance with both `A` and `B`. When communicates with `A` he impersonates `B`
and when it communicates with `B` he impersonates `A`.

The popular defense is to introduce some form of *data-origin authentication*.
For example by signing the public keys with a key trusted by both the entities
(i.e. some form of authority as done by *PKI*).


## Attacks to DLP

Attacks against DLP can be divided in two classes:
- **generic**: they work in any cyclic group, using only the group operation;
- **specialized**: exploit special properties of a particular cyclic group.

Attacks can be further divided into two more classes:
- running time dependent on the size of the cyclic group;
- running time dependent on the size of the prime factors of the group order.

In the attacks' analysis each step corresponds to a group operation.

Given the cyclic group `G` with order `n` and a generator `g`, let's assume we
want to compute the discrete logarithm of `y = gˣ`.

### Brute-Force Search

Generic algorithm where we simply repeat the group operation for the generator
`g` until the result is equal to `y`.

On average, for a random value `x`, we expect to find the correct solution after
checking half of all the possibilities.

This gives a complexity of `O(n)` steps.

To make brute-force infeasible is thus sufficient to choose a group `G` with
a large enough order.

### Shanks' Algorithm

Also known as *Baby-Step Giant-Step* method, is a generic algorithm which trades
time for memory.

The discrete logarithm is rewritten as:

    m = ⌈√n⌉
    x = m·x₁ + x₂  , for 0 ≤ x₁, x₂ < m

We rewrite `y` as:

    y = gˣ = g^(m·x₁ + x₂) = g^(m·x₁) · g^x₂

    → y·g^(-m·x₁) = g^x₂

The value of `g⁻ᵐ` is known. The algorithm tries to find the solution `(x₁, x₂)`.

The idea is to search for `x₁` and `x₂` separately.

In the first phase all the possible values for `g^x₂` are computed and stored
in a lookup table.

This phase requires `O(√n)` steps and needs to store `O(√n)` group elements.

The computed values for `g^x₂` can be computed offline once (per group
generator) and are independent on the exact value of `y`.

In the second phase we check for all `x₁` until we don't find the value which
satisfies the equation (using the pre-computed `x₂` values).

    y·g^(-m·x₁) ≟ g^x₂

The second phase requires `O(√n)` computational steps.

The implication of this attack is a reduction of complexity for the general DLP.
For example, to achieve at least `128` bits of security we require `n ≥ 2²⁵⁶`.

### Pollard's Rho Algorithm

This algorithm is currently the best known algorithm for computing the discrete
logarithm for elliptic curve groups.

Is based on the [birthday paradox](/posts/birthday-paradox), which asserts that
to achieve a probability `p` of finding a collision while randomly extracting
items from a set of `d` elements we need to extract: `n(p) ≈ √(2·d·ln(1/(1-p)))`.
For example, with `p = 1/2` we have `n = √(2·d·ln(2))`.

Pseudo-randomly generate group elements of the form `gⁱ·yʲ`. 

For each element keep track of the values `i` and `j`.

Continue until a collision is found: `g^i₁·y^j₁ = g^i₂·y^j₂`.

Which leads to the relation:

    i₁ + x·j₁ ≡ i₂ + x·j₂ (mod n)
    i₁ - i₂ ≡ x·(j₂ - j₁) (mod n)

If `gcd(j₂ - j₁, n) = 1`, then:

    x = (i₁ - i₂)·(j₂ - j₁)⁻¹ mod n

A clever pseudo-random function for `i` and `j` generation is presented by
Stinson[^1].


### Pohlig-Hellman Algorithm

The algorithm reduces the discrete logarithm problem in a group with a composite
order `n` to separate instances of the problem in subgroups of prime order `pᵢ`.

For each prime-order subgroup, another algorithm is applied, like Pollard's rho,
to solve the discrete log problem. Thus, this is essentially a pre-processing
phase that optimizes the problem for these more efficient algorithms when the
group order has small prime factors.

Given `y = gˣ` and `n = ∏ pᵢ^eᵢ`, the algorithm tries to compute the smaller
discrete logarithms `xᵢ = x mod pᵢ^eᵢ`.

Once the values `xᵢ = x mod pᵢ^eᵢ` for all the prime factors `pᵢ` are found, the
solution for `n` is trivially found by direct application of CRT.

Let `p` be a prime such that `pᵉ` is a factor of `n`. We want to compute the
value `r = x mod pᵉ` (without knowing `x` obviously).

Because `r < pᵉ`, then we can express `r` in base `p` as:

    r = ∑ rⱼ·pʲ , with 0 ≤ rⱼ < p  and for 0 ≤ j < e

Also, because `r = x mod pᵉ`, we can express `x` as:

    x = pᵉ·q + r = pᵉ·q + ∑ rⱼ·pʲ

For some integer `q`.

The first step is to compute `r₀` by observing that `y^(n/p) = g^(r₀·n/p)`.

*Proof*:

    y^(n/p) = g^(x·n/p)

    →  x·n/p = (pᵉ·q + ∑ rⱼ·pʲ)·n/p
             = (τ·p + r₀)·n/p
             = τ·n + r₀·n/p
             ≡ r₀·n/p (mod n)

Using this fact we proceed by trying to find the `r₀` which satisfies the
equation in `O(p)` steps.

If `e = 1` then `x ≡ r₀ (mod p)` and thus we're done. Otherwise, we proceed
determining `rⱼ` for all the other exponents `j < e`.

Define `y₀ = y` and `yⱼ = y·g^[-(r₀ + r₁·p + .. + rⱼ₋₁·pʲ⁻¹)] = ` 

This time we'll use the generalized equation `yⱼ^(n/pʲ⁺¹) = g^(rⱼ·n/p)`.

*Proof*:

    yⱼ^(n/pʲ⁺¹) = g^[(x - r₀ - r₁·p - .. - rⱼ₋₁·pʲ⁻¹)·n/pʲ⁺¹]

    → (x - r₀ - r₁·p - .. - rⱼ₋₁·pʲ⁻¹)·n/pʲ⁺¹
      = (pᵉ·q + ∑ rⱼ·pʲ - r₀ - r₁·p - .. - rⱼ₋₁·pʲ⁻¹)·n/pʲ⁺¹
      = (τⱼ·pʲ⁺¹ + rⱼ·pʲ)·n/pʲ⁺¹
      = τⱼ·n + rⱼ·n/p
      ≡ rⱼ·n/p (mod n)

We proceed computing each `rⱼ` in `O(p)` steps.

This can be improved by noting that finding `rᵢ` for `σ = g^(rᵢ·n/p)` is
equivalent to find `rᵢ = log_[g^(n/p)](σ)` and that `g^(n/p)` has order `p`.

We can try to find each `rᵢ` using any other DLP attack method, thus reducing
the complexity to find each `rᵢ` to `O(√p)`.

To contrast this attack the group order must have its largest prime factor in
a range that is considered safe (e.g. today something like `2¹⁶⁰`).

In practice, some popular cryptographic schemes defined over the DLP work
in a prime order group.

### Index Calculus Algorithm

Efficient method for cyclic groups `Zₚ*` and the multiplicative group of nonzero
elements in `GF(pᵐ), m > 1` (extension fields).

The idea comes from the fact that a significant number of elements of `G` can
be expressed as the product of elements of a small subset of `G`.

The attack is so powerful that to provide `80` bit security the prime of a DLP
in `Zₚ*` should be at least `1024` bit long!

#### Pre-Computation

Let `B = { pᵢ }` be a subset of small primes in `Zₚ*`.

In the first phase we find the logarithm of the `|B|` primes for base `g`.

Let `C` be the set of congruences defined using pseudo random values `xⱼ`
and such that `g^xⱼ` has all its factors in `B` (we can use trial division):

    C = { g^xⱼ ≡ ∏ pᵢ^aᵢⱼ (mod p) },  for some exponents set {aᵢⱼ}

Define `|C|` to be slightly bigger that `|B|`.

The elements of `C` can be rewritten as:

    xⱼ ≡ ∑ aᵢⱼ·log_g(pᵢ) (mod p-1)

We end up with `|C|` congruences in `|B|` unknowns (`{log_g(pᵢ)}`) which
hopefully have a unique solution modulo `p-1`.

This phase is carried out offline and an attacked can generate a big set
of tuples `L = { (pᵢ, log_g(pᵢ)) }` for a generator `g`.

#### Attack

We want to recover the discrete logarithm for a generic `y = gˣ`.

Choose a random integer `s` (`0 < s < p - 1`) such that `σ = y·gˢ mod p` can be
factored using just elements in `B`:

    y·gˢ ≡ ∏ pᵢ^zᵢ (mod p)

Which can be rewritten as:

    log_g(y) + s ≡ ∑ zᵢ·log_g(pᵢ) (mod p-1)

The only unknown in this equation is `log_g(y)`, which gives us `x`.

Asymptotic run times:
- pre-computation: `e^[(1 + o(1))·√(ln(p)·ln(ln(p)))]`
- attack: `e^[(1/2 + o(1))·√(ln(p)·ln(ln(p)))]`

##  References

- Cyclic groups [notes](/posts/cyclic-groups)
- Shanks algorithm Rust PoC [here](https://github.com/davxy/crypto-hacks/tree/main/shanks-algorithm)
- Reusing the ephemeral secret failure PoC [here](https://github.com/davxy/crypto-hacks/tree/main/ed25519-dalek-secret-recovery)
- [Merlin](https://merlin.cool) - Rust implementation which automates the Fiat-Shamir transform.

[^1]: Cryptography Theory and Practice - Douglas Stinson
