+++
title = "Classical Ciphers"
date = "2017-05-26"
modified = "2024-01-26"
tags = [ "cryptography", "history" ]
toc = true
+++

All modern ciphers are based on some kind of **substitution** operation.

A block of bits is substituted with another block of bits according to a given
table or algorithm.

**Monoalphabetic** cipher: the same element in the plaintext alphabet is
always encrypted to the same element in the ciphertext alphabet.

**Polyalphabetic** cipher: the same element in the plaintext alphabet may
be encrypted to different elements in the ciphertext alphabet.

Polyalphabetic ciphers algorithms typically depend on a key that is cyclically
used to encrypt the single letters. Thus are equivalent to a set of
monoalphabetic ciphers that are alternatively used.

Note that given a key with finite length, at some point the same letters are
encoded again to the same ciphertext (we loop through the key), thus in practice
polyalphabetic ciphers are equivalent to a monoalphabetic block cipher with
block length equal to the key length.

The distinction between a monoalphabetic and a polyalphabetic cipher thus
technically depends on the choice of what is the alphabet we work with, if
each block of a polyalphabetic cipher is interpreted as an element of a bigger
alphabet then the polyalphabetic cipher is still a monoalphabetic cipher.

Strictly speaking, a *true* polyalphabetic cipher has no cycles e.g. a stream
cipher using a TRNG for the keystream.

Modern block ciphers achieve a similar result using the so-called *counter
modes* of operation. These allow to transform any block cipher into a stream
cipher.

## Conventions

Each cipher is described by a tuple `(P, C, K, E, D)` with:
- `P`: plaintexts set
- `C`: ciphertexts set
- `K`: keys set (keyspace)
- `E`: encryption function
- `D`: decryption function

We assume to work with the alphabet `A = {a,..,z}`. Where more convenient, the
alphabet is interpreted as `Z₂₆` by mapping each letter to the corresponding
position within the English alphabet (`a → 0`, .., `z → 25`).

The set `A*` is the set of strings composed by elements of `A`.

For the ciphers that will follow:
- `P = C = A*`
- `K`, `E`, `D` are dependent on the specific cipher

## Substitution Cipher

The substitution is driven by a permutation table `π`.

    E_pi[p] = π(p) = c
    D_pi[c] = π⁻¹(c) = p

The keyspace consists of all the possible tables we can construct, or in other
words all the permutations of the alphabet symbols.

    |K| = |A|! = 26! ≥ 4·10²⁶

A key is one of the possible permutations.

In general, the substitution rule may not be describable without explicitly
providing the full permutation table and this may become quickly impractical as
the size of the alphabet grows.

For example if our alphabet consists of 64-bit elements, then the key size is
`64·2⁶⁴ = 2⁷⁰ ≈ 10²¹` bits, i.e. the table of all the substitutions that may be
applied during the encryption procedure (**the codebook**). For comparison, the
estimated total number of sand grains on all the beaches and deserts on Earth is
estimated to be around `10²⁰`.

Instead of allowing an arbitrary plaintext-ciphertext association we may derive
the mapping via some algorithm which uses a smaller information as the key.

Obviously, the key size reduction also comes with keyspace reduction, the
keyspace size will be the number of different associations that are possible via
such an algorithm.

Substitution ciphers driven by very simple algorithms are, for example, shift,
affine, atbash and Vigenere ciphers.

### Attack

**Frequency analysis**. Every language has a characteristic frequency for the
letters (e.g. in English the letter 'e' has an approximate frequency of 12%).

Simple substitution ciphers leaves the letters frequencies intact and thus allow
to attack the cipher via a trivial frequency analysis.

Potential workarounds for frequency analysis:
1. **Blocks substitution** ciphers: instead of replacing single letters we work
   on blocks of m letters. Thus flattening the frequencies of the blocks.
2. **Polyalphabetic** ciphers: use more than one monoalphabetic cipher by rotating
   their usage (e.g. Vigenere and Enigma).

