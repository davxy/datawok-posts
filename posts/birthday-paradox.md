+++
title = "Birthday Paradox"
date = "2023-03-29"
tags = ["cryptography","probability"]
+++

The birthday paradox is a surprising statistical phenomenon that shows how even
in a small group, it's very likely that two people share the same birthday.

In this blog post, we'll explore the math behind the paradox and its practical
applications in computer science and cryptography.

## The Paradox

As a flagship example, it states that in a group of just 23 people, there is a
50% change that two of them will share the same birthday.

This probability, which seems quite high, may come as a surprise to many,
however it can be easily explained by the principles of probability.

The paradox is a classical example of how probability can lead to seemingly
counterintuitive conclusions and is a great illustration of how probability
can be used in everyday life.

### Probability

The probability of the Birthday Paradox is computed by considering the number
of possible pairs of people in a group and the probability that any of these
people will have **different** birthdays.

To calculate the probability that any two people in a group of n will have
a different birthdays, we can use the formula:

    P(different birthdays) = 365/365 ⋅ 364/365 ⋅ ... ⋅ (365-n+1)/365
                           = 365! / [(365-n)!⋅365^n]
    
To find the probability that at least two people in the group will have
the same birthday, we can take 1 minus the probability that they have different
birthdays

    P(same birthday) = 1 - P(different birthdays)

Some results

  |  n |  P(n) |
  |----|-------|
  | 10 | 0.117 |
  | 20 | 0.411 |
  | 23 | 0.507 |
  | 40 | 0.891 |
  | 70 | 0.999 |

## Generalized Birthday Problem

Given a year of 'd' days we want to determine the minimal number 'n' such that
the probability of a birthday coincidence is at least 50%.

In other words n is the minimal integer such that:

    1 - (1-1/d)⋅(1-2/d)..(1-(n-1)/d) ≥ 0.5

Note that the classical birthday problem is an instance of the GBP with n=365
and gives as a result n=23.

Obviously n is a function of d, thus we're going to express it as n(d).

As an approximate result n(d) is

  n(d) = ⌈√(2d⋅ln(2))⌉

### Collision Probability

Given n random integers drawn from a discrete uniform distribution with range
[1,d], we look for the probability p(n; d) that at least two numbers are the same.

The generic results can be derived using the same arguments given above

    p(n; d) = 1 - (1-1/d)⋅(1-2/d)..(1-(n-1)/d)

Conversely if n(p; d) denotes the number of random integers drawn from [1,d]
to obtain a probability p that at least two numbers are the same, then

    n(p; d) ≈ √(2d⋅ln(1/(1-p)))

When applied to hash functions this is the expected number of N-bit hashes
that can be generated before getting a collision. This is not 2^N, but rather
only 2^(N/2).

This is exploited by birthday attacks.

### n(p; d) Formula Approximation

We define H(i,j) as a Bernulli's random variable representing the extraction
of two values i and j from the set [1,d].

    H(i,j) = 1 if i = j
             0 otherwise

The total number of possible collisions is ∑ H(i,j) over all the different
couples (i,j), noting that (i,j) = (j,i).

The number of possible couples is n!/((n-2)!2!) = n·(n-1)/2

The probability of a collision for a fixed value y is:

    Pr(Cy) = ∑ Pr(i = y)·Pr(j = y | i = y) = ∑ 1/d·1/d = 1/d

Expected value of a collision:

    σ = 1/d + ... +
    E[C] = ∑ E[Ci] = ∑ 1/d
        
   (1/d is the expected value of the Bernulli's variable)

========================
TODO: NOT NOT NOT CLEAR
========================

    The sums is aver all the possible couples, i.e. n·(n-1)/2

    E[C] = n(n-1)/2 · 1/d ≈ n^2 / 2 · 1/d

We want to determine the condition such that the expected number of collisions
are more than one:

    E[C] ≥ 1  →  n^2 ≥ 2d  →  n ≥ √(2d)

probability not collision: 1-1/k = (k-1)/k


## Attack

A collision can be particularly dangerous if the hash is used as a primitive
for a digital signature.

If the attacker discovers a collision, i.e. m and m' such that H(m) = H(m'), he
can submit m to the victim in order to have it signed, thus obtaining sign(H(m)).

Given that H(m) = H(m') then sign(H(m)) = sign(H(m')).

At this point, the attacker will have a valid signature for m' as well, which
can be used maliciously.

If the number of possible outputs of H is 2^z:

Technique to find a collision:
- constructs k=2^(z/2) variants of a legit message m which differs only for
  some trivial changes
- uses the same technique to construct k variants of a malicious messages m'
- each of these messages are feed to H
- we end up with two sets of digests: A = {H(mi)}, B = {H(mi')}
- we search for an y in A ∩ B

To construction of messages variants is quite easy, for example by inserting
100 spaces around the message the attacker can construct k=2^100 different
messages.

The probability of a collision obviously depends on k.

Can be proven that

    P(A ∩ B) ≥ 1/2 if k ≥ 2^(z/2)

TODO: PROOF

### Birthday Attack Mitigations

To reduce birthday attack risk we have to chose a value z that is sufficiently large.

Currently, hashes like MD5 (z=128) or sha1 (z=160) are not considered secure.

Another way to counter this attack is to use a MAC (i.e., a keyed hash such as
HMAC) where the output also also depends on a secret key k.

In this way an attacker cannot pre-compute offline collisions, as they do not
know the secret key.

---

H can be viewed as an aleatory variable with values in Y, with |Y| = k = 2^m

If we extract a number of elements from H, close to √k, the probability to find 
a collision (i.e. Hi = Hj) is ≈1/2.

For the pigeon-hole principle if the possible different outputs are k, then
after k+1 extractions we're going to have a collision with probability 1.

What can be proven using the birthday paradox is that that we're going to have
a collision with probability 1/2 after √k extractions (and not k/2 as
intuitively expected). Birthday Paradox Exploitation


## References

- Simple PoC in Rust [here](https://github.com/davxy/crypto-hacks/tree/main/birthday-paradox)
