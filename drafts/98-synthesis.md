+++
title = "Synthesis"
date = ""
tags = []
draft = true
+++

# Synthesis

## Network Security Intro

- Raw channels are: limited, unsecure, unreliable
- Desirable channel properties:
  - economy → compression codes
  - security → cryptographic codes
  - reliability → error detection and correction codes
- Code definition: a reversible function to transform a message
- Main disciplines: computer security and information theory
- Computer Security: prevent, detect, correct security related faults
- x800 OSI standard: defines services, attacks and mechanisms
  - services: CIA; attacks: active/passive, mechanisms: codes and protocols

## Ciphers Security

- Design principles: Kerckhoff's principle, Schneier's law
- Cryptanalysis: breaking ciphers
- Crypto-analysis techniques: ciphertext only, known plaintext, chosen plaintext, chosen ciphertext.
- Hard problem: unconditionally secure (statistically impossible) vs computationally hard.
- Perfect-secrecy: p(M|C) = p(M)
- One-time pad perfect-secrecty and key reuse (crib-dragging)

- Shared Key Cipher defined as (P, C, K, E, D)

## Classic Ciphers

- Monoalphabetic and Polyalphabetic substitution ciphers
- Shift cipher: monoalphabetic, vulnerable to freq. analysis
- Vigenere cipher: polyalphabetic, vulnerable to freq. analysis
- Substitution cipher: substitution is arbitrary (keyspace too big)
- Affine cipher
- Transposition cipher
- Hill cipher: block cipher introducing diffusion principle (vulnerable to known plaintext)
- Lesson learned: a strong cipher has diffusion and confusion

## Enigma

- Components: keyboard, plugboard, rotors, reflector, lampboard.
- Keyspace size computation
- Components properties (e.g. involutions, no fixed points)
- Attack: a kind of known plaintext attack.
  - Cribs

## Block Ciphers

- Key length issue with generic substitution
- SPN principles from Shannon
- Feistel design for SPN
  - relation to Shannon confusion and diffusion
- DES F function and s-box:
  - Strict Avalanche Criterion (SAC)
  - Bit Independence Criterion (BIC)

## Shared Key management

- Two problems: storage & distribution
- Traffic security requirements:
  - confidentiality: link and e2e
  - authentication: data origin or peer entity
- Key distribution: in person, kdc, pki
- Needham-Schroeder protocol (KDC) for key agreement and mutual auth

## Perfect Secrecy Introduction

- Shannon definition
  - Prof. len(k) ≥ len(m)  (Proof???)
  - Prop: |K| ≥ |M|
- One-time pad
  - Proof of perfect secrecy
- Latin squares
- Project Verona: not random keys

## Public Key Introduction

- Definition of key set and family of injective functions as `f_pub`
- Computational requirements
- One-way and one-way trapdoor functions:
  - Discrete logarithm
  - Integer factorization

## Modular Arithmetic Foundations

- Euclid's theorem. Primes are infinite
- Fundamental theorem or arithmetic. Unique factorization
- GCM and LCM defs
- Division theorem. Unique q and r
- Congruence classes
- Arithmetic properties: sum, mul, exp, cancellation law, modular inverse

## Euclid's Algorithm

- Base and Extended
- Bezout Identity

## Fermat Little Theorem and Euler Theorems

- Fermat's Little theorem: a^(p-1) = 1 (mod p), for p prime and (a,p)=1
  - Corollary: a^k = a^(k mod p-1) (mod p)
- Euler's totient function: φ(n) = n⋅∏(1-1/pi)
  Complete proof requires CRT: for case φ(p^x·q^y) = φ(p^x)·φ(q^y)
- Euler's theorem: a^φ(n) = 1 (mod n), for (a,n)=1
  - Corollary: a^k = a^(k mod φ(n)) (mod n)

## RSA

- Encryption directly using Fermat's Little theorem corollary
  - (e,p-1) = 1 → ed = 1 (mod p-1) → m^e⋅d = m (mod n)
- RSA with n=p⋅q
  - Proof when (m,n) ≠ 1 and security considerations

## Authentication

- Data origin vs peer entity auth
- Symmetric crypto
- Digital Signatures and MAC for authentication

## Hashes

- Hashes: Merkle-Damgard construction
  compression f collision resistant → H collision resistant (example)
- MD5 (128 bit), SHA1 (160 bit), RIPEMD, SHA2

## Primes Generation

- Probability for a prime less than n: 1/ln(n) and expected attempts
- Montecarlo probabilistic primality testing.
- Naive Approach. Check if (x,n) = 1
- Fermat Test. Check if 2^(n-1) mod n = 1 
- Miller-Rabin Test. Check if 2^(m·2^i) = 1 and 2^(m·2^(i-1)) ≠ ±1

## Entropy

- Entropy: H(p) = ∑ pi⋅log2(1/pi)
- Cross Entropy: H(p||q) = ∑ pi⋅log2(1/qi)
- Kullback-Leibler Divergence: D(p||q) = ∑ pi⋅log2(pi/qi)
- Gibbs Inequality: D(p||q) ≥ 0
- Linking Identity: H(p||q) = H(p) + D(p||q)

## Compression Codes

- Terms: code, codeword, codebook
- Uniquely decodable code: encoding function is injective
- Prefix-free (instantaneous) codes are uniquely decodable
  - Mapping to binary tree
- Kraft's inequality: prefix-free-code ↔ ∑ 2^-li ≤ 1
- Mc Millan inequality: not-ambiguous code → ∑ 2^-li ≤ 1
  - Corollary: not-ambiguous → prefix-free mapping
- Language Redundancy (compressibility): R = 1 - H(p)/log2(N)
- Optimal encoding average length
- Shannon Source Coding Theorem: H(p) ≤ li < H(p) + 1
- Shannon-Fano construction
- Huffman codes
- Arithmetic encoding (TODO?)

## Error-Correction Codes

- Discrete memory-less channel: (X, Y, p(·|·))
- Binary Symmetric channel: λ is the error probability.
- Noisy Typewriter channel
- Channel capacity: C = max I(X;Y)
