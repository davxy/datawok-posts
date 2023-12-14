+++
title = "Classical Ciphers"
date = "2017-05-26"
modified = "2023-11-18"
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
alphabet then a polyalphabetic cipher is still a monoalphabetic cipher.

Strictly speaking, a real polyalphabetic cipher has no cycles e.g. a stream
cipher using a TRNG for the keystream.

## Conventions

Each cipher is described by a tuple `(P, C, K, E, D)` with:
- `P` all the possible plaintexts
- `C` all the possible ciphertexts
- `K` all the possible keys (aka keyspace)
- `E` encryption function
- `D` decryption function

We assume to work with the alphabet `A = {a,..,z}`. Where more convenient the
alphabet is interpreted as `Z_26` by assigning each letter to the corresponding
position within the English alphabet (e.g. `a→0`, .., `z→25`).

The set `A*` is the set of strings composed by elements of `A`.

In the following algorithms:
- `P = C = A*`
- `K`, `E`, `D` are dependent on the specific cipher

## Substitution Cipher

The substitution is not driven by any particular algorithm but by a permutation
table `pi`.

    E_pi[p] = pi(p) = c
    D_pi[c] = pi^-1(c) = p

The keyspace consists of all the possible tables we can construct, or in other
words all the permutations of the alphabet symbols.

    |K| = |A|! = 26! ≥ 4·10^26

The key is one of all the possible permutations.

In a general substitution cipher the substitution rule may not be describable
algorithmically, thus to specify the key we have to explicitly enumerate all
the substitutions. This is impractical even with small alphabets.

For example if our alphabet consists of bit-strings of length 64 bits, then the
key size is 64⋅2^64 bits, i.e. the table of all the substitutions that may be
applied during the encryption procedure (**the codebook**).

Instead of allowing arbitrary plaintext-ciphertext association we may derive the
mapping via some kind of algorithm.

The key size is thus reduced to some kind of secret input that is required by
the algorithm definition, that is short enough to be practical for sharing.

Unfortunately key size reduction also comes with keyspace reduction, the size
will be bound to the number of associations that are possible via such an
algorithm.

Substitution ciphers driven by very simple algorithms are for example shift-
cipher, affine, atbash and Vigenere.

### Attack

**Frequency analysis**. Every language has a characteristic frequency for the
letters (e.g. in English the letter 'e' has an approximate frequency of 12%).

Simple substitution ciphers leaves the letters frequencies intact and thus allow
to attack the cipher via a trivial frequency analysis.

As an extension we can try to conceal the frequencies by considering group of
letters of fixed length (blocks) such as **digrams** (couples of two letters).
Some blocks have higher frequency (e.g. 'th' in English) anyway.

Potential solutions for frequency analysis:
1. **Blocks substitution** ciphers: instead of replacing single letters we work
   on blocks of m letters. Thus flattening the frequencies of the blocks.
2. **Polyalphabetic** ciphers: use more than one monoalphabetic cipher by rotating
   their usage (e.g. Vigenere and Enigma).

As said before, note that a polyaphabetic cipher with a cycle is equivalent to
a monoalphabetic block cipher. Working with blocks is just like working with a
larger alphabet.

For example if the block length is `3` there are `26^3` elements in the alphabet
(equal to the key length) and if the cipher is a *pure substitution* cipher then
the keyspace size of `(26^3)!` elements.

Polyalphabetic ciphers are thus preferred since the key is very compact, and we
still have a fairly big keyspace.

For example, with a polyalphabetic shift cipher, if the block length is `3` then
we have `26^3` possible keys and the key length is `3`.


## Shift Cipher

The key is defined as an integer `k ∈ Z_26`.

We shift each plaintext letter by `k` positions with respect to their position
in the alphabet.

    E_k[p] = (p + k) mod 26 = c
    D_k[p] = (p - k) mod 26 = p

The same shift quantity is applied for each word in the input string.

For example, shift every character in the plaintext by `k = 3` positions:

    a → d, b → e, ... , v → b, z → c

When `k = 3` the cipher is also known as the *Caesar cipher*.

### Attack

The keyspace is trivially small (26), thus can be easily brute forced.


## Vigenere Cipher

A polyalphabetic cipher composed of several shift ciphers.

The keyspace is `A^m`, where `m` is the key length.

The scheme can be easily visualized by writing the key and the plaintext one
above the other, the key is repeated as required till the end of the plaintext.

