+++
title = "Feistel Ciphers"
date = "2017-11-07"
modified = "2023-11-26"
tags = ["cryptography"]
toc = true
+++

Feistel ciphers are a family of symmetric encryption algorithms that use
repeated rounds of substitution and permutation operations on blocks of data to
provide confidentiality and data integrity.

Popular examples of Feistel ciphers include:
- [DES](https://en.wikipedia.org/wiki/Data_Encryption_Standard)
- [Twofish](https://en.wikipedia.org/wiki/Twofish)
- [Blowfish](https://en.wikipedia.org/wiki/Blowfish_(cipher))
- [IDEA](https://en.wikipedia.org/wiki/International_Data_Encryption_Algorithm)
- [CAST-128](https://en.wikipedia.org/wiki/CAST-128)
- [GOST](https://en.wikipedia.org/wiki/GOST_(block_cipher))
- [Camellia](https://en.wikipedia.org/wiki/Camellia_(cipher))
- [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) (not really a Feistel cipher, but follows some of the SPN design principles)

In this post I'll mostly go through the basics of Feistel ciphers principles and
analyze DES design with a rough evaluation of some of its security aspects.


## Problem with Generic Block Substitution Ciphers

In a *generic* block substitution cipher the plaintext is associated to the
ciphertext using an arbitrary **permutation** table.

Consider an alphabet with size `M` and block length `n`, then the number of
possible plaintext and ciphertext blocks is `|P| = |C| = Mⁿ` (key length) and
there are `|K| = Mⁿ!` possible ways to define the encryption function from `P`
to `C` (keyspace).

For instance, with 64 bit blocks `|P| = |C| = 2⁶⁴`, `|K| = 2⁶⁴!`.

This kind of cipher is generally very secure as
- big blocks defeat statistical analysis;
- plaintext-ciphertext mapping is non-linear and hopefully uniformly random;
- keyspace size grows exponentially with respect to the block size.

Unfortunately the **key size** is impractical.

For each possible plaintext block we have to explicitly share what is the
corresponding ciphertext block (there is no compact key derivation algorithm).

At best, if we consider the plaintext as a numeric sequence from `0` to
`Mⁿ-1`, we can eventually just share the sorted list of associated ciphertext
blocks (the plaintext block is implicit).

For instance, if each block length is 64 bits the key consists of the explicit
enumeration of `2⁶⁴` encrypted blocks. The key length is thus:

    keylen = len(block)·|C| = 64·2⁶⁴ = 2⁷⁰ ≈ 10²¹ bits


## Substitution Permutation Network (SPN)

Shannon proposed to trade some security for a more manageable key length.

Instead of a general block substitution cipher we opt out for a cipher which
iteratively apply a series of simple transformations to the plaintext.

**Diffusion**. The information of every word in the plaintext block is spread
all over the ciphertext block. The goal is to remove redundant data that may be
used for statistical analysis.

Diffusion techniques:
1. **Permutation**. We swap the elements within the block. This doesn't alter
   the frequency of the single words, but alters the groups of words (n-grams).
   Permutation is a linear transformation: product with a permutation matrix.
2. **Combination**. Every ciphertext element is function of (ideally all) the
   elements of the plaintext. Still a linear transformation.

**Confusion**. Making hard to invert the relation between plaintext and
ciphertext obtained once the key has been fixed.

Confusion is mostly obtained by introducing some kind of **non-linear**
transformation. In practice a **substitution** element which fetches ciphertext
data from a table in function of the plaintext and a key.

These non-linear substitution tables are typically known as *s-box*es, a name
originally borrowed from DES.


## Feistel Cipher

Feistel (IBM engineer ~1960/70) provided a pragmatic description of a SPN
in order to allow a practical implementation. Its design is the foundation of
almost every modern symmetric block cipher.

A plaintext block is divided into two halves `L₀` and `R₀`.

Encryption is performed by applying to the plaintext a series of *rounds*.

For each round a sub-key `kᵢ` is derived from the main key `k`.

         +-------+                     +-------+        +------+
    L₀ → | Round | → L₁ → ... → Lₙ₋₁ → | Round | → Lₙ → | Swap | → Lₙ₊₁
    R₀ → |       | → R₁ → ... → Rₙ₋₁ → |       | → Rₙ → |      | → Rₙ₊₁
         +-------+                     +-------+        +------+
             ↑                             ↑
             k₁                            kₙ

The rounds' logic is identical to each other, what changes are the inputs.

In the final step `Lₙ` and `Rₙ` are swapped and marked as `Lₙ₊₁` and `Rₙ₊₁`.

### Round

Compact formulas:

    Lᵢ = Rᵢ₋₁
    Rᵢ = Lᵢ₋₁ ⊕ F(kᵢ, Rᵢ₋₁)

Round actions:
- Swap of the two halves applies the **permutation** (diffusion) principle.
- Xor applies the **combination** (diffusion) principle, i.e. one half result
  depends on both the halves.
- F function applies the **substitution** (confusion) principle, i.e. groups
  of bits are non-linearly replaced with others in function of the key.

### Encryption

Assuming blocks with length `2·w`.

Split:

    L₀ = Plaintext[..w]
    R₀ = Plaintext[w..]

Repeat for `n` rounds:

    Lᵢ = Rᵢ₋₁
    Rᵢ = Lᵢ₋₁ ⊕ F(kᵢ, Rᵢ₋₁)

Final swap:

    Lₙ₊₁ = Rₙ
    Rₙ₊₁ = Lₙ

Merge:

    Ciphertext[..w] = Lₙ₊₁
    Ciphertext[w..] = Rₙ₊₁

### Decryption

Decryption algorithm is equal to encryption, the only difference is that the
sub keys are used in the opposite order (from `kₙ` to `k₁`).

The requirement is the following property of round function:

         +-------+
    Rᵢ → | Round | → Rᵢ₋₁
    Lᵢ → |       | → Lᵢ₋₁
         +-------+
             ↑
             kᵢ

Note that the `R` and `L` components are wired in the opposite order with
respect to the encryption procedure.

Given the round definition (used by encryption):

    Lᵢ = Rᵢ₋₁
    Rᵢ = Lᵢ₋₁ ⊕ F(kᵢ, Rᵢ₋₁)

Note that one side is always recoverable as it is forwarded untouched.
Thus, given `k` and applying `F` to it, we can recover the other side as well.

When applied to the decryption inputs we have that:

    Rᵢ₋₁ = Lᵢ
    Lᵢ₋₁ = Rᵢ ⊕ F(kᵢ, Lᵢ)

By the definition of the encryption routine we can indeed see that:

    Lᵢ = Rᵢ₋₁ , we inverted correctly one half

For second half, given that the encryption function is defined as:

    Rᵢ = Lᵢ₋₁ ⊕ F(kᵢ, Rᵢ₋₁)

Replacing `Rᵢ` in the defined decryption procedure:

    Lᵢ₋₁ = Rᵢ ⊕ F(kᵢ, Lᵢ) =
           = [Lᵢ₋₁ ⊕ F(kᵢ, Rᵢ₋₁)] ⊕ F(kᵢ, Lᵢ) =
           (given that Lᵢ = Rᵢ₋₁)
           = [Lᵢ₋₁ ⊕ F(kᵢ, Lᵢ)] ⊕ F(kᵢ, Lᵢ) =
           = Lᵢ₋₁

The identity holds, thus the decryption correctly reverts the encryption
procedure.


## DES Construction Details

In DES the blocks are 64 bits and key size 56 bits.

The three elements defining the security of the cipher are:
- the number of rounds `n`
- the sub-keys generation function `G` (key schedule algorithm)
- the function `F`

The more rounds we apply the more secure is the cipher.

For DES the number of rounds (`n = 16`) has been chosen to contrast the attacks
known at the time. In particular, it has been chosen a number such that the best
known cryptanalytic attacks have the same order of complexity as a brute force
attempt.

For example, by reducing the number of rounds the cipher would be vulnerable to
differential cryptanalysis (a kind of chosen plaintext attack). With 16
rounds differential cryptanalysis requires `2⁵⁵` operations, computationally
comparable to a brute-force attack.

### Key schedule

Transform a 56 bit key into 16 48-bit sub keys, one for each round.

1. Initial permutation according to a fixed table.
2. Split in two 28-bit halves `(C₀, D₀)`.
3. Key iterations: `(Cᵢ, Dᵢ)` are rotated to the left by 1 or 2 positions.
4. Round key generation: `(Cᵢ, Dᵢ)` are combined, permuted and 48-bits are fetched.

### F Function

    F(Rᵢ₋₁, kᵢ)


- `Rᵢ₋₁`: right input half (32 bits)
- `kᵢ`: i-th subkey (48 bits)

Details of `F` procedure:
1. A constant **permutation** is applied to `Rᵢ₋₁`.
2. An **expansion** is applied by duplicating some of the 32 bits to obtain a 48
   bit output.
3. The result is **xor**ed with the round subkey `kᵢ`.
4. The result is partitioned in 8 blocks of 6 bits each.
5. Each of these 8 blocks of 6 bits are replaced by 8 blocks of 4 bits using 8
   substitution tables (**s-box**).
6. These 8 blocks are finally concatenated to get a 32 bit output.

#### S-Box

An s-box is a lookup table taking as input `m` bits and yielding as output `n`
bits. For example in DES `m = 6` and `n = 4`.

The criteria used to construct the s-box for DES has never been completely
clarified by their designers but in practice has withstood the test of time.

Each DES s-box is a constant table of 64 elements divided in 4 rows and 16
columns. Each row contains a permutation of the numbers between 0 and 15.

The 6 input bits are used to choose one element from the table:
- first and last bits are used to choose the row
- middle four bits are used to choose the column

The s-box are constructed such that the SAC and BIC properties hold.

**Strict Avalanche Criterion** (SAC). If the i-th input bit changes then the
j-th output bit changes with probability 1/2.

**Bit Independence Criterion** (BIC). If the i-th input bit changes then the
change observed in the j-th and k-th output bits are independent.

In other words, the properties say that a small change in the input influences
all the output bits (SAC) and that the changes are independent for each bit
(BIC).

We can analyze the s-box as if it is a function `S` taking as input an aleatory
variable `X` (m-bits) and returning an aleatory variable `Y` (n-bits):

    Y = S(X)

 - `X[i]`: the i-th bit of `X`
 - `Xⁱ`: `X` with the i-th bit flipped

##### SAC Check

For an arbitrary input bit `i`:

    Y₁ = S(X), Y₂ = S(Xⁱ)

Then for any output bit `j ∈ {1..n}`

    Pr[ Y₁[j] ≠ Y₂[j] ] = 1/2

That is, by complementing the `i`-th input bit the probability to change an
arbitrary output bit `j` is `1/2`.

To evaluate this probability for a particular s-box for all possible inputs we
need to (empirically) check how many output bits are changing when we change an
input bit.

##### BIC Check

For each input bit `i` and output bit `j`, the output changes independently when
the input changes (independent events).

### DES Undesired properties

- Reciprocal property: `D(E(m)) = m` and `E(D(m)) = m`
- Complementation property: `E(¬k,¬m) = ¬E(k,m)`
- Zero key: if `k = 0` then `E(k,m) = D(k,m)`

These properties allow a *distinguished attack*, a kind of (mostly theoretical)
attack that allows to distinguish the cipher from the "*perfect cipher*" when
the cipher functions are given as black boxes.


## References

- DES sbox SAC property evaluation [here](https://github.com/davxy/crypto-hacks/tree/main/des-sbox-eval)
- DES sbox BIC property evaluation (TODO...)
- [Classical ciphers](/posts/classical-ciphers)
