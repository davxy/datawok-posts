+++
title = "Timing Attack"
date = "2022-04-23"
modified = "2023-12-14"
tags = ["cryptography","security"]
+++


## Variance Recap

The variance of an aleatory variable `X` is a statistical measure of the
*spread* (or dispersion) of a set of values for a random variable.

Variance is defined as the squared deviations of the values from the mean. In
other words, it measures how far the values of a random variable `X` are spread
out from its expected value `E[X]`.

    Var[X] = E[(X - E[X])²] = ∑ Pr(X = xᵢ)·(xᵢ - E[X])²

The formula can be simplified as:

    Var[X] = E[(X - E[X])²]
           = E[X² - 2·X·E[X] + E[X]²]
           = E[X²] - 2·E[X]·E[X] + E[X]²
           = E[X²] - E[X]²

If `X` and `Y` are independent variables:

    Var[X + Y] = Var[X] + Var[Y]
    Var[X - Y] = Var[X] + Var[-Y] = Var[X] + Var[Y]


## Fast Exponentiation Algorithm Recap

Algorithm for fast exponentiation `mᵉ`:

    k = bitlen(e)
    A = 1
    for i in [k-1..0]:
        A = A² mod n
        if is_ith_bit_set(e, i):
            A = m·A mod n
    return A

The total time is given by the sum of the times of each of the `k` iterations.


## Preamble

Fixed the exponent `d`, each iteration time `Tᵢ` depends on the exponent current
bit and on the current value of `A`, and thus depends on the base `m`.

`T` is the aleatory variable which is the sum of all the iterations aleatory
variables `Tᵢ`.

    T = Tₖ₋₁ + Tₖ₋₂ + ... + T₀

The attacker choose many different messages `mⱼ` to observe the relative
execution times, which are interpreted as independent extractions of `T`.


## Attack

The strong assumption is that the attacker has a local device that can emulate
the device under attack and that he can stop its execution while processing a
chosen bit.

The attack is based on the observation of the **variance** of `T`.

Assume that we already determined the bits from `k-1` down to `i+1`, the current
target is the `i-th` bit.

Since the attacker knows the bits from `k-1` to `i+1`, he can correctly emulate
the device under attack until the exponentiation iteration `k-(i+1)` (included).

Tries with both `d[i] = 0` and `d[i] = 1`.

The attacker ends up with two execution times:
- `T` from the real device which used the full correct key `d`.
- `T'` from the emulator which includes the execution time of the already
  disclosed bits plus the new bit we're trying to reveal.

Note that for `i < i ≤ k+1`, `Tᵢ = T'ᵢ`.

```
    T - T' = Tₖ₋₁ + ... + Tᵢ₊₁ + Tᵢ + ... + T₀ 
             - Tₖ₋₁ - ... - Tᵢ₊₁ - T'ᵢ =
           = Tᵢ + ... + T₀ - T'ᵢ =
           = Tᵢ - T'ᵢ + Tᵢ₋₁ + ... + T₀
```

This is the difference of two aleatory variables, we compute the variance of the
difference of the times:

    Var[T - T']

We assume that the times relative to the single iterations are independent
between each other (i.e. `Tᵢ` and `Tⱼ` are independent for `i ≠ j`).

    Var[Tᵢ] = Var[T'ᵢ] = v

If the value of `d[i]` that has been tried by the attacker is correct then the
emulations of the attacker are correct down to the `i`-th iteration (included):

    T - T' = Tᵢ₋₁ + ... + T₀

And thus:

    Var[T - T'] = Var[Tᵢ₋₁] + ... + Var[T₀]

If instead the bit value was not correct, the variance is:

    Var[T - T'] = Var[Tᵢ - T'ᵢ] + Var[Tᵢ₋₁] + ... + Var[T₀]
                = Var[Tᵢ] + Var[T'ᵢ] + Var[Tᵢ₋₁] + ... + Var[T₀]

Overall, if we have chosen the wrong value for `d[i]` then we're going to have a
variance that is greater by a term `2·v`.

To summarize, the attacker:
- executes the algorithm with a bunch of `mᵢ` (e.g. 1000);
- gets the timings for each `T`;
- computes the empirical variance using the samples;
- picks as the exponent next bit the one which yields the smaller variance.

## Reference

- [Rust and Python PoC](https://github.com/davxy/crypto-hacks/tree/main/group-op-timing-attack)
- [*Kocher* paper](https://link.springer.com/chapter/10.1007/3-540-68697-5_9)