The encryption/decryption functions for the i-th element of the plaintext/
ciphertext:

    E_k[p_i] = [p_i + k_(i mod m)] mod |A| = c_i
    D_k[c_i] = [c_i - k_(i mod m)] mod |A| = p_i

In practice the shift cipher can be reduced to a Vigenere cipher with m=1.

### Attack

The cipher is trivially vulnerable to a known plaintext attack:

    k_(i mod m) = (c_i - p_i) mod |A|

The cipher is also vulnerable to statistical analysis. In this case the
vulnerability stems from the key repetition. The shortest is the key the
more it is vulnerable.

Note that is `m` is equal to the plaintext length then this cipher is equivalent
to the *one-time pad*, a well known unconditionally secure cipher.

### Kasiski's Test (~1863).

When there are sequences that repeat in the plaintext, is possible that
this repetition is propagated to the ciphertext. This happens if they are at a
distance that is a multiple of the key length and thus end up being encrypted
using the same elements of the key (i.e. the same monoalphabetic cipher).

Finding a repetition in the ciphertext can thus suggest that the distance
between the repeated sequence is equal to a multiple of the key length.

Hint: consider only repetitions of 3+ letters.

Steps:
1. Compute the distances `d1`, .., `dz` between all the repetitions.
2. The key length `m` may divide `d1`, .., `dz` and divides `gcd(d1,..,dz)`.

Once that the key length has been guessed a frequency analysis attack can be
carried on the subsets encrypted with the same `k_i` (the same attack used for
the trivial shift cipher).

Each of these subsets is a simple shift cipher.

    C1 = { ci such that ci = pi + k1 }
    ...
    Cm = { ci such that ci = pi + km }

May happen to find some bogus `di` values, in this case proceed retry or use the
Friedman Test.

### Friedman Test (~1920)

#### Index of Coincidence

Given a vector of characters `x = (x1,..,xn)` in `A*` then `Ic(x)` is the
probability to extract two elements from `x`, without reinsertion, with the
same value.

Example:

    Ic(a, a, a) = P(a)·P(a|a) = 1
    Ic(a, b, a) = P(a)·P(a|a) + P(b)·P(b|b) = 2/3·1/2 + 1/3·0 = 2/6 = 1/3

Given the vector `x`, we define the frequency `f(i)` to be the number of
occurrences of the i-th character of the alphabet in `x` (e.g. `A = {a, b}`,
`x = (a, b, a)` → `f(0) = 2`, `f(1) = 1`).

We also define the probability to extract the i-th character of the alphabet
from `x` as `P(i) = f(i)/N`, with `N = len(x)`.

    Pr(0)  = f(0)/N       Pr(0|0)   ≈ (f(0)-1)/(N-1)
    ...                   ...
    Pr(25) = f(25)/N      Pr(25|25) ≈ (f(25)-1)/(N-1)

When both `f(i)` and `N` are big, then `(f(i)-1)/(N-1) ≈ f(i)/N`, thus:

    Ic(x) ≈ Pr(0)^2 + ... + Pr(25)^2 = ∑ Pr(i)^2

The `Ic` measures some **redundancy** value for a sequence of characters.

Three interesting cases for `x`.

- `x` is a (long enough) English text.
    - `Pr(i)` follows the well known probability values of English letters
    - `Ic(x) ≈ 0.065`

- `x` is obtained from a monoalphabetic substitution cipher
    - Individual probabilities are permuted, but the overall result is unchanged.
    - `Ic(x)` is the same as for the cleartext (`≈ 0.065`).

- `x` is a uniformly distributed random sequence
    - `Pr(i) = 1/26`, for every `i`
    - `Ic(x) = 26·[(1/26)^2] = 1/26 ≈ 0.038`

In short:
- high value → no randomness  → `Ic(x) ≈ 0.065`
- low value  → max randomness → `Ic(x) ≈ 0.038`

#### Key Length disclosure

Given the ciphertext:

    y = (y1, ..., yn)

We gain some key length candidates (e.g. via the Kasiski test or exhaustive
search).

Dispose the ciphertext in a matrix of `m` rows, with `m` a candidate.

The ciphertext is then divided in the columns of the matrix, i.e. the first
column contains the first m characters of the ciphertext:

    ⌈ y1   y_m+1 ... ⌉   ⌈ R1 ⌉
    | y2   y_m+2 ... | = | R2 |
    | ...  ...   ... |   | .. |
    ⌊ ym   y_2m  ... ⌋   ⌊ Rm ⌋

