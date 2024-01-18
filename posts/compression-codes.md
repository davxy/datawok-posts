+++
title = "Compression Codes"
date = "2023-07-23"
modified = "2024-01-18"
tags = ["codes"]
toc = true
+++

## Codes Introduction

Given a finite alphabet `X` a **code** for `X` is a function:
  
    c: X → {0,1}*

We can extend the code to arbitrary strings with symbols in `X` as:

    c(x₁..xₖ) = c(x₁)..c(xₖ)

A code is **uniquely decodable** if its encoding function is injective.

Note that for all the entropy-related formulas we take as the base of the
logarithm the cardinality of the code's alphabet (in our case 2).

Given `x ∈ X`, the binary string `c(x)` is called a **codeword** while the set
`C = {c(x): x ∈ X}` is called a **codebook**.

Given a probability distribution defined over the alphabet symbols, we want to
find the code which minimizes the average length of the codewords.

From now on, for the i-th symbol of the alphabet `xᵢ ∈ X` we're going to alias
`c(xᵢ)` with `cᵢ` and the probability associated with the symbol `p(xᵢ)` with
`pᵢ`.

### Entropy Formulas Recap

- Entropy : `H(p) = ∑ₓ p(x)·log₂(1/p(x))`
- Cross Entropy : `H(p||q) = ∑ₓ p(x)·log₂(1/q(x))`
- Kullback-Leibler Divergence : `D(p||q) = ∑ₓ p(x)·log₂(p(x)/q(x))`
- Gibbs Inequality : `D(p||q) ≥ 0`
- Linking Identity : `H(p||q) = H(p) + D(p||q)`

## Prefix-Free Codes

A code is **prefix-free** (or **instantaneous**) if no codeword `cᵢ` is a prefix
of another codeword `cⱼ`, with `i ≠ j`.

Every prefix-free code is uniquely decodable, but the inverse is not true.

Fixed length codewords are prefix-free by definition, but not all prefix-free
codes are fixed length.

Decoding of an unambiguous binary string proceeds from left to right. As soon
as a codeword is found, we remove it from the encoded string, and we restart
decoding the next character.

*Examples*

Given the alphabet `X = {a, b, c, d}` the following codebooks can be associated
to the symbols of `X`:

    C₁ = {0, 111, 110, 101}    (prefix-free, variable length)
    C₂ = {00, 01, 10, 11}      (prefix-free, fixed length)
    C₃ = {0, 01, 011, 0111}    (not prefix-free, uniquely decodable)
    C₄ = {0, 1, 01, 10}        (non uniquely decodable)

In `C₃` the start of a codeword is marked by the symbol `0` and thus the code is
unambiguous. However, before decoding an alphabet symbol, we need to check if
the next symbol is a `0` (*look-ahead*).
    
In `C₄` the code `01` can be decoded both as `ab` or as `c`

We will prove that for every decodable bit-string there exist an optimal
prefix-free code.

### Binary-Tree mapping

A prefix-free code can always be mapped to a binary tree by associating each
codeword to some node.

The mapping can be easily defined by using each codeword bit-string values to
represent a unique path from the root down to a leaf. The path is unique by
definition of prefix-free code (no codeword is prefix of another).

In practice, starting from the tree root, each codeword bits are read from left
to right. If a bit is `0` proceed to the current node left child, if is `1` we
proceed to the right child.

Once all codeword bits are read, the current node is bound to the codeword.

When all the codewords are processed, all the subtrees with nodes not associated
to any codeword are pruned.

### Kraft Inequality

**Lemma**. Given `n` integers `{l₁,..,lₙ}` with `lᵢ ≥ 1`, there exists a
prefix-free code with codewords lengths `{l₁,..,lₙ}` if and only if
`∑ᵢ 2^(-lᵢ) ≤ 1`.

*Proof Idea*.

First requirement is that each binary string with length `lᵢ` should be mapped
to a leaf in a binary tree. Since we can assign to each leaf a probability value
equal to `2^(-lᵢ)`. Can be easily seen that the thesis follows.

