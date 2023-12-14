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
- [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) (well, not really a Feistel cipher, but follows some design principles of SPN network)

In this post I'll mostly go through the basics of Feistel ciphers principles and
analyze DES design with a rough evaluation of some of its security aspects.


## Problem with *pure* Block Substitution Ciphers

In a *pure* block substitution cipher the plaintext is associated to the
ciphertext using an arbitrary **permutation** table.

Consider an alphabet with size `M` and block length `N`, then the number of
possible plaintext and ciphertext blocks is `|P| = M^N` and there are
`|K| = |P|!` possible ways to define the encryption function from `P` to `C`
(keyspace).

For example, with 64 bit blocks the keyspace size is:
- size of `P` and `C` is `2^64`;
- ways to define encryption function `|K| = (2^64)!`.

Such a pure block substitution cipher is generally very secure:
- big blocks defeat statistical analysis;
- the plaintext-ciphertext mapping is non-linear and hopefully uniformly random;
- the keyspace is gigantic.

Unfortunately the **key size** is impractical.

For each possible plaintext block we have to explicitly share what is the
corresponding ciphertext block (there is no compact key derivation algorithm).

At best, if we consider the plaintext as a numeric sequence from `0` to
`2^64-1`, we can just share the sorted list of associated ciphertext blocks
(the plaintext block is implicit).

For example, if each block length is 64 bits the key consists of the explicit
enumeration of `2^64` encrypted blocks. The key length is thus:

    keylen = len(block)·|C| = 64·2^64 = 2^70 ≈ 10^21 bits


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
   elements of the plaintext (similarly to Hill cipher). Still a linear
   transformation.

**Confusion**. Making hard to invert the relation between plaintext and
ciphertext obtained once the key has been fixed.

Confusion is mostly obtained by introducing some kind of **non-linear**
transformation. In practice a **substitution** element which fetches ciphertext
data from a table in function of the plaintext and a key.

These non-linear substitution tables are typically known as *s-box*es, a name
originally borrowed from DES.


## Feistel Cipher

Feistel (IBM engineer ~1960/70) provided a pragmatic description of an SPN
in order to allow a practical implementation.

The design is the foundation of almost every modern symmetric block cipher.

A plaintext block is divided into two halves `L0` and `R0`.

Encryption is performed by applying to the plaintext a series of *rounds*.

For each round a sub-key `ki` is derived from the main key `k`.

         +-------+                       +-------+        +------+
    L0 → | Round | → L1 → ... → L(n-1) → | Round | → Ln → | Swap | → L(n+1)
    R0 → |       | → R1 → ... → R(n-1) → |       | → Rn → |      | → R(n+1)
         +-------+                       +-------+        +------+
             ↑                               ↑
             k1                              kn

The rounds' logic is identical to each other, what changes are the inputs.

In the final step `Ln` and `Rn` are just swapped and marked as `L(n+1)` and
`R(n+1)`.

### Round

Compact formulas:

    Li = R(i-1)
    Ri = L(i-1) ⊕ F[ki, R(i-1)]

Round actions:
- Swap of the two halves applies the **permutation** (diffusion) principle.
- Xor applies the **combination** (diffusion) principle, i.e. one half result
  depends on both the halves.
- F function applies the **substitution** (confusion) principle, i.e. groups
  of bits are non-linearly replaced with others in function of the key.

### Encryption

Assuming blocks with length `2·w`.

Split:

    L0 = Plaintext[..w]
    R0 = Plaintext[w..]

Repeat for `n` rounds:

    Li = R(i-1)
    Ri = L(i-1) ⊕ F[ki, R(i-1)]

Final swap:

    L(n+1) = Rn
    R(n+1) = Ln

Merge:

    Ciphertext[..w] = L(n+1)
    Ciphertext[w..] = R(n+1)

### Decryption

Decryption algorithm is equal to encryption, the only difference is that the
keys are used in the opposite order (from `kn` to `k1`).

The requirement is the following property of round function:

         +-------+
    Ri → | Round | → R(i-1)
    Li → |       | → L(i-1)
         +-------+
            ↑
            ki

Note that the `R` and `L` components are wired in the opposite order with
respect to the encryption procedure.

Given the round definition (used by encryption):

    Li = R(i-1)
    Ri = L(i-1) ⊕ F[ki, R(i-1)]

Note that one side is always recoverable as it is forwarded untouched.
Thus, given `k` and applying `F` to it, we can recover the other side as well.

When applied to the decryption inputs we have that:

    R(i-1) = Li
    L(i-1) = Ri ⊕ F[ki, Li]

By the definition of the encryption routine we can indeed see that

    Li = R(i-1) , we inverted correctly one half

For second half, given that the encryption function is defined as:

    Ri = L(i-1) ⊕ F(ki, R(i-1))

Replacing `Ri` in the defined decryption procedure:

    L(i-1) = Ri ⊕ F(ki, Li) =
           = [L(i-1) ⊕ F(ki, R(i-1))] ⊕ F(ki, Li) =
           (given that Li = R(i-1))
           = [L(i-1) ⊕ F(ki, Li)] ⊕ F(ki, Li) =
           = L(i-1)

The identity holds, thus we found that the decryption correctly reverts the
encryption procedure.


## DES Construction Details

The three elements defining the security of the cipher are:
- the number of rounds `n`
- the function `F`
- the sub-keys generation function `G`

The more rounds we apply the more secure is the cipher.

For DES the number of rounds (`n = 16`) has been chosen to contrast the attacks
known at the time. In particular, it has been chosen a number such that the best
known cryptanalytic attacks have the same order of complexity as a brute force
attempt.

For example, by reducing the number of rounds the cipher would be vulnerable to
differential cryptanalysis. With 16 rounds differential cryptanalysis requires
`2^55` operations, computationally comparable to a brute-force attack.

### F Function

    F[R(i-1), ki]

- `R(i-1)`: right input half (32 bits)
- `ki`: i-th subkey (48 bits)

Details of `F` procedure:
1. A constant **permutation** is applied to `R(i-1)`.
2. An **expansion** is applied by duplicating some of the 32 bits to obtain a 48
   bit output.
3. The result is **xor**ed with the round subkey `ki`.
4. The result is partitioned in 8 blocks of 6 bits each.
5. Each of these 8 blocks of 6 bits are replaced by 8 blocks of 4 bits using 8
   substitution tables (**s-box**).
6. These 8 blocks are finally concatenated to get a 32 bit output.

### S-Box

An s-box is a lookup table taking as input `m` bits and yielding as output `n`
bits. For example in DES `m = 6` and `n = 4`.

The criteria used to construct the s-box for DES has never been completely
clarified by their designers but in practice has withstood the test of time.

DES s-box is a constant table of 64 elements divided in 4 rows and 16 columns.
Each row contains a permutation of the numbers between 0 and 15.

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

    X(i)  = the i-th bit of X
    X(i') = X with the i-th bit flipped

#### SAC Check

For an arbitrary input bit `i`:

    Y1 = S(X), Y2 = S(X(i'))

Then for any output bit `j ∈ {1..n}`

    Pr[ Y1(j) ≠ Y2(j) ] = 1/2

That is, by complementing the `i`-th input bit the probability to change an
arbitrary output bit `j` is 1/2.

To evaluate this probability for a particular s-box for all possible inputs we
need to (empirically) check how many output bits are changing when we change an
input bit.


#### BIC Check

For each input i and output j, the output changes independently when the input
changes (independent events).

### Undesired properties

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