As said before, a polyaphabetic cipher with a cycle is equivalent to a
monoalphabetic block cipher with a bigger alphabet. Working with blocks of size
`N` is just like working with a bigger alphabet where each element has size `N`.

For instance, if the block length is `3` there are `26³` elements in the
alphabet (equal to the block length) and if the cipher is a *pure substitution*
cipher then the keyspace size is `26³!`. However, the key length is `26³`.

Polyalphabetic ciphers where the substitution of each element within the block
is driven by a simple monoalphabetic cipher are a good compromise since the key
is very compact, and we still have a *big* enough keyspace.

For instance, with a polyalphabetic shift cipher, if the block length is `3` then
the keyspace size is `26³` and the key length is `3`.


## Shift Cipher

The key is defined as an integer `k ∈ Z₂₆`.

We shift each plaintext letter by `k` positions with respect to their position
in the alphabet.

    E_k[p] = (p + k) mod 26 = c
    D_k[p] = (p - k) mod 26 = p

The same shift quantity is applied to each word in the input string.

For example, shift every character in the plaintext by `k = 3` positions:

    a → d, b → e, ... , v → b, z → c

When `k = 3` the cipher is known as the *Caesar cipher*.

### Attack

The keyspace is trivially small (26), thus it can be easily brute forced without
resorting to a frequency analysis.


## Vigenere Cipher

A polyalphabetic cipher composed of several shift ciphers.

The keyspace is `Aᵐ`, where `m` is the key length.

The scheme can be easily visualized by writing the key and the plaintext one
above the other, the key is repeated as required till the end of the plaintext.

The encryption/decryption functions for the i-th element of the plaintext/
ciphertext:

    E_k[pᵢ] = [pᵢ + k_(i mod m)] mod |A| = cᵢ
    D_k[cᵢ] = [cᵢ - k_(i mod m)] mod |A| = pᵢ

### Attacks

The cipher is trivially vulnerable to a known plaintext attack:

    k_(i mod m) = (cᵢ - pᵢ) mod |A|

The cipher is also vulnerable to statistical analysis. In this case the
vulnerability stems from the key repetition. The shortest is the key the
more it is vulnerable.

Note that is `m` is equal to the plaintext length then this cipher is equivalent
to the *one-time pad*, a well known unconditionally secure cipher.

#### Kasiski Test (~1863).

When there are sequences that repeat in the plaintext, is possible that
this repetition is propagated to the ciphertext. This happens if they are at a
distance that is a multiple of the key length and thus end up being encrypted
using the same elements of the key (i.e. the same monoalphabetic cipher).

Finding a repetition in the ciphertext can thus suggest that the distance
between the repeated sequence is equal to a multiple of the key length.

Steps:
1. Compute the distances `d₁`, .., `dₙ` between all the repetitions.
2. If the key length `m` divides `d₁`, .., `dₙ` then it divides `gcd(d₁,..,dₙ)`.

(Hint: consider only repetitions of 3+ letters.)

Once that the key length has been guessed a frequency analysis attack can be
carried over the subsets encrypted with the same `kᵢ` (the same attack used for
the trivial shift cipher).

Each of these subsets is a simple shift cipher.

    C₁ = { cᵢ such that cᵢ = pᵢ + k₁ }
    ...
    Cₘ = { cᵢ such that cᵢ = pᵢ + kₘ }

May happen to find some bogus `dᵢ` values, in this case retry or use the
Friedman Test.

#### Friedman Test (~1920)

##### Index of Coincidence

Given a vector of characters `x = (x₁,..,xₙ)` in `A*` then `Ic(x)` is the
probability to extract, without reinsertion, two elements from `x` with the
same value.

Example:

    Ic((a, a, a)) = p(a)·p(a|a) = 1
    Ic((a, b, a)) = p(a)·p(a|a) + p(b)·p(b|b) = 2/3·1/2 + 1/3·0 = 2/6 = 1/3

Given the vector `x`, we define the frequency `f(i)` to be the number of
occurrences of the i-th character of the alphabet in `x` (e.g. `A = {a, b}`,
`x = (a, b, a)` → `f(0) = 2`, `f(1) = 1`).