Note that, the smaller `lᵢ` is the bigger is `2^(-lᵢ)`, thus given that in an
optimal code `lᵢ = log₂(1/pᵢ)` then `2^-lᵢ = 2^-log₂(1/pᵢ) = pᵢ`.
For an optimal code, the lengths sum at most to `1`.
Once the optimal lengths were computed we can optionally assign a permutation,
but not reduce any of them without eventually increase another by the same
quantity.

*Examples*

Given the lengths `{1,2,3,3}` we try to map the lengths to a binary tree.
We draw a path of length `1` in the tree, and we prune what is below. Then
we take the second length, and we draw a path of length 2 using what is left of
the tree. Again we prune what is below. We proceed with the other lengths using
the same strategy. The Kraft's inequality sum is: `1/2 + 1/4 + 1/8 + 1/8 = 1`.

If we try with `{1,2,2,3}` we can see that is not possible to map it to a binary
tree and thus not possible to create a prefix free code. The Kraft's inequality
sum is `> 1`.

### McMillan Inequality

**Lemma**. If `{l₁,..,lₙ}` are the codewords' lengths for a non-ambiguous code
then `∑ᵢ 2^(-lᵢ) ≤ 1`.

**Corollary** McMillan inequality holds in both directions since if `∑ᵢ 2^(-lᵢ) ≤ 1`
then for Kraft's inequality there exist a prefix free code with the given 
code lengths, and these are unambiguous by construction.

**Corollary**. There is a decodable code with lengths of codewords `{l₁,..,lₙ}`
if and only if there exist a prefix free code with the same codewords lengths.

    ∃ Not-Ambiguous c₁(x) ↔ `∑ᵢ 2^(-lᵢ) ≤ 1` ↔ ∃ Prefix Free c₂(x)
                         (⬑ McMillan)       (⬑ Kraft)

## Code Average Length

The code average length is defined as:

    L(c) = ∑ᵢ pᵢ·|cᵢ| 

*Example*:

    P  = {0.9, 0.05, 0.025, 0.025}
    C₁ = {0, 111, 110, 101}  →  L(C₁) = 0.9·1 + 0.05·3 + ... = 1.2
    C₂ = {00, 01, 10, 11}    →  L(C₂) = 0.9·2 + 0.05·2 + ... = 2.0

    H(p) = 0.618

Since, as explained later, the average length of an optimal code is equal to
the entropy of the alphabet probability distribution, then we can strive for a
better codebook.

### Language Redundancy

In this context, redundancy is synonym of **compressibility**.

Imagine that an alphabet has `N` possible symbols. If each symbol is encoded
using a fixed number of bits `⌈log₂N⌉` (trivial encoding) instead of the optimal
encoding where on average we use `H(p)` bits per symbol. Then:

    Δ = ⌈log₂N⌉ - H(p) ≈ log₂N·(1 - H(p)/log₂N) = log₂N·R

    R := 1 - H(p)/log₂N 

`R` is defined as the language **redundancy** and has a value between `0` and `1`.

When `H(p)` is close to `log₂N` then `R` is close to `0` and thus the language
is not very compressible. Conversely, the more `H(p)` is smaller than `log₂N`
the more `R` is close to `1`.

For example for the English language `R ≈ 0.62`, thus it has a redundancy of
`60%` and with an optimal compression under optimal conditions the result can be
compressed down to the `40%` of the initial string.

### Source Coding Theorem 

The theorem (Shannon 1948) synthesizes all the results we've proven so far with
respect to optimal encoding.

**Theorem**. If `c` is an unambiguous code with codewords lengths
`L = {l₁,..,lₙ} ` then `L(c) ≥ H(p)`, with equality if and only if
`lᵢ = log₂(1/pᵢ)` for every `pᵢ > 0`.

*Proof*

If `lᵢ = log₂(1/pᵢ)` then `L(c) = ∑ᵢ pᵢ·log₂(1/pᵢ) = H(p)`.

If `lᵢ ≠ log₂(1/pᵢ)` then `lᵢ = log₂(2^lᵢ) = log₂(1/2^(-lᵢ))`.

