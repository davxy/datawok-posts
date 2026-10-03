+++
title = "Feistel Ciphers"
date = "2017-11-07"
modified = "2023-11-26"
tags = ["cryptography"]
toc = true
+++

Feistel ciphers are a family of symmetric encryption algorithms that use
repeated rounds of substitution and permutation operations on blocks of data to
provide confidentiality.

Popular examples of Feistel ciphers include:
- [DES](https://en.wikipedia.org/wiki/Data_Encryption_Standard)
- [Twofish](https://en.wikipedia.org/wiki/Twofish)
- [Blowfish](https://en.wikipedia.org/wiki/Blowfish_(cipher))
- [CAST-128](https://en.wikipedia.org/wiki/CAST-128)
- [GOST](https://en.wikipedia.org/wiki/GOST_(block_cipher))
- [Camellia](https://en.wikipedia.org/wiki/Camellia_(cipher))
- [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) (not a Feistel cipher: AES is an SPN)

In this post I'll mostly go through the basic principles of Feistel ciphers and
analyze the design of DES, with a rough evaluation of some of its security aspects.


## Problem with Generic Block Substitution Ciphers

In a *generic* block substitution cipher the plaintext is associated with the
ciphertext using an arbitrary **permutation** table.

Consider an alphabet of size $M$ and a block length $n$. The number of
possible plaintext and ciphertext blocks is $|P| = |C| = M^n$ and
there are $|K| = M^n!$ possible ways to define the encryption function from $P$
to $C$ (the keyspace).

For instance, with 64-bit blocks $|P| = |C| = 2^{64}$, $|K| = 2^{64}!$.

This kind of cipher is generally very secure because:
- big blocks defeat statistical analysis;
- the plaintext-ciphertext mapping is non-linear and hopefully uniformly random;
- the keyspace size grows exponentially with respect to the block size.

Unfortunately the **key size** is impractical.

For each possible plaintext block we have to explicitly share the
corresponding ciphertext block (there is no compact key derivation algorithm).

At best, if we consider the plaintext as a numeric sequence from $0$ to
$M^n - 1$, we can just share the sorted list of associated ciphertext
blocks (the plaintext block is implicit).

For instance, if the block length is 64 bits the key consists of the explicit
enumeration of $2^{64}$ encrypted blocks. The key length is thus:

$$\operatorname{keylen} = \operatorname{len}(\text{block}) \cdot |C| = 64 \cdot 2^{64} = 2^{70} \approx 10^{21} \text{ bits}$$


## Substitution Permutation Network (SPN)

Shannon proposed to trade some security for a more manageable key length.

Instead of a general block substitution cipher we opt for a cipher which
iteratively applies a series of simple transformations to the plaintext.

**Diffusion**. The information of every word in the plaintext block is spread
all over the ciphertext block. The goal is to dissipate the redundancy of the
plaintext, which may be used for statistical analysis.

Diffusion techniques:
1. **Permutation**. We swap the elements within the block. This doesn't alter
   the frequency of single words, but alters the groups of words (n-grams).
   Permutation is a linear transformation: multiplication by a permutation matrix.
2. **Combination**. Every ciphertext element is a function of (ideally all) the
   elements of the plaintext. Still a linear transformation.

**Confusion**. It makes the relation between plaintext and ciphertext hard to
invert once the key is fixed.

Confusion is mostly obtained by introducing some kind of **non-linear**
transformation. In practice, this is a **substitution** element which fetches
ciphertext data from a table as a function of the plaintext and the key.

These non-linear substitution tables are typically known as *s-box*es, a name
originally borrowed from DES.


## Feistel Cipher

Horst Feistel (IBM, early 1970s) proposed a structure that is different from an
SPN, but follows the same idea of a product cipher: many rounds that alternate
confusion and diffusion. The round function $F$ does not need to be invertible,
and this makes the implementation practical. Many block ciphers use this
structure, for example DES, Blowfish, Twofish and Camellia. AES uses an SPN.

A plaintext block is divided into two halves $L_0$ and $R_0$.

Encryption is performed by applying a series of *rounds* to the plaintext.

For each round a sub-key $k_i$ is derived from the main key $k$.

![Feistel network](/companions/feistel-ciphers/network.svg)

All the rounds use the same logic, only the inputs change.

In the final step $L_n$ and $R_n$ are swapped and marked as $L_{n+1}$ and $R_{n+1}$.

### Round

Compact formulas:

$$
\begin{aligned}
L_i &= R_{i-1} \\
R_i &= L_{i-1} \oplus F(k_i, R_{i-1})
\end{aligned}
$$

Round actions:
- The swap of the two halves applies the **permutation** (diffusion) principle.
- The xor applies the **combination** (diffusion) principle, i.e. the result for
  one half depends on both halves.
- The function $F$ applies the **substitution** (confusion) principle, i.e.
  groups of bits are non-linearly replaced with others as a function of the key.

### Encryption

Assume blocks of length $2 \cdot w$.

Split:

$$
\begin{aligned}
L_0 &= \text{Plaintext}[..w] \\
R_0 &= \text{Plaintext}[w..]
\end{aligned}
$$

Repeat for $n$ rounds:

$$
\begin{aligned}
L_i &= R_{i-1} \\
R_i &= L_{i-1} \oplus F(k_i, R_{i-1})
\end{aligned}
$$

Final swap:

$$
\begin{aligned}
L_{n+1} &= R_n \\
R_{n+1} &= L_n
\end{aligned}
$$

Merge:

$$
\begin{aligned}
\text{Ciphertext}[..w] &= L_{n+1} \\
\text{Ciphertext}[w..] &= R_{n+1}
\end{aligned}
$$

### Decryption

The decryption algorithm is the same as encryption. The only difference is that
the sub-keys are used in the opposite order (from $k_n$ to $k_1$).

This works because of the following property of the round function:

![Decryption round](/companions/feistel-ciphers/decryption-round.svg)

Note that the $R$ and $L$ components are wired in the opposite order with
respect to the encryption procedure.

Given the round definition (used by encryption):

$$
\begin{aligned}
L_i &= R_{i-1} \\
R_i &= L_{i-1} \oplus F(k_i, R_{i-1})
\end{aligned}
$$

Note that one side is always recoverable as it is forwarded untouched.
Thus, given $k_i$, we can apply $F$ to that side and recover the other side as well.

Applied to the decryption inputs, this gives:

$$
\begin{aligned}
R_{i-1} &= L_i \\
L_{i-1} &= R_i \oplus F(k_i, L_i)
\end{aligned}
$$

By the definition of the encryption routine we can indeed see that:

$$L_i = R_{i-1} \quad \text{(one half is correctly inverted)}$$

For the second half, given that the encryption function is defined as:

$$R_i = L_{i-1} \oplus F(k_i, R_{i-1})$$

Substituting $R_i$ in the decryption procedure:

$$
\begin{aligned}
L_{i-1} &= R_i \oplus F(k_i, L_i) \\
&= [L_{i-1} \oplus F(k_i, R_{i-1})] \oplus F(k_i, L_i) \\
&= [L_{i-1} \oplus F(k_i, L_i)] \oplus F(k_i, L_i) && \text{(given that } L_i = R_{i-1} \text{)} \\
&= L_{i-1}
\end{aligned}
$$

The identity holds, thus decryption correctly inverts the encryption
procedure.


## DES Construction Details

In DES the block size is 64 bits and the key size is 56 bits.

The three elements defining the security of the cipher are:
- the number of rounds $n$
- the sub-keys generation function $G$ (key schedule algorithm)
- the function $F$

The more rounds we apply, the more secure the cipher is.

For DES the number of rounds ($n = 16$) was chosen to counter the attacks known
at the time. In particular, it was chosen such that the best known
cryptanalytic attacks have the same order of complexity as a brute-force attack.

For example, with fewer rounds the cipher is vulnerable to differential
cryptanalysis (a chosen-plaintext attack). With 16 rounds the attack of Biham
and Shamir needs $2^{47}$ chosen plaintexts, and its known-plaintext version needs $2^{55}$ known plaintexts. A brute-force attack
tries $2^{55}$ keys on average and needs only a few known plaintext-ciphertext
pairs. Thus in practice brute force is still the best attack.

### Key schedule

The key schedule transforms the 56-bit key into 16 sub-keys of 48 bits, one for each round.

1. Initial permutation according to a fixed table.
2. Split into two 28-bit halves $(C_0, D_0)$.
3. Key iterations: $(C_i, D_i)$ are rotated to the left by 1 or 2 positions.
4. Round key generation: $(C_i, D_i)$ are combined, permuted and 48 bits are selected.

### F Function

$$F(k_i, R_{i-1})$$


- $R_{i-1}$: right input half (32 bits)
- $k_i$: i-th sub-key (48 bits)

The $F$ procedure:
1. An **expansion** is applied to $R_{i-1}$ by duplicating some of the 32 bits
   to obtain a 48-bit output.
2. The result is **xor**ed with the round sub-key $k_i$.
3. The result is partitioned into 8 blocks of 6 bits each.
4. Each 6-bit block is replaced by a 4-bit block using one of 8 substitution
   tables (**s-boxes**).
5. These 8 blocks are concatenated to get a 32-bit output.
6. A constant **permutation** is applied to the 32-bit output.

#### S-Box

An s-box is a lookup table that takes $m$ bits as input and yields $n$ bits as
output. For example in DES $m = 6$ and $n = 4$.

IBM kept the design criteria of the DES s-boxes secret for about 20 years.
Coppersmith published them in 1994: one of the goals was resistance to
differential cryptanalysis, which IBM knew in 1974 and kept secret.

Each DES s-box is a constant table of 64 elements arranged in 4 rows and 16
columns. Each row contains a permutation of the numbers between 0 and 15.

The 6 input bits are used to choose one element from the table:
- the first and last bits choose the row
- the middle four bits choose the column

Two properties often used to evaluate an s-box are SAC and BIC, defined by
Webster and Tavares in 1985. They are more recent than DES, and the DES s-boxes
satisfy them only approximately.

**Strict Avalanche Criterion** (SAC). If the i-th input bit changes then the
j-th output bit changes with probability 1/2.

**Bit Independence Criterion** (BIC). If the i-th input bit changes then the
changes of the j-th and k-th output bits are independent.

In other words, the properties say that a small change in the input influences
all the output bits (SAC) and that the changes are independent for each bit
(BIC).

We can analyze the s-box as a function $S$ that takes as input a random
variable $X$ ($m$ bits) and returns a random variable $Y$ ($n$ bits):

$$Y = S(X)$$

 - $X[i]$: the i-th bit of $X$
 - $X^i$: $X$ with the i-th bit flipped

##### SAC Check

For an arbitrary input bit $i$:

$$Y_1 = S(X), \quad Y_2 = S(X^i)$$

Then, for any output bit $j \in \{1, \ldots, n\}$

$$\Pr[Y_1[j] \ne Y_2[j]] = \frac{1}{2}$$

That is, if we complement the $i$-th input bit, any output bit $j$ changes with
probability $1/2$.

To evaluate this probability for a particular s-box, we check over all the
possible inputs how often each output bit changes when we flip an input bit.

##### BIC Check

For each input bit $i$ and each pair of output bits $j \ne k$, when bit $i$ is
flipped, the changes of $Y[j]$ and $Y[k]$ are independent events.

### DES Undesired properties

- Complementation property: $E(\lnot k, \lnot m) = \lnot E(k, m)$
- Weak keys: for 4 keys (e.g. $k = 0$) all the sub-keys are equal, thus
  $E(k, m) = D(k, m)$
- Semi-weak keys: for 6 pairs of keys $(k, k')$, $E(k', E(k, m)) = m$

These properties allow a *distinguishing attack*, a (mostly theoretical) attack
that distinguishes the cipher from a "*perfect cipher*" (a random permutation)
when the cipher functions are given as black boxes.


## References

- DES s-box SAC property evaluation [here](https://github.com/davxy/crypto-hacks/tree/main/des-sbox-eval)
- DES s-box BIC property evaluation (TODO...)
- [Classical ciphers](/posts/classical-ciphers)
- E. Biham, A. Shamir, *Differential Cryptanalysis of the Full 16-round DES*, CRYPTO '92
- D. Coppersmith, *The Data Encryption Standard (DES) and its strength against attacks*,
  IBM Journal of Research and Development, 38(3), 1994
- A. F. Webster, S. E. Tavares, *On the Design of S-Boxes*, CRYPTO '85
