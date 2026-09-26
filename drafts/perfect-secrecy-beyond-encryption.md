+++
title = "Perfect Secrecy Beyond Encryption"
date = "2026-09-24"
modified = "2026-09-24"
tags = ["cryptography", "draft"]
toc = true
draft = true
+++

In the [introduction to perfect secrecy](/posts/perfect-secrecy-intro)
we saw that the one time pad hides a message with a uniform key, used only
once, and that the same argument works in any group. The same construction
appears in many other primitives. Some of them are unconditionally secure,
others are not, but in all of them the pad plays the same role.


## Secret Sharing

In 1979 *Adi Shamir* published
[How to Share a Secret](https://doi.org/10.1145/359168.359176), a scheme to
split a secret `s` into `n` shares such that:
- any `t` shares allow the reconstruction of `s`;
- any `t-1` shares give no information about `s`.

The value `t` is the **threshold**.

All the operations are in the field `𝔽_q`, with `q` a prime greater than `n`.
The secret is an element `s ∈ 𝔽_q`.

The dealer chooses the coefficients `a₁, .., aₜ₋₁` uniformly at random from
`𝔽_q`, and defines the polynomial of degree at most `t-1`:

    f(x) = s + a₁·x + .. + aₜ₋₁·xᵗ⁻¹

Thus `f(0) = s`. The share of the party `i` is the point `(i, f(i))`, for
`i = 1, .., n`.

A polynomial of degree at most `t-1` is uniquely determined by `t` points. Given
the shares `(x₁, y₁), .., (xₜ, yₜ)`, Lagrange interpolation gives the secret:

    s = f(0) = y₁·λ₁ + .. + yₜ·λₜ,    λᵢ = ∏ⱼ≠ᵢ xⱼ/(xⱼ - xᵢ)

For example, with `q = 13`, `s = 7`, `t = 3` and `n = 5`:

    f(x) = 7 + 5x + 2x²

    shares: (1, 1), (2, 12), (3, 1), (4, 7), (5, 4)

With the shares of the parties 1, 2 and 4 (all the values are in `𝔽₁₃`):

    λ₁ = (2·4)/((2-1)(4-1)) = 8/3 = 7
    λ₂ = (1·4)/((1-2)(4-2)) = -2  = 11
    λ₄ = (1·2)/((1-4)(2-4)) = 1/3 = 9

    s = 1·7 + 12·11 + 7·9 = 202 = 7

**Proposition**. Any `t-1` shares give no information about the secret:

    p(s|y₁, .., yₜ₋₁) = p(s)

*Proof*

Fix the shares `(x₁, y₁), .., (xₜ₋₁, yₜ₋₁)` and any candidate secret `s'`. The
`t` points `(0, s'), (x₁, y₁), .., (xₜ₋₁, yₜ₋₁)` determine exactly one
polynomial of degree at most `t-1`, thus exactly one choice of the coefficients
`a₁, .., aₜ₋₁`.

The coefficients are uniform and independent of the secret, thus for every `s'`:

    p(y₁, .., yₜ₋₁|s') = 1/qᵗ⁻¹

This is the same situation as the
[OTP proof](/posts/perfect-secrecy-intro/#one-time-pad-vernam-cipher), where
the coefficients take the role of the key. For a fixed pair of secret and
shares there is a unique key. Then `p(y₁, .., yₜ₋₁) = 1/qᵗ⁻¹` and, by Bayes'
theorem, `p(s|y₁, .., yₜ₋₁) = p(s)`.

∎

In the example, the two shares `(1, 1)` and `(2, 12)` are consistent with every
secret in `𝔽₁₃`: for each value of `s'` there is exactly one polynomial.

The link with OTP is even more direct for `t = 2`. A single share is
`y = s + a₁·x`, and for `x ≠ 0` the value `a₁·x` is uniform in `𝔽_q`. Thus a
share is an OTP encryption of `s`, with the addition mod `q` in place of the
xor.

As for OTP, perfect secrecy has a cost. In a perfect secret sharing scheme,
each share must be at least as large as the secret.


## One-Time MAC

The one time pad gives secrecy, but not integrity. The adversary can't read the
message, but can flip any bit of the ciphertext, and the same bit of the
plaintext flips too. If the adversary knows the position of an amount in a
message, then the adversary can change the amount without any knowledge of the
key.

Authentication can be unconditionally secure too. In 1981 *Mark Wegman* and
*Larry Carter* published
[New Hash Functions and Their Use in Authentication and Set Equality](https://doi.org/10.1016/0022-0000(81)90033-7),
with a message authentication code (MAC) whose security doesn't depend on the
computational power of the adversary.

The key is a pair `(a, b)` uniform in `𝔽_q²`. For a message `m ∈ 𝔽_q` the tag
is:

    t = a·m + b

**Proposition**. An adversary who sees one pair `(m, t)` can produce a valid
pair `(m', t')`, with `m' ≠ m`, with probability `1/q`.

*Proof*

For each value of `a` there is exactly one `b = t - a·m` consistent with the
pair `(m, t)`. Thus there are `q` consistent keys, all with the same
probability. That is, `b` is a one time pad on `a·m`, and `t` gives no
information about `a`.

The pair `(m', t')` is valid if `a·m' + b = t'`, that is if
`a·(m' - m) = t' - t`. Since `m' - m ≠ 0`, exactly one value of `a` satisfies
the equation, thus exactly one of the `q` consistent keys.

∎

For longer messages `m = (m₁, .., mₗ)` the tag is a polynomial in `a`:

    t = b + m₁·a + m₂·a² + .. + mₗ·aˡ

A forgery requires `a` to be a root of a non-zero polynomial of degree at most
`l`, thus the probability of success is at most `l/q`.

As the name says, the key must be used only once. With two tags under the same
key the pad cancels:

    t₁ - t₂ = a·(m₁ - m₂)  →  a = (t₁ - t₂)/(m₁ - m₂),  b = t₁ - a·m₁

and the adversary can produce valid tags for any message.

Poly1305 and GCM use this construction. The hash key `a` is reused, but the pad
`b` is fresh for each message, and a cipher computes it from a nonce, e.g.
`b = AESₖ(nonce)`. In ChaCha20-Poly1305 both parts of the key are fresh for
each message. The pad is only pseudo-random, thus the security is
computational, and it holds only if the nonce never repeats.

If the nonce repeats in GCM, the difference of the two tags is a polynomial in
the hash key with known coefficients, and its roots give the key. *Antoine
Joux* described this "forbidden attack" in 2006. In 2016 *Böck et al.* found
184 HTTPS servers which repeated GCM nonces
([Nonce-Disrespecting Adversaries](https://eprint.iacr.org/2016/475)).


## Pedersen Commitments

A [commitment](/posts/journey-to-zero-knowledge/#commitment-protocols) must be:
- **hiding**: the commitment gives no information about the committed value;
- **binding**: the committer can't open the commitment to a different value.

In 1991 *Torben Pedersen* published
[a commitment scheme](https://doi.org/10.1007/3-540-46766-1_9) which is
perfectly hiding.

Let `g` and `h` be two generators of a group of prime order `q`, such that
nobody knows `λ` with `h = g^λ`. To commit to `m ∈ ℤ_q`:

    r ← uniform in ℤ_q
    C = gᵐ·hʳ

To open the commitment, the committer reveals `(m, r)`.

**Proposition**. For any `m`, the commitment `C` is uniform in the group.

*Proof*

`C = g^(m + λ·r)`. For a fixed `m`, the map `r → m + λ·r` is a bijection of
`ℤ_q`, since `λ ≠ 0`. Thus the exponent is uniform, and `C` is uniform.

∎

Again this is a one time pad: `hʳ` is the pad on `gᵐ`, with the group
multiplication in place of the xor.

The binding property is only computational. Two openings `(m, r)` and
`(m', r')` of the same commitment, with `m ≠ m'`, give:

    m + λ·r = m' + λ·r'  →  λ = (m - m')/(r' - r)

Thus a committer who can open to two values can compute the discrete logarithm
of `h`. Conversely, a committer with unlimited computational power can compute
`λ` and open `C` to any `m'` with `r' = r + (m - m')/λ`.

This limit is general. A commitment can't be both perfectly hiding and
perfectly binding. If a commitment `C` has no opening for some value `m`, then
`p(m|C) = 0 ≠ p(m)` and the scheme is not perfectly hiding. If every `C` has an
opening for every `m`, then an adversary with unlimited computational power can
find the one it needs.


## Schnorr Signatures

Public key schemes can't be unconditionally secure. The public key determines
the secret key, and an adversary with unlimited computational power can
compute the secret key from the public key by brute force. Nevertheless, a one
time pad hides in the Schnorr signature too.

Let `g` be a generator of a group of prime order `q`, `x ∈ ℤ_q` the secret key
and `X = gˣ` the public key. To sign a message `m`:

    k ← uniform in ℤ_q
    R = gᵏ
    c = H(X, R, m)
    s = k + c·x  mod q

The signature is `(R, s)`, and the verifier checks that `gˢ = R·Xᶜ`.

The value `s` is the one time pad encryption of `c·x`, with the nonce `k` as
the key and the addition mod `q` in place of the xor.

**Proposition**. For any fixed `x` and `c`, the value `s` is uniform in `ℤ_q`.

*Proof*

For every `s ∈ ℤ_q` there exists a unique nonce `k = s - c·x` which gives `s`.
The nonce is uniform, thus `p(s) = p(k) = 1/q`.

∎

This is the reason why the Schnorr identification protocol, where `c` is a
random challenge from an honest verifier, is **perfect** zero knowledge. We can
choose `c` and `s` uniformly and compute `R = gˢ·X⁻ᶜ`, without any knowledge of
`x`. These transcripts `(R, c, s)` have exactly the same distribution as the
real ones. For the signature, where `c` comes from the hash function, the same
argument holds in the random oracle model.

Note that this is not perfect secrecy of `x`: the public key `X` already
determines `x`. It means that the signatures don't give any information about
`x` in addition to what `X` gives.

### Reusing the Nonce

If the same nonce `k` is used for two signatures:

    s₁ = k + c₁·x
    s₂ = k + c₂·x
    s₁ - s₂ = (c₁ - c₂)·x  →  x = (s₁ - s₂)/(c₁ - c₂)

As for OTP, reusing the pad cancels it. But here the adversary recovers the
whole secret key, not only a relation between two messages.

The same attack applies to ECDSA. In December 2010, at the 27th Chaos
Communication Congress, the *fail0verflow* group showed that Sony signed the
PlayStation 3 software with ECDSA using the same nonce for every signature.
This allowed the recovery of the signing key, which *George Hotz* published on
3 January 2011.

A nonce that is not uniform, even if never reused, is also dangerous: with many
signatures a small bias allows the recovery of the key with lattice techniques.
For this reason many implementations derive the nonce deterministically from
the secret key and the message, e.g. with
[RFC 6979](https://www.rfc-editor.org/rfc/rfc6979). The same message gives the
same signature, and different messages give different nonces.


## Perfect Zero Knowledge

In [Journey to Zero-Knowledge](/posts/journey-to-zero-knowledge/#probability-distributions-distinguishability)
we classified the distributions of the simulator and of the real protocol as
equal, statistically indistinguishable or computationally indistinguishable.
The corresponding names are **perfect**, **statistical** and **computational**
zero knowledge.

Perfect zero knowledge is the perfect secrecy of proofs. The transcript of the
protocol has exactly the same distribution with or without the witness, also
for a verifier with unlimited computational power. For Shannon, the ciphertext
is independent of the message. Here the transcript is independent of the
witness.

The protocols with perfect zero knowledge use the same one time pad:
- In the [graph isomorphism](/posts/journey-to-zero-knowledge/#graph-isomorphism)
  protocol, Peggy masks the isomorphism `f` with a uniform permutation `πₓ`.
  The response `πᵧ` is uniform among the permutations which map `H` to `Gᵥ`,
  independently of `f`. This is a one time pad in the group of permutations.
- In the [quadratic residue](/posts/journey-to-zero-knowledge/#quadratic-residue)
  protocol, the response `z = r·w` is a one time pad on `w` in the group `ℤₙ*`.
- In the [Schnorr](#schnorr-signatures) identification protocol, the response
  `s = k + c·x` is a one time pad on `c·x` in `ℤ_q`.

### The Limit of Perfect Zero Knowledge

Some languages, such as graph isomorphism and quadratic residuosity, have
perfect zero knowledge proofs. For `NP`-complete languages such proofs probably
don't exist, even with statistical zero knowledge. The class `SZK` of
the languages with a statistical zero knowledge proof is contained in
`AM ∩ coAM` (*Fortnow*, *Aiello* and *Håstad*, 1987). If `NP ⊆ SZK`, then
`coNP ⊆ AM`, and by a result of *Boppana*, *Håstad* and *Zachos* the
polynomial hierarchy collapses to its second level.

Thus, for a generic `NP` statement, we must choose which property is
unconditional:
- **Unconditional soundness**, with computational zero knowledge. This is the
  [three coloring](/posts/journey-to-zero-knowledge/#graph-three-coloring)
  protocol of *Goldreich*, *Micali* and *Wigderson*, with commitments which are
  perfectly binding and computationally hiding.
- **Perfect zero knowledge**, with computational soundness. A protocol of this
  type is an **argument**. *Brassard*, *Chaum* and *Crépeau* obtained perfect
  zero knowledge arguments for all `NP` in 1988, with perfectly hiding
  commitments such as the Pedersen ones.

This is the same trade-off as for the [commitments](#pedersen-commitments). Zero
knowledge is the hiding side and soundness is the binding side, and they can't
be both unconditional.

The modern SNARKs are on the argument side.
[Groth16](https://eprint.iacr.org/2016/260) is perfect zero knowledge, and its soundness depends on assumptions about the
pairing groups. In [PLONK](https://eprint.iacr.org/2019/953) the prover adds a
random multiple of the vanishing polynomial `Z_H(X)` to each wire polynomial:

    a(X) = (b₁·X + b₂)·Z_H(X) + w₁·L₁(X) + .. + wₙ·Lₙ(X)

On the domain `H` the polynomial `Z_H(X)` is zero, thus the witness values
don't change. Outside `H` the random terms mask the values which the verifier
sees: the evaluation at the challenge point, and the secret point `τ` of the
[KZG](/posts/kzg_pcs) commitment. The KZG commitment is deterministic, thus
without the blinding it would not hide the witness. The pad is again a uniform
value, used only once.