When `∑ᵢ 2^(-lᵢ) = 1`, then `L` it can be interpreted as a probability
distribution `q` and thus `qᵢ = 2^(-lᵢ)`.

Then `lᵢ = log₂(1/qᵢ)` and thus for the linking identity:
`L(c) = ∑ᵢ pᵢ·log₂(1/qᵢ) = H(p||q) = H(p) + D(p||q)` 

Unfortunately, in general `2^(-lᵢ)` doesn't sum exactly to `1`.
To map it to a probability distribution we need to have the terms to sum to `1`.
Thus, we define:

    k = ∑ᵢ 2^(-lᵢ) and qᵢ = 2^(-lᵢ)/k  →  ∑ᵢ qᵢ = 1

The lengths can now be written as:

    lᵢ = log₂(1/2^(-lᵢ)) = log₂(1/(k·2^(-lᵢ)/k)) = log₂(1/(k·qᵢ))
       = log₂(1/qᵢ) + log₂(1/k)

The average code length is thus:

    L(c) = ∑ᵢ pᵢ·lᵢ = ∑ᵢ pᵢ·log₂(1/qᵢ) + ∑ᵢ pᵢ·log₂(1/k) = H(p||q) + log₂(1/k)

Since `c` is unambiguous, then for McMillan inequality:
`0 < k ≤ 1  →  1 ≤ 1/k  →  0 ≤ log₂(1/k)` 

    L(c) = H(p||q) + log₂(1/k) ≥ H(p||q)

Using the linking identity and the Gibbs inequality:

    L(c) ≥ H(p||q) = H(p) + D(p||q) ≥ H(p)

We have equality when:
1. `D(p||q) = 0  ↔  p = q`    
2. `log₂(1/k) = 0  ↔  k = 1  ↔  qᵢ = 2^(-lᵢ)` (always implied by the first)

∎

The theorem suggests that for an optimal non-ambiguous code each codeword length
should be `lᵢ = log₂(1/pᵢ)`.

The optimal values satisfy the McMillan inequality:

    ∑ᵢ 2^-lᵢ  = ∑ᵢ 2^(-log₂(1/pᵢ)) = 2^log₂(pᵢ) = ∑ᵢ pᵢ = 1

**Corollary** Given an optimal code `c` for a given distribution `p` then the
individual codeword lengths `lᵢ` are bounded by:

    log₂(1/pᵢ) ≤ lᵢ = ⌈log₂(1/pᵢ)⌉ < log₂(1/pᵢ) + 1

This potential extra bit per codeword may look innocuous but when considered
in the context of a big amount of data its may end-up having a non-negligible
impact.

`log₂(1/pᵢ) = ⌈log₂(1/pᵢ)⌉` if and only if `1/pᵢ` is a power of two.

Estimation for optimal `L(c)` with an alphabet of `N` elements:

    H(p) ≤ L(c) < H(p) + N

With `H(p) = L(c)` if and only if `log₂(1/pᵢ)` are integers.

Note that if a symbol `x` has `p(x) = 0`, we can assign to it an arbitrary
symbol as it will never be encoded.


## Practical Codes Design

### Shannon-Fano Coding

Given the probability distribution of the symbols `p = {p₁,..,pₙ}`, we set the
length of each symbol `xᵢ` to `lᵢ = ⌈log₂(1/pᵢ)⌉`.

The lengths are then used to construct the binary tree associated with the
prefix-free encoding.

Problems with this approach:
- The *true* `pᵢ` values are unknown, we know just the approximations given by
  the relative frequencies. Thus, `p` can't be used to create an optimal and
  generic code for all the possible strings.
- In general, `⌈log₂(1/pᵢ)⌉ ≠ log₂(1/pᵢ)`, thus we are subject to the extra bit
  penalty described in the previous paragraph.
- Sub-optimal encoding of symbols with very low probabilities (see the example).

*Optimal* encoding example:

    p = {1/2, 1/4, 1/8, 1/8}
    l = {1, 2, 3, 3}
    C = {0, 10, 110, 111}

