+++
title = "Cryptographic Systems Design"
date = "2023-11-18"
modified = "2023-11-18"
tags = ["cryptography", "draft"]
draft = true
+++

All modern cryptographic schemes follow the **Kerckhoffs's principle**. The
principle asserts that a scheme should be secure even if everything about the
system, except for the key, is of public knowledge.

The opposite (obsolete) approach to secure systems design is the so-called
*security by obscurity*. Where everything about the system is confidential.

An openly designed algorithm is subject to the **public scrutiny** where the
best minds in the field tries to attack the scheme with any available means,
a discipline called **cryptanalysis**.

Another well known principle highlighting the importance of public scrutiny
is the so-called [**Schneier's Law**](https://www.schneier.com/blog/archives/2011/04/schneiers_law.html)
 which asserts that anyone, from the most clueless amateur to the best
cryptographer, can create a scheme he can't break.

Following well established design principles allows designing systems that are
secure against the worst case scenario which in practice this is often the case.

### Cryptanalysis

Analysis over the ciphertext generally to gather some information about the
plaintext or the key.

Classification:
- **Ciphertext only**: one or more ciphertext built with the same key.
- **Known plaintext**: one or more plaintext/ciphertext couples obtained with
  the same key.
- **Chosen plaintext**: like known plaintext, but the attacker can choose the
  plaintext and can encrypt it without knowing the secret key.
  With asymmetric cryptography this scenario always applies;
- **Chosen ciphertext**: like chosen plaintext, but the attacker can also choose
  the ciphertext and can decrypt it without knowing the secret key.
  Example: the attacker steals a tamper-proof smartcard. It can encrypt/decrypt
  data without knowing the secret key.

Examples of analysis techniques:
- Ciphertext only: exhaustive search.
- Known plaintext: DES linear cryptanalysis.
- Chosen plaintext: DES differential cryptanalysis.
- Chosen ciphertext: smart card side channel attack.


## Hard Problems

Obviously a secure cryptosystem should be *hard* to break.

But what it means for a problem to be hard? Two interpretations:
- **Unconditionally** hard
- **Computationally** hard

### Unconditional Security

A message in the plaintext set `M` is encrypted as a string in the ciphertext
set `C`.

The letters composing the messages in `M` are subject to a known and public
probability distribution `p` driven by the language of choice (e.g. in English
the letter 'e' is the most frequent one). `M` can thus be considered a random
variable.

We say that our system has **perfect secrecy** property or that it is
**unconditionally secure** according to *Shannon* if:

    p(M = m | C = c) = p(M = m)

That is, the observation of the ciphertext doesn't leak any information about
the plaintext. In other words, `M` and `C` are independent variables.

Using entropy notation:

    H(M|C) = H(M)

The most popular unconditionally secure cipher is the **one-time pad**.

### Computationally Hard

To break a computationally hard crypto-system an attacker should use an amount
of computation resources so huge that for him is not convenient to break it
while the information is still relevant.

It is an empirical estimation, and should always be considered that:
- what looks impossible today may be not infeasible in few years (e.g. DES in
  1976 bad estimations);
- there is always the possibility of some breakthrough in cryptanalysis that is
  keep secret.

Breaking a computationally hard crypto system is computationally equivalent to
solve the worst cast of a NP-complete problem.

For NP-complete problems, it's not required that all problem's instances
are exponentially hard to solve. What matters is that there exist at least
one instance (the worst cases) that which requires a super-polynomial (e.g.
exponential) time with respect to the size of the input.

An example of a NP-complete problem is the *knapsack problem*. Even though the
majority of this problem instances are polynomial, there are instances that
are exponential.

Thus, the generic requirement of NP-completeness doesn't satisfy what we require
from a computationally secure crypto system which requires that **all** the
problem instances are complex. Often this is obtained by carefully restricting
the general problem parameters such that the constrained problem is hard for
all the valid instances.

Failing to properly constrain a problem which is then used to construct a crypto
system will leave an attack surface for cryptanalysts which will eventually
discover the security hole.
