+++
title = "Classical Ciphers"
date = "2017-05-26"
modified = "2024-01-26"
tags = [ "cryptography", "history" ]
toc = true
+++

Most modern ciphers use some kind of **substitution** operation.

A block of bits is substituted with another block of bits according to a given
table or algorithm.

**Monoalphabetic** cipher: the same element in the plaintext alphabet is
always encrypted to the same element in the ciphertext alphabet.

**Polyalphabetic** cipher: the same element in the plaintext alphabet may
be encrypted to different elements in the ciphertext alphabet.

Polyalphabetic cipher algorithms typically depend on a key that is cyclically
used to encrypt the single letters. Thus they are equivalent to a set of
monoalphabetic ciphers that are alternately used.

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

Modern block ciphers achieve a similar result using the *stream modes* of
operation (e.g. CTR, OFB, CFB). These make it possible to transform any block
cipher into a stream cipher. The keystream is not truly cycle free: in CTR mode
it repeats after at most $2^n$ blocks, with $n$ the block size. However, this
period is much longer than any practical message.

## Conventions

Each cipher is described by a tuple $(P, C, K, E, D)$ with:
- $P$: plaintexts set
- $C$: ciphertexts set
- $K$: keys set (keyspace)
- $E$: encryption function
- $D$: decryption function

We assume to work with the alphabet $A = \{a, \ldots, z\}$. Where more convenient, the
alphabet is interpreted as $\mathbb{Z}_{26}$ by mapping each letter to the corresponding
position within the English alphabet ($a \to 0$, ..., $z \to 25$).

The set $A^*$ is the set of strings composed by elements of $A$.

For the ciphers that will follow:
- $P = C = A^*$
- $K$, $E$, $D$ are dependent on the specific cipher

## Substitution Cipher

The substitution is driven by a permutation table $\pi$.

$$
\begin{aligned}
E_\pi[p] &= \pi(p) = c \\
D_\pi[c] &= \pi^{-1}(c) = p
\end{aligned}
$$

The keyspace consists of all the possible tables we can construct, or in other
words all the permutations of the alphabet symbols.

$$|K| = |A|! = 26! \ge 4 \cdot 10^{26}$$

A key is one of the possible permutations.

In general, the substitution rule may not be describable without explicitly
providing the full permutation table and this may become quickly impractical as
the size of the alphabet grows.

For example if our alphabet consists of 64-bit elements, then the key size is
$64 \cdot 2^{64} = 2^{70} \approx 10^{21}$ bits, i.e. the table of all the substitutions that may be
applied during the encryption procedure (**the codebook**). For comparison, the
total number of sand grains on all the beaches and deserts on Earth is
estimated to be between $10^{18}$ and $10^{20}$.

Instead of allowing an arbitrary plaintext-ciphertext association we may derive
the mapping via some algorithm which uses a smaller information as the key.

Obviously, the key size reduction also comes with keyspace reduction, the
keyspace size will be the number of different associations that are possible via
such an algorithm.

Substitution ciphers driven by very simple algorithms are, for example, shift,
affine, Atbash and Vigenère ciphers.

### Attack

**Frequency analysis**. Every language has a characteristic frequency for the
letters (e.g. in English the letter 'e' has an approximate frequency of 12%).

Simple substitution ciphers leave the letters frequencies intact and thus allow
to attack the cipher via a trivial frequency analysis.

Potential workarounds for frequency analysis:
1. **Blocks substitution** ciphers: instead of replacing single letters we work
   on blocks of $m$ letters. Thus flattening the frequencies of the blocks.
2. **Polyalphabetic** ciphers: use more than one monoalphabetic cipher by rotating
   their usage (e.g. Vigenère and Enigma).

The two workarounds are the same thing seen from two sides (see the
introduction): working with blocks of size $N$ is just like working with a
bigger alphabet where each element has size $N$.


## Shift Cipher

The key is defined as an integer $k \in \mathbb{Z}_{26}$.

We shift each plaintext letter by $k$ positions with respect to their position
in the alphabet.

$$
\begin{aligned}
E_k[p] &= (p + k) \bmod 26 = c \\
D_k[c] &= (c - k) \bmod 26 = p
\end{aligned}
$$

The same shift quantity is applied to each letter in the input string.

For example, shift every character in the plaintext by $k = 3$ positions:

$$a \to d, \quad b \to e, \quad \ldots, \quad v \to y, \quad \ldots, \quad y \to b, \quad z \to c$$

When $k = 3$ the cipher is known as the *Caesar cipher*.

### Attack

The keyspace is trivially small (26), thus it can be easily brute forced without
resorting to a frequency analysis.