We also define the probability to extract the i-th character of the alphabet
from `x` as `p(i) = f(i)/N`, with `N = length(x)`.

    p(0)  = f(0)/N       p(0|0)   ≈ (f(0)-1)/(N-1)
    ...                   ...
    p(25) = f(25)/N      p(25|25) ≈ (f(25)-1)/(N-1)

When both `f(i)` and `N` are big, then `(f(i)-1)/(N-1) ≈ f(i)/N`, thus:

    Ic(x) ≈ p(0)² + ... + p(25)² = ∑ p(i)²

The `Ic` measures some **redundancy** value for a sequence of characters.

Three interesting cases for `x`.

- `x` is a (long enough) English text:
  - `p(i)` follows the well known probability values of English letters.
  - `Ic(x) ≈ 0.065`

- `x` is obtained from a monoalphabetic substitution cipher applied to an English text:
  - Individual probabilities are permuted, but the overall result is unchanged.
  - `Ic(x) ≈ 0.065`, the same as for the plaintext.

- `x` is a uniformly distributed random sequence:
  - `p(i) = 1/26`, for every `i`
  - `Ic(x) = 26·[(1/26)²] = 1/26 ≈ 0.038`

In short:
- high value → no randomness  → `Ic(x) ≈ 0.065`
- low value  → max randomness → `Ic(x) ≈ 0.038`

##### Key Length disclosure

Given the ciphertext:

    y = (y₁, ..., yₙ)

We test a key length candidate `m` by disposing the ciphertext in a matrix of
`m` rows (the first column contains the first m characters of the ciphertext).

    ⌈ y₁   yₘ₊₁ .. ⌉   ⌈ R₁ ⌉
    | ..   ..   .. |   | .. |
    ⌊ yₘ   y₂ₘ  .. ⌋   ⌊ Rₘ ⌋

Compute the `Ic` for each row `Rᵢ`.

- If the key length `m` is correct then `Rᵢ` is a sequence whose elements are
  all encrypted with the same key value, thus `Ic(Rᵢ)` should be high (close
  to `0.065`).
- If the key length is incorrect then `Ic(Rᵢ)` will be low (close to `0.038`).

(Note: we could have used the entropy of `x`)

##### Key disclosure

Once that the key length `m` is disclosed, we proceed determining the single
letters of the key `k = (k₁,..,kₘ)`.

    [ R1 ] has been encrypted with k₁
    N₁ = length(R₁)
    p(i) = prob for the i-th char when using English language

How encryption is done using `k₁` on the single plaintext characters:

  | Plaintext  | English prob. P(i) | Ciphertext   |  Cipher frequencies F(i+k₁) |
  |------------|--------------------|--------------|-----------------------------|
  | 0          |    p(0)            |   0+k₁       |     f(0+k₁)/N₁              |
  | ...        |    ...             |   ...        |     ...                     |
  | 25         |    p(25)           |   25+k₁      |     f(25+k₁)/N₁             |

As the value of `k₁` we need to choose the value that better approximates the
English typical frequencies.

In other words `k₁` is equal to `j ∈ Z₂₆` if the distance between `F(j)` and `P`
vectors `||F(j) - P||` is minimal. An **equivalent** technique often reported
in literature is to get `j` that maximize the scalar product between `F(j)`
and `P`.

The procedure is repeated for every row `Rᵢ` to gain different parts of the key.

Note that this is exactly the same attack used for the shift encryption (only
more structured) where we'd have a single row `R` containing the full ciphertext.

As the opposite extreme case, if the key length is equal to the length of
the plain text this cipher is equivalent to the *one-time pad*. In this case
each row `Rᵢ` has just one element, thus we have no material to analyze the
frequencies.


## Affine Cipher

A substitution cipher where substitution algorithm requires multiplication and
addition.

The key is defined as a couple of integers `(a, b)` in `Z₂₆`.

    E_(a,b)[p] = a·p + b mod 26 = c
    D_(a,b)[c] = (c - b)·a⁻¹ mod 26 = p

