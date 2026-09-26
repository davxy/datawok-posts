+++
title = "Introduction to Perfect Secrecy"
date = "2023-08-30"
modified = "2023-08-30"
tags = ["cryptography"]
toc = true
+++

A cipher has perfect secrecy if the ciphertext gives no information about the
plaintext, even to an adversary with unlimited computational power.

Perfect secrecy is the strongest case of unconditional security. A scheme is
unconditionally secure if its security doesn't depend on a computational
assumption, but it can still leak a small amount of information.


## A Bit of History

The invention of the one time pad is usually credited to *Gilbert Vernam* of
AT&T and *Joseph Mauborgne* of the U.S. Army Signal Corps. In 1917 Vernam built
a teleprinter device which xors each character of the message with a character
from a key tape. Mauborgne realized that the cipher can't be broken if the key
tape is perfectly random and is never reused.

In 2011 *Steven Bellovin* found that they were anticipated by about 35 years.
In 1882 *Frank Miller*, a banker from Sacramento, described a one time pad in
his *Telegraphic Code to Insure Privacy and Secrecy in the Transmission of
Telegrams* ([paper](https://doi.org/10.1080/01611194.2011.583711)). Most likely
nobody ever used Miller's system for real messages.

The proof of the security came later. *Claude Shannon* wrote his results in a
classified report in 1945, and published them in 1949 with
[Communication Theory of Secrecy Systems](https://doi.org/10.1002/j.1538-7305.1949.tb00928.x).
In the Soviet Union, *Vladimir Kotelnikov* proved the same result independently
in a report of 1941, which apparently is still classified.


## Perfect Secrecy Foundations

We define the following **random variables**:
- `M` taking values from the plaintext set.
- `C` taking values from the ciphertext set.
- `K` taking values from the key set.

With a small abuse of notation, we use the same letters for the sets, e.g.
`m ∈ M`.

- `M` and `K` are independent variables with known probability distributions
  `p(M)` and `p(K)`.
- `C` is a function of `M` and `K`, i.e. `C = E(K, M)`. Thus `p(C)` is
  determined by `p(M)`, `p(K)` and `E`.
- If we fix a message `m ∈ M` then the value of `c ∈ C` depends only on `k ∈ K`.
  But this alone doesn't imply that `M` and `C` are independent variables.

Even if `M` and `K` are independent, the function `E` may generate a `c ∈ C`
which may be more or less dependent on `m ∈ M`.

We assume that every element of the three sets has a non-zero probability.
Messages that are never sent and ciphertexts that are never produced can be
removed from the sets.

From now on, when it is clear from the context, we're going to write `p(M = m)`
as `p(m)`, the same applies for `C` and `K` variables.

**Perfect Secrecy**. For Shannon, a cipher is **perfect** if for all `m ∈ M` and
`c ∈ C`: `p(M=m|C=c) = p(M=m)`.

That is, observing the value of `c` doesn't leak any information about `m`, in
other words `M` and `C` are independent variables. By Bayes' theorem, this is
equivalent to `p(c|m) = p(c)`.

Note that this doesn't say anything about the probability distribution of `M`.
If some plaintext is more probable than the others, observing `c` doesn't change
its probability.

**Proposition**. In a perfect cipher `|C| ≤ |K|`.

*Proof*

Fix a message `m`. For every ciphertext `c` we have `p(c|m) = p(c) > 0`, thus
there exists a key `k` such that `E(k, m) = c`.

For a fixed `m`, each key produces exactly one ciphertext, thus different
ciphertexts require different keys, and `|C| ≤ |K|`.

∎

**Corollary**. In a perfect cipher `|M| ≤ |K|`.

*Proof*

For every cipher (perfect or not) the encryption function `E(k, ·)` must be
injective, otherwise decryption is ambiguous. Thus `|M| ≤ |C| ≤ |K|`.

∎

Note that it is not required to have `|M| = |C|`. Even if `|M| < |C|` the cipher
can still be perfect, as long as there are enough keys: `|K| ≥ |C|`.


## One Time Pad (Vernam Cipher)

The OTP cipher is defined over:
- Alphabet `A = { 0, 1 }`
- Plaintext `M ⊆ Aⁿ`
- Ciphertext `C = Aⁿ`
- Keyspace `K = Aⁿ`

With `Aⁿ` the set of binary strings of length `n`.

Shorter messages must be padded to `n` bits. Otherwise the length of the
ciphertext leaks the length of the message.

As usual, there is a known probability distribution `p(M)`, we can't do anything
about it (e.g. if `m ∈ M` is an English text then it will follow the known
distribution for English letters).

For `p(K)` we can instead choose the probability distribution, and we're going
to use the uniform distribution: `p(k) = 1/2ⁿ`.

Encryption and decryption procedures are defined as bitwise xor of the input
binary string with the key binary string:

    Eₖ(m) = m ⊕ k = c
    Dₖ(c) = c ⊕ k = m

Even though different elements of `M` have different probabilities these don't
influence the ciphertext probabilities that are driven only by the key uniform
distribution.

For example:

    |K| = 2⁴, M = { 0101, 1010 }, p(M = 0101) = 3/4, p(M = 1010) = 1/4

Regardless of the value of `m`, the ciphertext `c` has the same probability to
be one of the `2⁴` possible values.

The important point is that the message distribution can be arbitrarily skewed;
it doesn't matter. The key distribution supplies exactly the amount of randomness
needed to make the ciphertext equally likely.

**Proposition**. OTP is a perfect cipher:

    p(m|c) = p(m).

*Proof*

By Bayes' theorem:

    p(m|c) = p(c|m)·p(m)/p(c)

For a fixed pair of `c` and `m`, in OTP there exists a unique key `k = c ⊕ m`
such that `Eₖ(m) = c`. It follows that for a fixed `m` the probability that it
encrypts to `c` is equal to the probability to choose `k`:

    p(c|m) = p(k) = 1/2ⁿ

To compute `p(c)`, let `m₁, .., mₜ` be the elements of `M`:

    p(c) = p(c,m₁) + .. + p(c,mₜ)
         = p(c|m₁)·p(m₁) + .. + p(c|mₜ)·p(mₜ)
         = 1/2ⁿ · (p(m₁) + .. + p(mₜ))
         = 1/2ⁿ

Thus:

    p(m|c) = (1/2ⁿ · p(m)) / (1/2ⁿ) = p(m)

∎

### Reusing the Key

If we want to preserve the perfect-secrecy property over the encryption of
different messages, then we must choose a new key for each message:

    c₁ = m₁ ⊕ k
    c₂ = m₂ ⊕ k
    c₁ ⊕ c₂ = m₁ ⊕ m₂

The pair `(c₁, c₂)` reveals `m₁ ⊕ m₂`, thus the ciphertexts are no longer
independent of the messages. For example, if we know `m₁` then we can recover
`m₂ = c₁ ⊕ c₂ ⊕ m₁`, regardless of `p(m₂)`.

Reusing the key, also makes OTP extremely weak as it easily
[leaks information](https://crypto.stackexchange.com/questions/59/taking-advantage-of-one-time-pad-key-reuse)
e.g. with pictures or using **crib-dragging** attack.

### Key Reuse in Practice

The xor of two ciphertexts encrypted with the same key is known as a **depth**.
History has two famous examples.

The German High Command used the
[Lorenz](https://en.wikipedia.org/wiki/Lorenz_cipher) teleprinter cipher, a
Vernam-like cipher where the key is generated by a set of pinwheels. Thus the
key is only pseudo-random, and the cipher is not perfect even without reuse.
On 30 August 1941 an operator sent a message of about 4000 characters from
Athens to Vienna. The receiver asked for a retransmission, and the operator
sent the message again with the same key settings, but with some abbreviations.
*John Tiltman* at Bletchley Park recovered both plaintexts, and thus about 4000
characters of key, in about ten days. From this key *Bill Tutte* deduced the
logical structure of the machine, without ever seeing one. This work led to
Colossus, operational at Bletchley Park in early 1944.

The Soviets used true one time pads, but under the pressure of the German
advance on Moscow the manufacturer printed some pad pages twice. From 1943, the
U.S. [Venona](https://en.wikipedia.org/wiki/Venona_project) project searched
for these depths. Less than 3000 messages were partially or completely
decrypted, out of hundreds of thousands. These were enough to expose spies such
as *Klaus Fuchs*, *Julius and Ethel Rosenberg* and *Donald Maclean*.

In both cases the cipher was correct in theory. An operational error in the key
management was enough to break it.


## Latin Squares

Latin squares are `N⨯N` tables where each of `N` symbols appears exactly once in
every row and in every column. For example:

        ⌈ 1 2 3 ⌉
    E = | 3 1 2 |
        ⌊ 2 3 1 ⌋

Given a Latin square of size `N⨯N`, we number the keys, the messages and the
ciphertexts from `1` to `N`. The **Latin square cipher** encrypts `m ∈ M` with
`k ∈ K` using `k` and `m` as row and column indices of the encryption table `E`:

    E(k,m) = c,  (example: E(2,1) = 3)

Every row of `E` is a permutation, thus the decryption table is defined by
`D(k,c) = m` if and only if `E(k,m) = c`. The row `k` of `D` is the inverse of
the permutation in the row `k` of `E`:

        ⌈ 1 2 3 ⌉
    D = | 2 3 1 |
        ⌊ 3 1 2 ⌋

Note that `D` is a Latin square too.

**Proposition**. The Latin square cipher with a uniform key distribution
`p(k) = 1/N` is a perfect cipher.

*Proof*

In the column `m` each ciphertext `c` appears exactly once, thus there exists a
unique key `k` such that `E(k,m) = c`. This is the only property of OTP used in
its proof, and the same steps give `p(c|m) = p(c) = 1/N`, thus `p(m|c) = p(m)`.

∎

The one time pad is a particular Latin square where the map from `(k, m)` to `c`
is the xor. In a general Latin square this map is completely arbitrary.

The Latin square for OTP with a key length of 2 is:

            00 01 10 11
          +------------
       00 | 00 01 10 11        0 1 2 3
       01 | 01 00 11 10   <=>  1 0 3 2
       10 | 10 11 00 01        2 3 0 1  
       11 | 11 10 01 00        3 2 1 0

Since xor is its own inverse, for OTP we have `D = E`.

More generally, the operation table of any finite group is a Latin square, with
`E(k,m) = k·m`. OTP is the xor on `n`-bit strings, and the `3⨯3` example above
is the addition mod 3, up to the numbering of the keys: every row is a cyclic
shift of the first one. With the addition mod 26 we get the Caesar cipher. With
a uniform key, used for a single letter, it is perfect too. The Caesar cipher is
weak only because the same key encrypts all the letters of a message.

A general Latin square doesn't give a better cipher. For `n`-bit messages the
table has `2ⁿ⨯2ⁿ` entries, both parties must store it, and the key must still
be random and used only once. The xor gives the same security without any
table. The value of the generalization is in the understanding: perfect secrecy
comes from the structure of the table, not from the xor.

Latin squares are more than an example. Shannon proved that when
`|M| = |C| = |K|`, a cipher is perfect if and only if every key has probability
`1/|K|` and for every `m` and `c` there exists a unique key `k` such that
`E(k,m) = c`. That is, every perfect cipher of this size is a Latin square with
a uniform key distribution.
