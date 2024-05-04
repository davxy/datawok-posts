+++
title = "Cyclic Redundancy Check"
date = "2015-08-25"
modified = "2015-08-25"
tags = ["cryptography"]
+++

In error detection algorithms the core business is to maximize the
probability of detecting errors minimizing the number of redundant
information.

CRCs are so called because the check value is a redundancy (it expands the
message without adding information) and the algorithm is based on cyclic
codes.

CRCs are popular because they are simple to implement in binary hardware,
easy to analyze mathematically, and particularly good at detecting common
errors caused by noise in transmission channels. Because the check value
has a fixed length, the function that generates it is occasionally used as
a hash function.

## Arithmetic modulo 2

This is a quick theoretic recap to better understand the practice.

Given a positive integer *m ∊ ℤ* and an arbitrary element *a ∊ ℤ*, the
congruence class *[a]* modulo *m*, is defined as the set of elements in ℤ
that are congruent to *a* modulo *m*. That is, 

[a] = { x ∊ ℤ | x ≡ a (mod m) }

Or, equivalently

[a] = { x ∊ ℤ | x = a + mk, for some integer k }

The set of congruence classes modulo *m* is denoted as *ℤ/ℤm* and have
cardinality equal to m.

*ℤ/ℤ2* is the field of integers modulo 2. Such a field has only two elements
[0] and [1].

Note that in this field [1] = [-1] and [2] = [0].

Addition
- [0] + [0] = [0]
- [0] + [1] = [1]
- [1] + [0] = [1]
- [1] + [1] = [0]

Multiplication
- [0] ⋅ [0] = [0]
- [0] ⋅ [1] = [0]
- [1] ⋅ [0] = [0]
- [1] ⋅ [1] = [1]

Because [1] = [-1], then in this particular field the subtraction result is
equivalent to the addition result

[a] - [1] = [a - 1] = [a + (-1)] = [a] + [-1] = [a] + [1]

Also note the the addition/subtraction is equivalent to the binary **XOR**
operation.


## ℤ/ℤ2 Polynomials 

Given two polynomias *B(x)* and *C(x)* with cohefficients in *ℤ/ℤ2*,
follows the list of the **core properties** that are useful in our discussion:

- If *B(x)* is of higher degree than *C(x)*, then it can be divided by *C(x)*.
- If *B(x)* is of the same degree as *C(x)*, it can be divided once by *C(x)*.
- If *B(x)* is of the same degree as *C(x)*, then the remainder obtained
  when *B(x)* is divided by *C(x)* is obtained by subtracting *C(x)*
  from *B(x)*.
- To subtract *C(x)* from *B(x)*, we simply perform the exclusive-OR
  operation on each pair of matching coefficients.

The division of *B(x)* by *C(x)*, with *B(x)* of higher degree, is done
following the common long-division rules combined with the four rules given
above.

Example: 

x^3+1 can be divided by x^3+x^2+1 (both of degree 3).
The remainder would be x^2.


## CRC Derivation

Represent an *(n+1)* bits message as a polynomial of degree *n*, that is a
polynomial whose highest-order term is *x^n*. Each bit in the sequence
represents the coefficient of the corresponding term in the poly, starting
with the most significant bit to represent the highest-order term.

Example

bit string 10011010 corresponds to the poly *M(x)* = x^7+x^4+x^3+x

The sender and the receiver have to agree on a *divisor* polynomial, *C(x)*,
a polynomial of degree *k*.

Example

*C(x)* = x^3+x^2+1, in this case k=3.

The choice of *C(x)* have significant impact on what types of errors can be
reliably detected. The choice is usually part of the protocol design.

When a sender wishes to transmit a message *M(x)* that is *n+1* bits long,
what is actually sent is the *(n+1)*-bit message plus *k* bits. We call the
complete transmitted message *P(x)*.