Note that `a` is required to be invertible modulo `|A| = 26`, thus is required
that `gcd(a, 26) = 1`. Because `26 = 13·2` then `a` can't be even or 13.

### Attacks

The affine cipher defined over `A = Z₂₆` has only `26·12 = 312` possible keys.
A brute force attack is trivial over such a small set.

Frequency analysis can also be used like any other substitution cipher.

The cipher is vulnerable to a known plaintext attack when two couples `(p₁,c₁)`
and `(p₂,c₂)` are known:

    c₁ = a·p₁ + b
    c₂ = a·p₂ + b
    c₁ - c₂ = a·(p₁ - p₂)
    a = (c₁-c₂)/(p₁-p₂)
    b = c₁ - a·p₁

The only requirement is that `(p₁-p₂)` is invertible modulo `|A|`.


## Transposition Cipher

Scrambles the position of the plaintext characters without changing the
characters themselves.

Given a plaintext with length `N` and assuming a relative frequency of the i-th
alphabet character as `fᵢ` then the number of possible ciphertexts are `N!/∏(fᵢ!)`
for each `i`.

For instance, the plaintext "santarealfun" can be encrypted in `12!/(3!·2!) =
39,916,800` different ways, one of these is "satanfuneral".

By dividing and processing the plaintext in blocks of length `m`, encryption can
be formalized by multiplying each block by an `m⨯m` transposition matrix.

This is a special instance of the Hill cipher, which is described next.

### Attacks

Since transposition does not affect the frequency of individual symbols, simple
transposition can be easily detected by doing a frequency count. If the
ciphertext symbols exhibit a frequency distribution very similar to the
plaintext's language then it is most likely a transposition.

There are several methods for attacking the cipher. These include:
- Known-plaintext attack: see Hill cipher
- Using known or guessed parts of the plaintext to assist in reverse-engineering.

To decipher the encrypted message an attacker could try to guess possible words
with the characters found in the ciphertext.

In general, transposition methods are vulnerable to **anagramming**, sliding pieces
of ciphertext around, then looking for sections that look like anagrams of
words, and solving the anagrams. Once such anagrams have been found, they reveal
information about the transposition pattern, and can consequently be extended.


## Hill Cipher

A block cipher more explicitly derived from linear algebra.

With a block size `m`, if we interpret the cipher as a monoalphabetic cipher,
the alphabet can be also viewed as `Z₂₆ᵐ`.

Each plaintext and ciphertext block is represented as a `m×1` column vector:

        ⌈ p₁ ⌉       ⌈ c₁ ⌉
    p = | .. |   c = | .. |
        ⌊ pₘ ⌋       ⌊ cₘ ⌋

The block transformation is driven by the key `K`, a `m×m` square matrix:

        ⌈ k₁₁ ... k₁ₘ ⌉
    K = |     ...     |
        ⌊ kₘ₁ ... kₘₘ ⌋

Encryption and decryption functions are defined as:

    E_K[p] = K·p mod 26 = c
    D_K[p] = K⁻¹·c mod 26 = p

With modular operation applied to the result of row by column product.

The transformation is a matrix-vector product:

    c₁ = k₁₁·p₁ + ... + k₁ₘ·pₘ (mod 26)
      ...
    cₘ = kₘ₁·p₁ + ... + kₘₘ·pₘ (mod 26)

**Diffusion principle**: a single ciphertext character depends on all the
plaintext characters within the same block.

The principle is quite effective against frequency analysis attacks by reducing
the redundancy of the single letters.

Note that decryption requires the key matrix to be **invertible** modulo `|A|`.

When operating over real numbers a matrix is invertible if the columns are
linearly independent (i.e. we cannot express one column as a linear combination
of the others). In other, equivalent, terms a matrix `K` is invertible if and
only if `det(K) ≠ 0`.

