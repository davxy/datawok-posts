+++
title = "Cyclic Groups"
date = "2023-08-23"
modified = "2023-08-23"
tags = ['cryptography','number-theory']
toc = true
+++

A cyclic group is a type of algebraic structure in abstract algebra which
definition is based on the concept of a generator and the operations within
the group.

Cyclic groups provide the mathematical foundation for many cryptographic
protocols and schemes. The hardness of certain mathematical problems in cyclic
groups, such as the discrete logarithm problem, forms the basis for the security
of these cryptographic systems.


## Cyclic Groups and Generators

**Definition**. A group `G` is said to be **cyclic** if there exists an element
`g ∈ G`, called a generator, such that every element of `G` can be obtained by
repeatedly applying the group operation to `g`.

Given a group `G` and a value `α ∈ G`, the **order** of `α` is defined as:

    ord(α) := min{i ∈ Zn} such that αⁱ = e

With `e` the group identity and `αⁱ` the repeated application of the group
operation to `α`.

The number `g ∈ G` is a **generator** of `G` if `ord(g) = |G|`.

A generator is also called a **primitive root** for a group.

**Proposition**. If `g` is a generator of `G` then `{g¹, .. , g𐞶ᴳ𐞶}` are
all distinct. With each `gⁱ` taken modulo `|G|`.

*Proof*

For two exponents `1 < i < j ≤ |G|`, we set `r = j - i < |G|`. If `gⁱ ≡ gʲ` then
`gⁱ ≡ gⁱ⁺ʳ ≡ gⁱ·gʳ`. Given that `g` is invertible then we can cancel `gⁱ` on
both sides leaving with `1 ≡ gʳ`. But then `g` is not a generator as `r < |G|`.

∎

In this discussion we're going to mostly focus on groups
`Zn* = { x: gcd(x,n) = 1 }` defined by the product modulo `n` group operation.

*Example*. Given `p = 19` (a prime) we know that `Zp*` is a group with respect
to the product modulo `p` and that `|Zp*| = 18`

    α = 7  →  7¹ mod 19 = 7, ..., 7^³  mod 19 = 1  →  ord(7) = 3 
    α = 2  →  2¹ mod 19 = 2, ..., 2^¹⁸ mod 19 = 1  →  ord(2) = 18

For Euler's theorem, if `(α,n) = 1` then `αᵠⁿ = 1 (mod n)`, however the order of
an element `α` can be smaller that `φ(n)`.

Can be proven that if `p` is prime then it has at least one generator `g` able
to generate the whole set `Zp*`, that is `∃ g ∈ Zp*: ord(g) = p-1`.

Once we found a generator `g` for an arbitrary group `G`, all the other generators are
easily identified.

Give a generator `g` for a group `G` with `|G| = n`, the order of `gᵐ` is equal
to `n/(m,n)` (this is easily provable). Follows that `gᵐ` is another generator
iff `(m,n) = 1`.

As a consequence, the number of different generator in `|G|` is `φ(n)`.

Furthermore, using the
[*Lagrange theorem*](https://en.wikipedia.org/wiki/Lagrange%27s_theorem_(group_theory))
we can prove that if a group `G` has prime order `p` then any element of `G` is a
generator.

### Lagrange theorem

#### Cosets

A subgroup `H` of a group `G` may be used to decompose the underlying set of `G` into
disjoint, equal-size subsets called **cosets**.

If `a ∈ G` then `a·H` is the left coset determined by applying the group
operation to each element of `H`. Note that `a·H` is not a subgroup as it is
missing the identity element.

There are left cosets and right cosets. Cosets have the same number of elements
as does `H`. Furthermore, `H` itself is both a left coset and a right coset.

The number of left cosets of `H` in `G` is equal to the number of right cosets
of `H` in `G`. This value is called the **index** of `H` in `G`, written as
`[G:H]`.

**Proposition**. Any coset `a·H` has the same number of elements of `H`.

*Proof*. We can easily define a bijective function from `a·H` to `H` using
the inverse of `a ∈ H`.

**Proposition**. Two cosets are either disjoint or equal.

*Proof*. Given two cosets `a·H` and `b·H`. If `c = a·hᵢ = b·hⱼ`, then for any
`a·h' ∈ a·H` given that `H` is a group we can find a `t` such that `h' = t·hᵢ`.
But then `a·h' = a·t·hᵢ = b·t·hⱼ` and thus `a·H ⊆ b·H`. For the same argument we
prove `b·H ⊆ a·H` and thus `a·H = b·H`.

**Lagrange Theorem**. For any finite group `|G|`, the number of elements of
every subgroup of `G` divides the order of `G`.

*Proof*. Let G have `n` elements and `H` have `m` elements.
`G` can be written as the union of the cosets `G = a₁·H ∪ .. ∪ aₙ·H`.
After removal of any duplicated coset, we are left with `G = a₁·H ∪ .. ∪ aₛ·H`
with `s ≤ n`. Given that each coset has the same number of elements of `H`
we have that `n = s·c`, with `c` the number of cosets.