Frequency analysis also works, and the attacker does not need to read 26
candidate plaintexts. The most frequent ciphertext letter $c$ is probably the
encryption of 'e', thus $k = (c - 4) \bmod 26$. A more robust method compares the whole
ciphertext frequency vector with the English one (see the key disclosure step
of the Vigenère attack).


## Vigenère Cipher

A polyalphabetic cipher composed of several shift ciphers.

The keyspace is $A^m$, where $m$ is the key length.

The scheme can be easily visualized by writing the key and the plaintext one
above the other, the key is repeated as required till the end of the plaintext.

The encryption/decryption functions for the i-th element of the plaintext/
ciphertext:

$$
\begin{aligned}
E_k[p_i] &= [p_i + k_{i \bmod m}] \bmod |A| = c_i \\
D_k[c_i] &= [c_i - k_{i \bmod m}] \bmod |A| = p_i
\end{aligned}
$$

### Attacks

The cipher is trivially vulnerable to a known plaintext attack:

$$k_{i \bmod m} = (c_i - p_i) \bmod |A|$$

The cipher is also vulnerable to statistical analysis. In this case the
vulnerability stems from the key repetition. The shorter the key, the more
vulnerable it is.

Note that if $m$ is equal to the plaintext length, and the key is uniformly
random and used only once, then this cipher is equivalent to the *one-time pad*,
a well known unconditionally secure cipher.

#### Kasiski Test (~1863)

When there are sequences that repeat in the plaintext, it is possible that
this repetition is propagated to the ciphertext. This happens if they are at a
distance that is a multiple of the key length and thus end up being encrypted
using the same elements of the key (i.e. the same monoalphabetic cipher).

Finding a repetition in the ciphertext can thus suggest that the distance
between the repeated sequences is equal to a multiple of the key length.

Steps:
1. Compute the distances $d_1, \ldots, d_n$ between all the repetitions.
2. If the key length $m$ divides $d_1, \ldots, d_n$ then it divides $\gcd(d_1, \ldots, d_n)$.

(Hint: consider only repetitions of 3+ letters.)

Once that the key length has been guessed a frequency analysis attack can be
carried out over the subsequences encrypted with the same $k_i$ (the same attack
used for the trivial shift cipher).

Each of these subsequences is a simple shift cipher. The subsequence $C_j$
contains the ciphertext letters at the positions encrypted with $k_j$.

$$
\begin{aligned}
C_0 &= (c_0, c_m, c_{2m}, \ldots) \\
&\;\;\vdots \\
C_{m-1} &= (c_{m-1}, c_{2m-1}, c_{3m-1}, \ldots)
\end{aligned}
$$

You may find some bogus $d_i$ values, in this case retry or use the
Friedman Test.

#### Friedman Test (~1920)

##### Index of Coincidence

Given a vector of characters $x = (x_0, \ldots, x_{n-1})$ in $A^*$ then $\operatorname{Ic}(x)$ is the
probability to extract, without reinsertion, two elements from $x$ with the
same value.

Example:

$$
\begin{aligned}
\operatorname{Ic}((a, a, a)) &= p(a) \cdot p(a \mid a) = 1 \\
\operatorname{Ic}((a, b, a)) &= p(a) \cdot p(a \mid a) + p(b) \cdot p(b \mid b)
  = \tfrac{2}{3} \cdot \tfrac{1}{2} + \tfrac{1}{3} \cdot 0 = \tfrac{2}{6} = \tfrac{1}{3}
\end{aligned}
$$

Given the vector $x$, we define the frequency $f(i)$ to be the number of
occurrences of the i-th character of the alphabet in $x$ (e.g. $A = \{a, b\}$,
$x = (a, b, a)$ $\Rightarrow$ $f(0) = 2$, $f(1) = 1$).

We also define the probability to extract the i-th character of the alphabet
from $x$ as $p(i) = f(i)/N$, with $N = \operatorname{length}(x)$.

$$
\begin{aligned}
p(0) &= \frac{f(0)}{N} & p(0 \mid 0) &= \frac{f(0) - 1}{N - 1} \\
&\;\;\vdots & &\;\;\vdots \\
p(25) &= \frac{f(25)}{N} & p(25 \mid 25) &= \frac{f(25) - 1}{N - 1}
\end{aligned}
$$

When both $f(i)$ and $N$ are big, then $(f(i) - 1)/(N - 1) \approx f(i)/N$, thus:

$$\operatorname{Ic}(x) \approx p(0)^2 + \cdots + p(25)^2 = \sum_i p(i)^2$$

The $\operatorname{Ic}$ measures some **redundancy** value for a sequence of characters.