In modular arithmetic the inverse of a matrix exists if and only if the
determinant is coprime with the alphabet size or in other words if and only if
`det(K)` is invertible modulo `|A|`.

    K is invertible modulo |A| iff gcd(det(K), |A|) = 1

The determinant is typically computed via the **Cramer's** formula.

The inverse matrix `B = K⁻¹` elements are computed as:

    bᵢⱼ = (-1)ⁱ⁺ʲ · det(K*ⱼᵢ) · det(K)⁻¹ mod |A|
        
Where:
- `K*ⱼᵢ`: is the matrix `K` *minor* obtained by removing from `K` the row `j`
  and column `i`.
- `det(K)⁻¹` is the inverse of the determinant modulo `|A|`. The inverse exists
  when `gcd(det K, |A|) = 1`.

### Attack

Because of the diffusion principle, the cipher is fairly resistant to ciphertext
only attacks, but easily fails with a known-plaintext attack.

Assume that the attacker knows `m` and `m` couples of plaintext/ciphertext
blocks `(pᵢ,cᵢ)` of length `m` encrypted using the same key `K`:

    cᵢ = K·pᵢ mod |A|

We merge the `cᵢ` and `pᵢ` column vectors to obtain two `m×m` matrix

    [c₁ | .. | cₘ ] = K·[p₁ | .. | pₘ ]
    C = K·P

Next we can use one of the well-known matrix resolution methods (e.g. Gaussian
elimination method, LRU, ...) to compute `P⁻¹`.

If `P` is not invertible modulo `|A|`, then we should try with a different set
of `(pᵢ,cᵢ)`. Follows that the first thing the attacker should do is to check if
`P` is invertible by computing its determinant.


## Wrapping Up

## Linear Transformation

In practice, excluded the generic non-linear substitution cipher, **all**
the classical ciphers viewed so far can be expressed using exactly the same
**linear transformation**:
    
    E[p] = A·p + b = c
    D[c] = A⁻¹·(c - b) = p

With `A` a matrix providing diffusion and `b` a vector providing polyalphabetic
shift encryption.

- Shift cipher: `A` is a `1⨯1` identity matrix and `b` a vector of length 1.
- Vigenere cipher: `A` is a `m⨯m` identity matrix and `b` a `m⨯1` vector.
- Affine cipher: `A` is a `1⨯1` invertible matrix and `b` a vector of length 1.
- Transposition cipher: `A` is a `m⨯m` transposition matrix and `b` is a zero vector.
- Hill cipher: `A` is a `m⨯m` invertible matrix and `b` is a `m⨯1` zero vector.

We can obviously extend the Hill cipher by using an arbitrary `m⨯1` vector `b`.

### Lesson Learned

In general, once the key has been fixed, we obtain a function from plaintext to
ciphertext. This function should **NOT** be a linear transformation.

If the cipher is based on a linear function then we can always apply some simple
technique to break it (or weaken it if it has some linear component).

Modern standards require that a cipher should resist to known-plaintext attacks.

If we combine an operation providing **diffusion** (as Hill) with some elements
of **confusion** (as a non-linear substitution) we can obtain a strong cipher.

This naturally brings to the more modern Substitution-Permutation-Network (SPN)
design introduced by Shannon and later implemented by Feistel.

### More on Polyalphabetic Ciphers

Consider each block of a polyalphabetic cipher as a single word of a
substitution cipher where the substitution is driven by some algorithm.

Doing such substitution algorithmically we are not using the entire
possibilities for the mapping between the plaintext and ciphertext
(`|K| < |A|!`).

For example, with Vigenere cipher with blocks of 64 bits (key length = 64) we
have a keyspace of `2⁶⁴` and not `2⁶⁴!` as for a generic substitution cipher
derived from a permutation table.

When using a particular key then such a key is reused over the whole plaintext
set. With a *true* polyalphabetic cipher should not be possible to have a
mapping where we apply to two different blocks the same key.


## References

- [cry](https://github.com/davxy/cry/blob/master/src/crypt/affine.c) affine cipher
- [Feistel ciphers](/posts/feistel-ciphers)