Compute the `Ic` for each row `Ri`.

- If the key length `m` is correct then `Ri` is a sequence which elements are
  all encrypted with the same key value, thus `Ic(Ri)` should be high (close
  to `0.065`).
- If the key length is incorrect then `Ic(Ri)` will be low (close to `0.038`).

TODO: can't we use the entropy of `x` in place of the index of coincidence?

#### Key disclosure

Once that the key length `m` is disclosed, we proceed determining the single
letters of the key `k = (k1,..,km)`.

    [ R1 ] → encrypted with k1
    N1 = len(R1)
    p(i) = prob for the i-th char when using English language

How encryption is done using `k1` on the single plaintext characters:

  | Plaintext  | English prob. P(i) | Ciphertext   |  Cipher frequencies F(k1)   |
  |------------|--------------------|--------------|-----------------------------|
  | 0          |    p(0)            |   k1+0       |     f(k1+0)/N1              |
  | 1          |    p(1)            |   k1+1       |     f(k1+1)/N1              |
  | ...        |    ...             |   ...        |     ...                     |
  | 25         |    p(25)           |   k1+25      |     f(k1+25)/N1             |

As the value of `k1` we need to choose the value (one out of the 26 alphabet
values) that better approximates the English typical frequencies.

In other words `k1` is equal to `j ∈ Z_26` if the distance between `F(j)` and
`P` vectors `||F(j) - P||` is minimal.

An **equivalent** technique often reported in literature is to get `j` that
maximize the scalar product between `F(j)` and `P`.

The procedure is repeated for every row `Ri` to gain different parts of the key.

Note that this is exactly the same attack used for the shift encryption (only
more structured), with shift encryption `m = 1`, i.e. we have a single row R
containing the full ciphertext.

As the opposite case, also note that if the key length is equal to the length
of the plain text this cipher is equivalent to the *one-time pad*. In this case
each row `Ri` has just one element, thus we have no material to analyze the
frequencies.


## Affine Cipher

A substitution cipher where substitution algorithm requires multiplication and
addition.

The key is defined as a couple of integers `(a, b)` in `Z_26`.

    E_(a,b)[p] = a·p + b mod 26 = c
    D_(a,b)[c] = (c - b)·a^-1 mod 26 = p

Note that `a` is required to be invertible modulo `|A| = 26`, thus is required
that `gcd(a, 26) = 1`. Because `26 = 13·2` then `a` can't be even or 13.

### Attacks

The affine cipher defined over `A = Z_26` has only `26·12 = 312` possible keys.
A brute force attack is trivial over such a small set.

Frequency analysis can also be used like any other substitution cipher.

The cipher is vulnerable to a known plaintext attack when two couples `(p1,c1)`
and `(p2,c2)` are known:

    c1 = a·p1 + b
    c2 = a·p2 + b
    → c1 - c2 = a·(p1 - p2)
    → a = (c1-c2)/(p1-p2)
    → b = c1 - a·p1

The only requirement is that `(p1-p2)` is invertible modulo `|A|`.


## Transposition Cipher

Scrambles the position of the plaintext characters without changing the
characters themselves.

Given a plaintext of length `N` and assuming a relative frequency of the i-th
alphabet character as `fi` then the number of possible ciphertexts are `N!/∏fi!`
for each `i`.

For example, the plaintext "santarealfun" can be encrypted in `12!/(3!·2!) =
39,916,800` different ways, One of these is "satanfuneral".

By dividing and processing the plaintext in blocks of length `m`, encryption can
be formalized by multiplying each block by a transposition matrix

Both encryption and decryption are similar to the Hill cipher, described next.

### Attacks

Since transposition does not affect the frequency of individual symbols, simple
transposition can be easily detected by doing a frequency count. If the
ciphertext exhibits a frequency distribution very similar to plaintext, it is
most likely a transposition.

There are several methods for attacking the cipher. These include:
- Known-plaintext attack: see Hill cipher
- Using known or guessed parts of the plaintext to assist in reverse-engineering.

To decipher the encrypted message an attacker could try to guess possible words
with the characters found in the ciphertext.

In general, transposition methods are vulnerable to anagramming, sliding pieces
of ciphertext around, then looking for sections that look like anagrams of
words, and solving the anagrams. Once such anagrams have been found, they reveal
information about the transposition pattern, and can consequently be extended.