Three interesting cases for $x$.

- $x$ is a (long enough) English text:
  - $p(i)$ follows the well known probability values of English letters.
  - $\operatorname{Ic}(x) \approx 0.065$

- $x$ is obtained from a monoalphabetic substitution cipher applied to an English text:
  - Individual probabilities are permuted, but the overall result is unchanged.
  - $\operatorname{Ic}(x) \approx 0.065$, the same as for the plaintext.

- $x$ is a uniformly distributed random sequence:
  - $p(i) = 1/26$, for every $i$
  - $\operatorname{Ic}(x) = 26 \cdot (1/26)^2 = 1/26 \approx 0.038$

In short:
- high value → low randomness → $\operatorname{Ic}(x) \approx 0.065$
- low value  → max randomness → $\operatorname{Ic}(x) \approx 0.038$

##### Key Length disclosure

Given the ciphertext:

$$y = (y_0, \ldots, y_{n-1})$$

The original Friedman test estimates $m$ directly from $\operatorname{Ic}(y)$.
Two letters extracted from $y$ are encrypted with the same key value with
probability about $1/m$. With $\kappa_p \approx 0.065$ (English) and
$\kappa_r = 1/26 \approx 0.038$ (random), for a long ciphertext:

$$
\operatorname{Ic}(y) \approx \frac{\kappa_p}{m} + \left(1 - \frac{1}{m}\right) \kappa_r
\quad \Rightarrow \quad
m \approx \frac{\kappa_p - \kappa_r}{\operatorname{Ic}(y) - \kappa_r}
$$

The estimate is rough. A more precise method tests each candidate separately.

We test a key length candidate $m$ by arranging the ciphertext in a matrix of
$m$ rows (the first column contains the first $m$ characters of the ciphertext).

$$
\begin{bmatrix}
y_0 & y_m & \cdots \\
\vdots & \vdots & \ddots \\
y_{m-1} & y_{2m-1} & \cdots
\end{bmatrix}
=
\begin{bmatrix}
R_0 \\ \vdots \\ R_{m-1}
\end{bmatrix}
$$

Compute the $\operatorname{Ic}$ for each row $R_i$.

- If the key length $m$ is correct then $R_i$ is a sequence whose elements are
  all encrypted with the same key value, thus $\operatorname{Ic}(R_i)$ should be high (close
  to $0.065$).
- If the key length is incorrect then $\operatorname{Ic}(R_i)$ will be low (close to $0.038$).
- If $m$ is a multiple of the correct key length then each row is still
  encrypted with one key value, and $\operatorname{Ic}(R_i)$ is high too. Thus
  choose the smallest candidate with high values.

(Note: we could have used the entropy of $x$)

##### Key disclosure

Once that the key length $m$ is disclosed, we proceed determining the single
letters of the key $k = (k_0, \ldots, k_{m-1})$.

$$
\begin{aligned}
&R_0 \text{ has been encrypted with } k_0 \\
&N_0 = \operatorname{length}(R_0) \\
&p(i) = \text{prob for the } i\text{-th char when using English language}
\end{aligned}
$$

How encryption is done using $k_0$ on the single plaintext characters:

  | Plaintext  | English prob. $p(i)$ | Ciphertext   |  Cipher frequencies            |
  |------------|----------------------|--------------|--------------------------------|
  | $0$        |    $p(0)$            | $(0+k_0) \bmod 26$ |     $f((0+k_0) \bmod 26)/N_0$  |
  | ...        |    ...               |   ...        |     ...                        |
  | $25$       |    $p(25)$           | $(25+k_0) \bmod 26$ |     $f((25+k_0) \bmod 26)/N_0$ |

As the value of $k_0$ we need to choose the value that better approximates the
English typical frequencies.

For each candidate $j \in \mathbb{Z}_{26}$ we define the vector of the
frequencies in $R_0$ shifted back by $j$, and the vector of the English
probabilities:

$$
\begin{aligned}
F_j &= \left( \frac{f(j)}{N_0}, \frac{f((1+j) \bmod 26)}{N_0}, \ldots, \frac{f((25+j) \bmod 26)}{N_0} \right) \\
P &= (p(0), \ldots, p(25))
\end{aligned}
$$

Then $k_0$ is equal to the $j$ for which the distance $\lVert F_j - P \rVert$ is
minimal. An **equivalent** technique often reported in literature is to get the
$j$ that maximizes the scalar product $F_j \cdot P$. The two are equivalent
because $\lVert F_j - P \rVert^2 = \lVert F_j \rVert^2 + \lVert P \rVert^2 - 2 F_j \cdot P$,
and $\lVert F_j \rVert$ does not depend on $j$ ($F_j$ is a cyclic shift of $F_0$).