Note that in this case `⌈log₂(1/pᵢ)⌉ = log₂(1/pᵢ)` and thus `L(c) = H(p)`.

*Sub-optimal* encoding example:

    p = {1/2, 1/2 - ε, ε}, with ε = 2^-5

    l₂ = ⌈log₂(1/(1/2 - ε))⌉ = ⌈1.09⌉ = 2
    l₃ = log₂(1/ε) = 5

    l = {1, 2, 5}
    C = {0, 10, 11000 }

This code is evidently suboptimal since a prefix free code for such an alphabet
can be constructed with `l = {1, 2, 2}`. This is a case where `H(p) < L(c)`.

### Huffman Coding

The prefix-free tree is progressively constructed *bottom-up* by first setting
the elements probabilities as tree leaves.

The two parent-less nodes with smaller probabilities are merged to create the
parent node with probability equal to the sum of the children's probabilities.

The procedure is iterated until we reach the root.

The resulting tree defines the associated prefix-free code.

*Example*.

Given `p = {0.025, 0.025, 0.05, 0.9}`.
1. Sort the probabilities: `p₀ = {0.025, 0.025, 0.05, 0.9}`.
2. Merge the two elements with smaller probabilities `{0.025, 0.025}` to create
   a new node with associated probability `0.05`.
3. Update the probabilities set `p₁ = {0.05, 0.05, 0.9}`.
3. Go to step 2 until we are left with a set with one single element `pₙ = {1}`.

```
    (0.025)-+
    (0.025)-+-(0.05)-+
    (0.05)-----------+-(0.1)-+
    (0.9)--------------------+-(1.0)
```

**Theorem**. The Huffman algorithm constructs an optimal prefix-free code.

The only practical problem is that `p` can be unknown.

### Lampel-Ziv Coding

This algorithm is the foundation of the algorithm used by *zip/gzip* application
and of *Deflate* algorithm used by *zlib* (LZ77 combined with Huffman codes).

LZ algorithm is not optimal in terms of minimizing the average codeword length
for a given probability distribution of source symbols. Instead, it is
asymptotically optimal in terms of compression ratio for long sequences of data
where the statistical properties are not known in advance or are changing.

The algorithm works by scanning the input data from left to right and building
a **dictionary** of encountered substrings. When a repeated substring is found,
the algorithm outputs a pair of values: a known substring reference and a new
letter used to create the encountered new substring.

Can be proved that the number of bits used by LZ77 tends towards the empirical
entropy of the sequence.

In practice the dictionary is a table with the following columns:
- *index*: number used to reference back to a row instance;
- *reference*: number pointing to another row whose substring is used as prefix;
- *symbol*: symbol introduced by the substring.

Example:

    "AABABBBABAABABBBABBABB"

The first block 0 is the empty block

      A AB ABB B ABA ABAB BB ABBA BB

      idx | ref | sym      substring
     -----|-----|-----
       1  |  0  |  A        → A
       2  |  1  |  B        → AB
       3  |  2  |  B        → ABB
       4  |  0  |  B        → B
       5  |  2  |  A        → ABA
       6  |  5  |  B        → ABAB
       7  |  4  |  B        → BB
       8  |  3  |  A        → ABBA
       9  |  4  |  B        → BB

Note that the last block is equal to block 7.

During encoding references and the letters are converted to binary.

The number of bits to encode a reference is driven by the number of references
already encoded. We start using `n+1` bits after we encoded `2ⁿ` references.

In the following example, the binary string outside the parentheses is the
binary representation of the reference while the binary digit within the
parentheses represents the character: `A = 0` and `B = 1`.

    0(0) 1(1) 10(1) 00(1) 010(0) 101(1) 100(1) 011(0) 0100(1)

Decoding is about reconstructing the dictionary from the binary string and
recovery of the substrings.

In this specific example there is no compression, but in a longer text with more
redundancy there are a lot of substrings that repeats and a repeated substring
is then merely represented as a pointer to some other block.
