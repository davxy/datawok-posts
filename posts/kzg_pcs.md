+++
title = "KZG Polynomial Commitment Scheme"
date = "2024-09-09"
modified = "2024-09-09"
tags = ["cryptography", "scheme"]
toc = true
+++

A polynomial commitment scheme allows a prover to commit to a polynomial and
later prove evaluations of the polynomial at specific points, without revealing
the full polynomial. It ensures that the prover cannot change the polynomial
after committing, and the verifier can check the correctness of the evaluations
with high efficiency.

Formally, given a field $F$, for $x \in F$ and a secret polynomial
$f \in F[x]^{\le d}$ (i.e. $deg(f) \le d$), the prover wants to convince the verifier
that $f(u) = v$, for some $u \in F$.

The verifier is only given $(d, com_f, u, v)$, where $com_f$ is a commitment to $f$.

There are several techniques to construct the scheme, based on:
- **Bilinear groups**: KZG'10 (requires trusted setup), Dory'20, etc.
- **Hash functions**: FRI (Fast Reed Solomon) based schemes (longer proofs);
- **Regular elliptic curves**: Bulletproofs (short proofs, long verifier $O(d)$);
- **Unknown order groups**: Dank'20.

In this post we'll explore the KZG polynomial commitment scheme (PCS for
short), which were introduced by Kate, Zaverucha, and Goldberg in 2010
([KZG'10](https://iacr.org/archive/asiacrypt2010/6477178/6477178.pdf)).

The scheme utilizes bilinear pairings to verify the correctness of the proofs,
thus it is required to use of some pairing-friendly curve like BLS12-381, BN254,
or similar.

The basic version of the scheme is designed for univariate polynomials in
the ring $F[X]^{\leq d}$, but it can be extended to support commitments to
multivariate polynomials with $k$ variables.

## Operations and Notation

- Setup: $(\lambda, F) \mapsto SRS$
  - Global parameters setup for a group $F$ and security parameter $\lambda$.
  - In this context, global parameters are also known as **SRS** (Structured Reference String).

- Commit: $f \mapsto com_f$
  - Polynomial $f$ commitment

- Open: $(gp,f,u) \mapsto (v,\pi)$
  - Evaluation of $f$ at point $u$, returns $v$ and an associated proof $π$

- Verify: $(gp,com_f,u,v,π) \mapsto \top/\bot$
  - Verification if $f(u) = u$ using the $com_f$ and $π$.

- Pairing $e: G_1 \times G_2 \to G_t$

- $G_1$ and $G_2$ are prime order groups.
- $|G_1| = |G_2| = p$, for some prime $p$. 
- $F = F_p$
- $\omega$ generator of the evaluation domain with order $d$.

### Setup

Let $g_1 \in G_1$

- Sample a random scalar $\tau \in F$
- Compute powers of tau for $g_1 \in G_1$ and $g_2 \in G_2$
  - $SRS_{g_1} = (g_1, \tau  g_1, 𝜏^2 g_1, \dots , \tau^d g_1)$;
  - $SRS_{g_2} = (g_2, \tau  g_2)$;
  - $SRS$ set as the concatenation of $SRS_{g_1}$ and $SRS_{g_2}$.
- Delete $\tau$ (also known as *toxic waste*)

### Commit

Let $f(x) = a_0 + a_1 x + a_2 x^2 .. + a_d x^d$, evaluate $f$ at the secret
point $\tau$ by using the $SRS$.

$$\begin{aligned}
    com_f &= f(\tau) \cdot g_1 \\
          &= a_0 \cdot g_1 + a_1 \cdot \tau g_1 + a_2 \cdot \tau^2 g_1 + \dots + a_d \cdot \tau^d g_1 \\
          &= a_0 \cdot SRS_0 + a_1 \cdot SRS_1 + a_2 \cdot SRS_2 + \dots + a_d \cdot SRS_d
\end{aligned}$$

Note that:
- the $SRS$ allows to evaluate the polynomial $f$ "in the exponent" of $g_1$ at
  the unknown value $𝜏$.
- $com_f$ is a single group element in $G_1$
- KZG is a **binding commitment** but not hiding as prover reveals $f(𝜏)·g$.

### Open

For an arbitrary $u \in F$, given that $u$ is a root of $f(x) - f(u)$, then for
some $q(x) \in F[x]^{< d}$ we have:

$$f(x) - f(u) = (x-u)·q(x)$$

The prover computes $q(x)$ and evaluates it at $𝜏$:
$$π = com_q = q(𝜏)·g_1$$

Note that:
- Proving is expensive as $q(x)$ must be evaluated in the exponent $𝜏$, which
  depends on degree $d$.
- The verifier has access to the committed polynomial value only at $𝜏$.

### Verify

Verification relies on [SZDL lemma](https://en.wikipedia.org/wiki/Schwartz%E2%80%93Zippel_lemma) corollary.
Two polynomials are evaluated at the same point ($𝜏$). If they match, then
they are equal with very high probability as long as the two have a bounded degree.

If the prover is honest we have:
$com_f = f(𝜏)·g_1$, $π = q(𝜏)·g_1$, $v = f(u)$

Check the equation at $𝜏$: $[f(𝜏)-f(u)]·g_1 = [q(𝜏)·(𝜏-u)]·g_1$

The verifier evaluates $f(𝜏) - f(u) = (𝜏-u)·q(𝜏)$ "in the exponent":

$$(f(𝜏)-f(u))·g_1 = (q(𝜏)·(𝜏-u))·g_1$$

As the operation in the right-hand side requires the multiplication of two encrypted
values (i.e. $q(𝜏)$ and $(𝜏-u)$), pairings are used.

Verification equation, for $g_2 \in G_2$:

$$e((f(𝜏)-f(u))·g_1, g_2) = e(q(𝜏)·g_1, (𝜏-u)·g_2)$$
$$e(f(𝜏)·g_1 - f(u)·g_1, g_2) = e(q(𝜏)·g_1, 𝜏·g_2 -u·g_2)$$

Which must be equivalent to:

$$e(com_f - v·g_1, g_2) = e(π, 𝜏·g_2 - u·g_2)$$

Note that for the pairing the verifier only needs:
- $SRS_{g_1, 0}$: the first parameter of the powers of tau in $G_1$ (to compute $v·g_1$).
- $SRS_{g_2, 0}$ and $SRS_{g_2, 1}$: the first and second parameters of the
  powers of tau in $G_2$, namely $g_2$ and $τ g_2$.
    
The proof size is independent of the degree $d$, it is constant size as it is a
single point $\pi \in G_1$.

## Proofs Aggregation

KZG supports very efficient batch proofs.

Suppose verifier has commitments to $n$ different polys: $f_1$, .. , $f_n$.
The prover wants to prove $f_i(u_j) = v_{i,j}$ for $i = 1 \dots n$, $j ∈ 1 \dots m$,
with $i$ and $j$ the polynomials and evaluation points indices, respectively.

E.g. if I have 5 poly and 10 eval points. The eval proofs are 50.
These can be aggregated in one single proof.

TODO: example

### Multi-point proof generation

Prover has some polynomial $f ∈ F[X]^{\le d}$.

Let $\Omega \subseteq F$ and $|\Omega| = d$

Suppose prover needs a KZG proof $π_a ∈ G$ for all $a ∈ Ω$.

Naively we can do this one at a time. Each proof takes $O(d)$ time to generate.
Thus it will take $O(d^2)$ time.

**Feist-Khovratovich (FK)** algorithm

If $\Omega$ is a multiplicative subgroup: time $O(d·log(d))$ otherwise time
$O(d·log^2(d))$

## Linear Time Commitment

Time for the prover to commit to a polynomial is linear in the degree to the
polynomial. As $f(𝜏)$ must be evaluated (sum/mul of $n$ monomials).

**Standard representation (Coefficients)**:

$$f(x) = a_0 + a_1·x + \dots + a_d·x^d$$

**Point-value representation**:

$$(b_0, f(b_0)), \dots , (b_d, f(b_d))$$

with ${b_i}$ the chosen domain basis. $d+1$ points to encode a poly of degree $d$.

Polynomial in standard representation can be always recovered using polynomial
interpolation.

Given with the point-value representation, a naive way to compute
$com_f$ is to first convert it into the standard representation
to find the coefficients $a_0, \dots, a_d$ and then proceed as usual.

Converting from point-value representation into coefficient representation
takes time $O(d·log(d))$ using **Number Theory Transform** (NTT) (closely
related to FFT).

A better approach to compute $com_f$ is to use Lagrange's interpolation:
$f(𝜏) = ∑_i f(b_i) λ_i(𝜏)$, with $λ_i(𝜏)$ the Lagrange basis polynomial
and $\{b_i\}$ the evaluation domain.

The $SRS$ is given in Lagrange form:

$$SRS' = (H_0 = λ_0(𝜏)·g_1, ..., H_d = λ_d(𝜏)·g_1)$$

The mapping between $SRS$ and $SRS'$ is a linear transformation ([example](https://github.com/w3f/fflonk/blob/1e854f35e9a65d08b11a86291405cdc95baa0a35/src/pcs/kzg/lagrange.rs#L44))

In Lagrangian form the commitment can be computed as:

$$\begin{aligned}
    com_f = f(𝜏)·g_1 &= f(b_0)·H_0 + \dots + f(b_d)·H_d \\
          &= [f(b_0)·λ_0(𝜏) + \dots + f(b_d)·λ_d(𝜏)] · g_1
\end{aligned}$$

Note that $\{H_i\}$ doesn't depend on the polynomial $f$.

As this method runs in $O(d)$, it is very common to find the global parameters
in Lagrange basis rather than standard basis.

## Toy Example

Curve definition:

$$E: y^2 = x^3 + 3$$

defined over $\mathbb{F}_{101}$, which has a subgroup of prime order $17$.
So our "working" field is $F = \mathbb{F}_{17}$, where we be used to construct
a polynomial capable to can commit to up to $17$ values ($d = 16$).


**Fields and Curves Definitions**

```python
# Base field
F101 = GF(101)
# Pairing friendly curve with subgroup with prime order 17
E_G1 = EllipticCurve([F101(0), F101(3)])

# Extension field over the finite field F101 defined by
# the irreducible polynomial is U^2 + 2
FU.<U> = F101[] # This is required to define U
F101_ext.<u> = F101.extension(U^2 + 2)
# Extend the base field of E from F101 to Fu, the quadratic extension of F101
E_G2 = E_G1.base_extend(F101_ext)

# G1 prime order subgroup generator (ord = 17)
g1 = E_G1(1, 2)
# G2 prime order subgroup generator (ord = 17)
g2 = E_G2(36, 31*u)

assert g1.order() == 17
assert g2.order() == 17

# Scalar field with same size of prime order groups generated by g1 and g2
F17 = GF(17)
```

**Construct SRS**

```python
# Random tau
tau = F17.random_element()

# Powers of tau for g1 and g2
srs_g1 = [tau^i * g1 for i in range(13)]
srs_g2 = [tau^i * g2 for i in range(2)]
```

**Polynomial Construction**

- Values to commit: $v = (11, 2, 7, 8)$
- Evaluation domain generator: $\omega = 13$
- Evaluation domain: $D = \{\omega^0 = 1, \omega^1 = 13, \omega^2 = 16, \omega^3 = 4\}$
- Points: $\{ (1, 11), (13, 2), (16, 7), (4, 8) \}$
- Polynomial: $f(x) = 7 x^3 + 2 x^2 + 12x + 7$

```python
# Values we want to commit to
evals = [11, 2, 7, 8]

# Generator for a big enough domain (4 in this example)
omega = F17(13);
assert len(evals) <= omega.multiplicative_order()
points = [(omega^i, evals[i]) for i in range(len(evals))]

# Lagrange interpolation
R.<X> = F17[]
f = R.lagrange_polynomial(points)
print(f.coefficients(sparse=False))
```

**Proving**

```python
# Commit a polynomial 'f' using the provided G1 SRS
def commit(f, g1_srs):
    coefficients = f.coefficients(sparse=False)
    return sum(c * s for c, s in zip(coefficients, g1_srs))

# Prover: commits values polynomial
com_f = kzg_commit(f, srs_g1)

# Verifier: Random evaluation point.
# Use Fiat-Shamir for a non-interactive scheme
u = GF(g1.order()).random_element()

# Prover: compute the value
v = f(u)

# Prover: quotient polynomial
q, r = (f - v).quo_rem(R(X - u))
assert r == 0
proof = kzg_commit(q, srs_g1)
```

**Verification**

```python
# Verifier: proof verify (has access to: com_f, u, v, proof=com_q)
P = E_G2(com_f - v*srs_g1[0])
Q = srs_g2[0]
lhs = P.tate_pairing(Q, P.order(), 2) # order = 17, embedding_degree = 2

P = E_G2(proof)
Q =  srs_g2[1] - u*srs_g2[0]
rhs = P.tate_pairing(Q, P.order(), 2)

assert lhs == rhs
```

## Applications

### Verkle Trees

Given a vector $(v_1 \dots v_k) ∈ F^k$, prover constructs a polynomial $f$
such that $f(i) = v_i$ for $i = 1 \dots k$ and commits to $f$ ($com_f$).

Aggregation can be leveraged to share compact proofs of presence for multiple
points. Much shorter that Merkle proofs but less efficient if the vector
is frequently updated.

### ZK-SNARKS

Together with a compatible IOP, can be used to construct SNARKS.

- [APK Proof](https://medium.com/web3foundation/apk-proofs-by-hand-and-sage-3f5feb3fcca4)
- [Ring Proof](https://github.com/w3f/ring-proof/)

## References

- [ZKP MOOC course section 6](https://youtu.be/HdwMtrXLLWk?si=-SoSVPUqhmni_iIO)
- [KZG'10 paper](https://iacr.org/archive/asiacrypt2010/6477178/6477178.pdf)