The procedure is repeated for every row $R_i$ to gain different parts of the key.

Note that this is exactly the same attack used for the shift encryption (only
more structured) where we'd have a single row $R$ containing the full ciphertext.

As the opposite extreme case, if the key length is equal to the length of
the plain text, each row $R_i$ has just one element, thus we have no material to analyze the
frequencies.


## Affine Cipher

A substitution cipher where substitution algorithm requires multiplication and
addition.

The key is defined as a pair of integers $(a, b)$ in $\mathbb{Z}_{26}$.

$$
\begin{aligned}
E_{(a,b)}[p] &= (a \cdot p + b) \bmod 26 = c \\
D_{(a,b)}[c] &= (c - b) \cdot a^{-1} \bmod 26 = p
\end{aligned}
$$

Note that $a$ is required to be invertible modulo $|A| = 26$, thus is required
that $\gcd(a, 26) = 1$. Because $26 = 13 \cdot 2$ then $a$ can't be even or 13.

The shift cipher is the special case $a = 1$. The *Atbash* cipher, which maps
$a \to z$, $b \to y$, ..., $z \to a$, is the special case $a = b = 25$:
$c = (25 - p) \bmod 26 = (25 \cdot p + 25) \bmod 26$.

### Attacks

The affine cipher defined over $A = \mathbb{Z}_{26}$ has only $26 \cdot 12 = 312$ possible keys.
A brute force attack is trivial over such a small set.

Frequency analysis can also be used like any other substitution cipher.

The cipher is vulnerable to a known plaintext attack when two pairs $(p_1, c_1)$
and $(p_2, c_2)$ are known:

$$
\begin{aligned}
c_1 &= a \cdot p_1 + b \pmod{26} \\
c_2 &= a \cdot p_2 + b \pmod{26} \\
c_1 - c_2 &= a \cdot (p_1 - p_2) \pmod{26} \\
a &= (c_1 - c_2) \cdot (p_1 - p_2)^{-1} \bmod 26 \\
b &= (c_1 - a \cdot p_1) \bmod 26
\end{aligned}
$$

The only requirement is that $(p_1 - p_2)$ is invertible modulo $|A|$.


## Transposition Cipher

Scrambles the position of the plaintext characters without changing the
characters themselves.

Given a plaintext with length $N$ and the number of occurrences of the i-th
alphabet character $f_i$, then the number of possible ciphertexts are $N!/\prod_i f_i!$.

For instance, the plaintext "santarealfun" can be encrypted in
$12!/(3! \cdot 2!) = 39{,}916{,}800$ different ways, one of these is "satanfuneral".

By dividing and processing the plaintext in blocks of length $m$, encryption can
be formalized by multiplying each block by an $m \times m$ permutation matrix.

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

With a block size $m$, if we interpret the cipher as a monoalphabetic cipher,
the alphabet can be also viewed as $\mathbb{Z}_{26}^m$.

Each plaintext and ciphertext block is represented as an $m \times 1$ column vector:

$$
p = \begin{bmatrix} p_1 \\ \vdots \\ p_m \end{bmatrix}
\qquad
c = \begin{bmatrix} c_1 \\ \vdots \\ c_m \end{bmatrix}
$$

The block transformation is driven by the key $K$, an $m \times m$ square matrix:

$$
K = \begin{bmatrix}
k_{11} & \cdots & k_{1m} \\
\vdots & \ddots & \vdots \\
k_{m1} & \cdots & k_{mm}
\end{bmatrix}
$$

Encryption and decryption functions are defined as:

$$
\begin{aligned}
E_K[p] &= K \cdot p \bmod 26 = c \\
D_K[c] &= K^{-1} \cdot c \bmod 26 = p
\end{aligned}
$$

With modular operation applied to the result of row by column product.

The transformation is a matrix-vector product:

$$
\begin{aligned}
c_1 &= k_{11} \cdot p_1 + \cdots + k_{1m} \cdot p_m \pmod{26} \\
&\;\;\vdots \\
c_m &= k_{m1} \cdot p_1 + \cdots + k_{mm} \cdot p_m \pmod{26}
\end{aligned}
$$

**Diffusion principle**: a single ciphertext character depends on all the
plaintext characters within the same block.

The principle is quite effective against frequency analysis attacks by reducing
the redundancy of the single letters.

Note that decryption requires the key matrix to be **invertible** modulo $|A|$.

