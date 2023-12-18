+++
title = "X.800 OSI Standard"
date = "2023-11-18"
modified = "2023-11-18"
tags = ["standards", "security", "draft"]
draft = true
+++

X.800 is an OSI standard which defines the basic concepts and principles for
network security in the context of the OSI reference model.

In particular, it defines:
- **services**: security features we want to provide;
- **mechanisms**: techniques used to implement the services;
- **attacks**: threats and actions aimed at disrupting the services.

## Services

- **Confidentiality**: information is kept private and protected from
  unauthorized access.
- **Integrity**: ensures the accuracy and reliability of data.
- **Authentication**:
  - *data origin* authentication: message origin is authenticated (E2E);
  - *peer entity* authentication: identity of the sender is authenticated (P2P).
- **Non-Repudiation**: provides accountability by giving an evidence that an
  action has been carried out by a specific actor.
- **Access Control**: policies that control access to system resources based on
  the identity of users and the permissions they have.

**Confidentiality** differs from **privacy** service. The former refers to the
protection of sensitive information from unauthorized disclosure. Privacy on
the other hand refers to an individual's right to control their information,
including data that is not necessarily considered sensitive or confidential. A
service which guarantees privacy allows data sharing in a way where not strictly
required details cannot be inferred.

  | Security property             | Violation example              |
  |-------------------------------|--------------------------------|
  | Confidentiality               | Sensitive information read     |
  | Integrity                     | Message tampering              |
  | Authentication                | Impersonation                  |
  | Non-repudiation               | Denial of responsibility       |
  | Access control                | Restricted area access         |
  | Privacy (no X.800)            | Confidential data inference    |
  | Quality of service (no X.800) | Distributed DoS                |

The first three together are often dubbed *CIA triad*.

The last three are generally considered *system security* issues.


## Mechanisms

Mechanisms to implement the security services mostly leverage cryptographic
codes and protocols.

The focus is on **prevent**, **detect** and **correct** faults caused by
security violations which involve some form of malicious actor.

Even though often is not possible to prevent an attack, a good detection system
allows a recovery via some correction action.

A **code** is come kind of data transformation provided by some low level
cryptographic primitive. Examples are:
- encryption
- secure hash
- message authentication codes
- digital-signatures.

A **protocol** is an algorithm which provide a higher level cryptographic
scheme. Examples are:
- Key agreement
- Key exchange
- Peer authentication
- Zero-knowledge proofs

Cryptographic primitives using some kind of secret key can be classified in:
- **symmetric**: one shared secret key;
- **asymmetric**: one key is public and one is secret.

None of the two families is perfect.

The major problem with symmetric schemes is the distribution of the shared key.

With asymmetric schemes there is one publicly available key to encrypt (or sign)
and one secret key to decrypt (or verify). Follows that key distribution is
easier, however:
- asymmetric primitives are math heavy and thus are generally orders of
  magnitude slower than shared key schemes with the same level of security;
- we may require some form of certification for the distributed public keys.

In practice, to provide confidentiality services, often we use a hybrid approach
with asymmetric schemes used to distribute or agree on a shared key to be used
by a fast symmetric algorithm.


## Attacks

Roughly attacks can be divided in passive and active.

### Passive attacks

Characterized by the unauthorized interception of information. The attacker aims
to obtain sensitive information without altering the data.

Characteristics:
- hard to detect
- easy to prevent

Mostly carried out against confidentiality.

Examples
- Eavesdropping: listening in on communications to capture sensitive information.
- Traffic analysis: analyzing patterns and characteristics of network traffic.

### Active attacks

Involve the alteration of data. The attacker seeks to modify the information,
disrupt communication, or gain unauthorized access to systems.

Characteristics:
- Easy to detect
- Hard to prevent.

Mostly carried out against integrity, authentication and non-repudiation.

Examples:
- Data modification: changing the content of a message.
- Denial of Service (DoS): overloading the system to make it unavailable to users.
- Masquerading: pretending to be an authorized user or system.


## Cryptographic Systems Design