## Hill Cipher

A block cipher more explicitly derived from linear algebra.

With a block size `m`, if we interpret the cipher as a monoalphabetic cipher,
the alphabet can be also viewed as `Z_26^m`.

Each plaintext and ciphertext block is represented as a `m×1` column vector:

    p = [ p1 ... pm ]'
    c = [ c1 ... cm ]'

The block transformation is driven by a key `K`, a `m×m` square matrix:

        ⌈ k11 k12 ... k1m ⌉
    K = | k21 k22 ... k2m |
        |       ...       |
        ⌊ km1 km2 ... kmm ⌋

Encryption and decryption functions are defined as:

    E_K[p] = K·p mod 26 = c
    D_K[p] = K^-1·c mod 26 = p

With modular operation applied to the result of row by column product.

The transformation is a matrix-vector product:

    c1 = k11·p1 + k12·p2 + ... + k1m·pm (mod 26)
    ...
    cm = km1·p1 + km1·p2 + ... + kmm·pm (mod 26)

**Diffusion principle**: a single ciphertext character depends on all the
plaintext characters within the same block.

Diffusion principle is quite effective against frequency analysis attacks by
reducing the redundancy of the single letters.

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

The inverse matrix `B = K^-1` elements are computed as:

    b_ij = (-1)^(i+j) · det(K*_ji) · det(K)^-1 mod |A|
        
Where:
- `K*_ji`: is the matrix `K` *minor* obtained by removing from `K` the row `j`
  and column `i`.
- `det(K)^-1` is the inverse of the determinant modulo `|A|`. The inverse exists
  when `gcd(det K, |A|) = 1`.

### Attack

Because of the diffusion principle, the cipher is fairly resistant to ciphertext
only attacks, but easily fails with a known-plaintext attack.

Assume that the attacker knows `m` couples of plaintext/ciphertext blocks of
length `m` encrypted using the same key `K` (and thus knows `m` as well).

    (pi,ci) → ci = K·pi mod |A|

We merge the `ci` and `pi` column vectors to obtain two `m×m` matrix

    [c1 | c2 | ... | cm ] = K·[p1 | p2 | ... | pm ]
    C = K·P

Next we can use one of the well-known matrix resolution methods (e.g. Gaussian
elimination method, LRU, ...) to compute `P^-1`.

If `P` is not invertible modulo `|A|`, then we should try with a different set
of `(pi,ci)`.

Follows that the first thing the attacker should do is to check if `P` is
invertible by computing the determinant.

## Wrapping Up

## Reduction to a linear transformation

In practice, excluded the pure non-algorithmic substitution cipher, **all**
the classical ciphers viewed so far can be expressed using exactly the same
**linear transformation**:
    
    E[p] = A·p + b = c
    D[c] = A^-1·(c - b) = p

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
ciphertext. This function should **NOT** be a linear function.

If the cipher is based on a linear function then we can always apply some simple
technique to break it (or weaken it if it has some a linear component).

For example, *Lucifer* (an ancestor of DES) was having a linear component.

Modern standards require a cipher should resist to known-plaintext attacks.

If we combine an operation providing **diffusion** (as Hill) with some elements
of **confusion** (as a non-linear substitution) we can obtain a strong cipher.

This naturally brings us to the more modern Substitution-Permutation-Network
(SPN) design for ciphers (e.g. **Feistel**).

### More on polyalphabetic ciphers

We consider each block of a polyalphabetic cipher as a single word of a
substitution cipher where the substitution is driven by some sort of algorithm.

Doing such substitution algorithmically we are not using the entire
possibilities for the mapping between the plaintext and ciphertext
(`|K| < |A|!`).

For example, with Vigenere cipher with blocks of 64 bits (keylen = 64) we have a
keyspace of `2^64` and not `(2^64)!` as for a substitution cipher derived from a
permutation table

When using a particular key then such a key is reused over the whole
plaintext set. With a polyalphabetic cipher is not possible to have a mapping
where we apply to two different blocks two different keys. Well, to be fair is
possible to extend the block cipher to use different keys a la Vigenere cipher
but we've just moved the problem forward since this is just equivalent to an
algorithmic substitution cipher with a bigger alphabet.


## References

- [cry](https://github.com/davxy/cry/blob/master/src/crypt/affine.c) affine cipher
- [Feistel ciphers](/posts/feistel-ciphers)