When operating over real numbers a matrix is invertible if the columns are
linearly independent (i.e. we cannot express one column as a linear combination
of the others). In other, equivalent, terms a matrix $K$ is invertible if and
only if $\det(K) \ne 0$.

In modular arithmetic the inverse of a matrix exists if and only if the
determinant is coprime with the alphabet size or in other words if and only if
$\det(K)$ is invertible modulo $|A|$.

$$K \text{ is invertible modulo } |A| \iff \gcd(\det(K), |A|) = 1$$

The determinant is typically computed via the **Laplace** (cofactor) expansion
or via Gaussian elimination.

The inverse matrix $B = K^{-1}$ elements are computed with the adjugate formula:

$$b_{ij} = (-1)^{i+j} \cdot \det(K^*_{ji}) \cdot \det(K)^{-1} \bmod |A|$$

Where:
- $K^*_{ji}$: is the submatrix of $K$ obtained by removing from $K$ the row $j$
  and column $i$.
- $\det(K)^{-1}$ is the inverse of the determinant modulo $|A|$. The inverse exists
  when $\gcd(\det K, |A|) = 1$.

### Attack

Because of the diffusion principle, the cipher resists simple frequency analysis
of single letters. It is still vulnerable to ciphertext only attacks for small
$m$ (e.g. digraph frequency analysis for $m = 2$, or attacks that recover the
key one row at a time), and it easily fails with a known-plaintext attack.

Assume that the attacker knows $m$ and $m$ couples of plaintext/ciphertext
blocks $(p_i, c_i)$ of length $m$ encrypted using the same key $K$:

$$c_i = K \cdot p_i \bmod |A|$$

We merge the $c_i$ and $p_i$ column vectors to obtain two $m \times m$ matrices

$$
\begin{aligned}
[c_1 \mid \cdots \mid c_m] &= K \cdot [p_1 \mid \cdots \mid p_m] \\
C &= K \cdot P
\end{aligned}
$$

Next we can use one of the well-known matrix resolution methods (e.g. Gaussian
elimination method, LU decomposition, ...) to compute $P^{-1}$, and then the key:

$$K = C \cdot P^{-1} \bmod |A|$$

Since 26 is not a prime, Gaussian elimination modulo 26 requires every pivot to
be invertible modulo 26. Alternatively, we can work modulo 2 and modulo 13 and
combine the results via the Chinese remainder theorem.

If $P$ is not invertible modulo $|A|$, then we should try with a different set
of $(p_i, c_i)$. It follows that the first thing the attacker should do is to check if
$P$ is invertible by computing its determinant.


## Wrapping Up

### Affine Transformation

In practice, excluded the generic non-linear substitution cipher, **all**
the classical ciphers viewed so far can be expressed using exactly the same
**affine transformation**:

$$
\begin{aligned}
E[p] &= (M \cdot p + b) \bmod |A| = c \\
D[c] &= M^{-1} \cdot (c - b) \bmod |A| = p
\end{aligned}
$$

With $M$ a matrix providing diffusion and $b$ a vector providing polyalphabetic
shift encryption.

- Shift cipher: $M$ is a $1 \times 1$ identity matrix and $b$ a vector of length 1.
- Vigenère cipher: $M$ is an $m \times m$ identity matrix and $b$ an $m \times 1$ vector.
- Affine cipher: $M$ is a $1 \times 1$ invertible matrix and $b$ a vector of length 1.
- Transposition cipher: $M$ is an $m \times m$ permutation matrix and $b$ is a zero vector.
- Hill cipher: $M$ is an $m \times m$ invertible matrix and $b$ is an $m \times 1$ zero vector.

We can obviously extend the Hill cipher by using an arbitrary $m \times 1$ vector $b$.

### Lesson Learned

In general, once the key has been fixed, we obtain a function from plaintext to
ciphertext. This function should **NOT** be a linear (or affine) transformation.

If the cipher is based on a linear or affine function then we can always apply some simple
technique to break it (or weaken it if it has some linear component).

Modern standards require that a cipher should resist chosen-plaintext attacks,
and usually also chosen-ciphertext attacks.

If we combine an operation providing **diffusion** (as Hill) with some elements
of **confusion** (as a non-linear substitution) we can obtain a strong cipher.

This naturally leads to the idea of product ciphers, proposed by Shannon, which
alternate confusion and diffusion layers. Modern designs of this kind are the
Substitution-Permutation Network (SPN) and the Feistel network.


## References

- [cry](https://github.com/davxy/cry/blob/master/src/crypt/affine.c) affine cipher
- [Feistel ciphers](/posts/feistel-ciphers)
- D. R. Stinson, *Cryptography: Theory and Practice*, CRC Press