All modern cryptographic schemes follow the **Kerckhoffs's principle**. The
principle asserts that a scheme should be secure even if everything about the
system, except the key, is public knowledge.

The opposite (obsolete) approach to secure systems design is the so-called
*security by obscurity*. Where everything about the system is confidential.

An openly designed algorithm is subject to the **public scrutiny** where the
best minds in the field tries to attack the scheme with any available means,
a discipline called **cryptanalysis**.

Another well known principle highlighting the importance of public scrutiny
is the so-called **Schneier's Law** which asserts that anyone, from the most
clueless amateur to the best cryptographer, can create a scheme he can't break.

Following well established design principles allows designing systems that are
secure against the worst case scenario and in practice this is often the case.

### Cryptanalysis

Analysis over the ciphertext generally to gather some information about the
plaintext or the key.

Classification:
- **Ciphertext only**: one or more ciphertext obtained with the same key
- **Known plaintext**: one or more plaintext/ciphertext couples obtained with
  the same key.
- **Chosen plaintext**: like known plaintext, but the attacker can choose the
  plaintext and can encrypt it without knowing the secret key.
  With asymmetric cryptography this scenario always applies.
- **Chosen ciphertext**: like chosen plaintext, but the attacker can also choose
  the ciphertext and can decrypt it without knowing the secret key.
  Example: the attacker steals a tamper-proof smartcard. It can encrypt/decrypt
  data without knowing the secret key.

Examples of analysis techniques:
- Ciphertext only: exhaustive search (aka brute force).
- Known plaintext: DES linear cryptanalysis.
- Chosen plaintext: DES differential cryptanalysis.
- Chosen ciphertext: smart card side channel attack.


## Hard Problems

Obviously a secure cryptosystem should be *hard* to break.

But what it means for a problem to be hard? Two interpretations:
- **Unconditionally secure**
- **Computationally hard**

### Unconditional Security

A message in the plaintext set `M` is encrypted as a string in the ciphertext
set `C`.

The letters composing the messages in `M` are subject to a probability
distribution `p` driven by the language of choice (e.g. in English the letter
'e' is the most frequent one). `M` can thus be considered a random variable.

Following the *Kerckhoff's principle*, the distribution `p` is known and public.

We say that our system has **perfect secrecy** property or that it is
**unconditionally secure** according to Shannon if:

    p(M = m | C = c) = p(M = m)

That is, the observation of the ciphertext doesn't leak any information about
the plaintext. In other words, `M` and `C` are independent variables.

Using entropy notation:

    H(M|C) = H(M)

The most popular example of unconditionally secure cipher is **one-time pad**.

### Computationally Hard

To break the crypto-system an attacker should use an amount of computation
resources so huge that for him is not convenient to break it while the
information is still relevant.

It is an empirical estimation, and should be considered that:
- What looks like impossible today maybe is not infeasible in few years (e.g.
  DES in 1976 bad estimations).
- There is always the possibility of some breakthrough in cryptanalysis that is
  keep secret.

Breaking a computationally hard crypto system is computationally equivalent to
solve the worst cast of a NP hard problem.

For NP problems, it's not required that all problem instances are hard to
solve. What matters is that there exist instances (the worst cases) that are
hard to solve and require exponential time in the size of the input. In other
words, the problem is considered hard in the worst-case scenario.

An example of a NP-complete problem is the *knapsack problem*. Even though the
majority of this problem instances are polynomial, there are sporadic instances
that are exponential.

If there exists at least one instance of a problem that is difficult to solve
(requiring exponential time) as the size of the input grows, then the problem is
classified as NP-hard or NP-complete. This doesn't mean that every instance is
necessarily hard; there might be instances that are easy to solve.

Thus, if we want to be more precise, the generic definitions of complexity
doesn't satisfy what we require from a computationally secure crypto scheme.
Here we require that **all** the problem instances are complex. Often this
is obtained by carefully restricting the general problem parameters such that
the problem is difficult in the average case as well.


## References

- [X.800](https://www.itu.int/rec/T-REC-X.800/_page.print)
- [Schneier's Law](https://www.schneier.com/blog/archives/2011/04/schneiers_law.html)