To be acceptable, *P(x)* must be divisible by *C(x)*. If an error is
introduced, then in all likelihood the received polynomial will no longer
be divisible by *C(x)*.

Remember that we are operating with polynomial arithmetic modulo 2, thus to
obtain *P(x)* given a *k* bits divisor *C(x)* we must:

1. Multiply *M(x)* by *x^k*; that is, add *k* zeroes at the end of the
   message. Call zero-extended message *T(x)*.
2. Divide *T(x)* by *C(x)* and find the remainder.
3. Subtract the remainder from *T(x)*.

The message, *P(x)* obtained is then perfectly divisible by *C(x)*.

Because the degree of *R(x)* is less than or equal *k*, given the
above definition of subtraction, then subtracting *R(x)* from the k-zeros
padded *T(x)* is equal to replace the zeros in *T(x)* with the remainder
*R(x)*. So the recipient sees *P(x) = T(x) xor R(x)*.

Example

M(x) = 11000010, C(x) = 100011101

The divisor has degree 8 (9 bits) so append 8 zero bits to M(x).
Align the leading '1' of the divisor with the first '1' of the dividend and
perfor a step-by-step school-like division, using XOR operation for each
bit.

    1100001000000000    T(x)
    100011101|||||||    C(x)
    ---------v||||||
    0100110010||||||
     100011101||||||
     ---------vvv|||
     000101111000|||
        100011101|||
        ---------vv|
        00110010100|
          100011101|
          ---------v
          0100010010
           100011101
           ---------
           000001111    R(x)

    P(x) = T(x) - R(x) = 1100001000000000 XOR 1111 = 1100001000001111

When the data and the CRC are received, the recipient can either verify the
received data by computing the CRC and compare the calculated CRC value
with the received one. Or, more commonly used, the CRC value is directly
appended to the actual data. Then the receiver computes the CRC over the
whole sequence (data||CRC). If the CRC is 0, then the check succeeded.

## Where C(x) comes from

We can think as the introduction of errors as the addition of another
polynomial *E(x)*. Thus the recipient sees *P(x) + E(x)*.
An error is undetected if the resulting message can be evenly divided by
*C(x)* and this could only happen if *E(x)* can be divided evenly by
*C(x)*.

The trick is to pick *C(x)* so that this is very unlikely fo common types
of errors.

**Single bit errors**

One common type of error is a single-bit error, which can be expressed as
*E(x) = x^i*, that is, the i-th bit value is flipped.
If we select *C(x)* such that first and the last term are nonzero then we
already have a two-term polynomial that cannot divide evenly the one-term
*E(x)*.

**Double bit errors**

As long as *C(x)* has a factor with at least three terms.

**Odd number of errors**

As long as *C(x)* contains the factor (x + 1).

**Burst of errors**

A sequence of errored bits for which the length of the burst is less than
*k* bits. Most burst errors of larger than *k* bits can also be detected.

## Common CRC Polynomials

Mostly used by link layer protocols

| Name      | C(x)                                  |
|-----------|---------------------------------------|
| CRC-8     | x^8 + x^2 + x^1 + 1                   |
| CRC-10    | x^10 + x^9 + x^5 + x^4 + x^1 + 1      |
| CRC-12    | x^12 + x^11 + x^3 + x^2 + 1           |
| CRC-16    | x^16 + x^15 + x^2 + 1                 |
| CRC-CCITT | x^16 + x^12 + x^5 + 1                 |
| CRC-32    | x^32 + x^26 + x^23 + x^22 + x^16      |
|           |      + x^12 + x^11 + x^10 + x^8       |
|           |      + x^7 + x^5 + x^4 + x^2 + x + 1  |

## References

- Computer Networks: A System Approach - Peterson, Davie
- [Wikipedia](https://en.wikipedia.org/wiki/Cyclic_redundancy_check)
- [Sunshine2k](http://www.sunshine2k.de/articles/coding/crc/understanding_crc.html)
