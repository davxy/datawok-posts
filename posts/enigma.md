+++
title = "Breaking Enigma"
date = "2018-11-07"
modified = "2023-11-18"
tags = [ "cryptography", "history" ]
toc = true
+++

During World War II, the Enigma machine presented a formidable challenge to the
Allied forces as they struggled to decipher encrypted German messages.

However, a team of brilliant codebreakers, including *Alan Turing*, at Britain's
Bletchley Park successfully cracked Enigma's codes, turning the tide of the war.

In this post I'm going to describe the core components of the machine and what
are the keypoints that allowed the cryptanalysts to break one of the most
famous codes of the history.

## Construction

Main components:
- **Keyboard**: allows the operator to input the plaintext by pressing the
  corresponding keys.
- **Plugboard**: a series of interchangeable cables that connect pairs of
  letters.
- **Rotors**: a set of rotating cipher wheels which are wired together. Each
  rotor had a unique configuration of wiring inside which cause the input signal
  to be scrambled before reaching the next rotor.
- **Reflector**: a specialized rotor that reflected the signal back through the
  rotors.
- **Lampboard**: display for the encrypted output. When a key is pressed on the
  keyboard, the corresponding encrypted letter illuminates on the lampboard.

The Enigma machine had different variations and models, each with a specific
configuration. These variations primarily involved the number of rotors and the number of cables used in the plugboard.

In these notes I'll describe one of the first models, where the configuration
allowed to choose 3 out of 5 possible rotors and a plugboard with 6 cables.

Operation Steps:
 1. `x`: keyboard input given by the operator
 2. `𝜎`: plugboard constant substitution
 3. `𝛼`: first rotor substitution
 4. `𝛽`: second rotor substitution
 5. `𝛾`: third rotor substitution
 6. `𝜋`: reflector
 7. `𝛾⁻¹`: third rotor inverse substitution
 8. `𝛽⁻¹`: second rotor inverse substitution
 9. `𝛼⁻¹`: first rotor inverse substitution
10. `𝜎`: another plugboard constant substitution
11. output sent to the lampboard

As a formula:

    𝜌(x) = 𝜎·𝛼⁻¹·𝛽⁻¹·𝛾⁻¹·𝜋·𝛾·𝛽·𝛼·𝜎(x) = 𝜎·𝜏·𝜎(x)

With `𝜏` a permutation function that changes after each input character due to
the rotors. In particular:
- 1st rotor advances by one place after each character
- 2nd rotor advances by one place after 26 characters
- 3rd rotor advances by one place after 26² characters

## Keyspace Size

The operator is allowed to choose:
- Three out of five possible ordered rotors: `5·4·3 = 60`
- Rotors initial configuration: `26³ = 17567`
- Plugboard cabling with 6 cables: `100,391,791,500 ≈ 10¹¹`

Total keyspace size is thus `|K| ≈ 105,869,167,644,240,000 ≈ 10¹⁷`.

### Plugboard configurations

We count the ways we can choose 6 different couples from a set of 26 elements:

    Couple1 = binom(26,2)
    Couple2 = binom(24,2)
    ...
    Couple6 = binom(16,2)

    TotOrd = Couple1 · Couple2 · ... · Couple6 = 72,282,089,880,000

Alternatively, we can first count the ways we can choose 12 elements:

    N = binom(26, 12)

Then the ways to choose different couples from the set of 12 elements:

    Couple1 = binom(12,2)
    Couple2 = binom(10,2)
    ...
    Couple6 = binom(2,2)

    TotOrd = N · Couple1 · Couple2 · ... · Couple6 = 72,282,089,880,000

Finally, since we don't care about the order of the 6 couples, divide by `6!`.

    Tot = TotOrd / 6! = 100,391,791,500


## Components Properties

### Reflector

The reflector function `𝜋`
- is an **involution** (`𝜋·𝜋(x) = x`);
- doesn't have **fixed points** (`∀ x, 𝜋(x) ≠ x`).

### Plugboard

The plugboard function `𝜎`
- is an **involution**;
- generally `𝜎(x) = x`, except for 12 "unstakered" letters where `𝜎(x) ≠ x`.

### Rotors

The product of rotors function and their inverses is the identity function:

    𝛼⁻¹·𝛽⁻¹·𝛾⁻¹·𝛾·𝛽·𝛼(x) = x

Since the rotors' configuration changes after each input we identify a rotor `𝛾`
configuration at step `k` with the notation `𝛾ₖ` and the configuration of the
whole machine at step `k` as `𝜌ₖ`

    𝜌ₖ(x) = 𝜎·𝛼ₖ⁻¹·𝛽ₖ⁻¹·𝛾ₖ⁻¹·𝜋·𝛾ₖ·𝛽ₖ·𝛼ₖ·𝜎(x) = 𝜎·𝜏ₖ·𝜎(x)

### General properties

Given the properties of the single components:
- `𝜌(x)` is an involution (`𝜌·𝜌(x) = x`)
- `𝜌(x)` doesn't have fixed points (`∀ x, 𝜌(x) ≠ x`)

*Proof*. 

Involution property can be trivially proven by expanding `𝜌·𝜌(x)`.

Property about fixed points property can be proven by contradiction.

Assume that `𝜌` has a fixed point `x`.
Then `𝜎·𝛼⁻¹·𝛽⁻¹·𝛾⁻¹·𝜋·𝛾·𝛽·𝛼·𝜎(x) = x`

We apply the inverses on both sides (inverse of `𝜎⁻¹ = 𝜎`).
Then `𝜋·𝛾·𝛽·𝛼·𝜎(x) = 𝛾·𝛽·𝛼·𝜎(x)`  →  `𝜋(y) = y`

Follows that `𝜋` has a fixed point, but this is not possible by construction.

∎

Not having fixed points is a weakness as it allows discarding some possibilities
from the keyspace during cryptanalysis.


## Cryptanalysis

This is a **known plaintext** attack.

A world which is assumed to be present in the plaintext is called a **crib**.

There is a trick to speed-up checking if the position of a crib is at least
possible: we can discard the possibilities with fixed points.

For example, let's say that the message is assumed to contain the crib
"wettervorhersage", which is the German word for "weather forecast".

    W E T T E R V O R H E R S A G E
    Q F Z W R W I V T Y R E S X B F O G K U H Q B A I S E Z
                            ^impossible

      W E T T E R V O R H E R S A G E
    Q F Z W R W I V T Y R E S X B F O G K U H Q B A I S E Z
                  ^impossible

        W E T T E R V O R H E R S A G E
    Q F Z W R W I V T Y R E S X B F O G K U H Q B A I S E Z
                        ^impossible

          W E T T E R V O R H E R S A G E
    Q F Z W R W I V T Y R E S X B F O G K U H Q B A I S E Z
          ^ impossible

One possible encryption:

            W E T T E R V O R H E R S A G E
    Q F Z W R W I V T Y R E S X B F O G K U H Q B A I S E Z

The more are the crib's letters the more is the probability to find the correct
offset.

### Initial configuration recovery

The initial configuration is taken as the one where the crib begins:

    config n.    : 1 2 3 4 5 6 . . .
    plain (crib) : W E T T E R V O R H E R S A G E
    cipher       : R W I V T Y R E S X B F O G K U

We create a graph with a node for each alphabet letter.

Two nodes are connected by an arch if there is a correspondence in the
ciphertext/plaintext. The arch identifier is the configuration number.

    W ←1→ R, E ←2→ W, T ←3→ I, T ←4→ V, E ←5→ T, ...

The correspondence is symmetric because the encryption is an involution.
That is, if W in state 1 is mapped to R then R in state 1 would be mapped to W.

The important thing of this graph are the **cycles**.

For example, let's assume to have found the following cycle (not from the
previous example):

    T ←3→ N ←7→ S ←2→ T

This means that if we connect three enigma machines with the configurations
equal to the cycle and with the output of each machine connected to the input
of the next one (the last output is connected to the first input), then we
constructed a circuit.

Since the cipher is an involution, the input/output distinction is blurred and
can be ignored.

For example, we know that if the rotors of one machine are in config `𝜏₃` then
the machine will map `T` to `N` and `N` to `T`.

If we connect a lamp to the circuit the lamp should turn on.

(`𝜏ₖ` are the rotors in configuration `k`)

     +--(T)---[𝜎·𝜏₃·𝜎]---+
     |                   |
     |   +---------------+
     |   |
     |  (N)---[𝜎·𝜏₇·𝜎]--+
    💡                   |
     |   +---------------+
     |   |
     |  (S)---[𝜎·𝜏₂·𝜎]---+
     |                   |
     +-------------------+

Note that the plugboard configuration `𝜎` is constant for the whole circuit and
can be removed. Given the cycle:

    𝜎·𝜏ᵢ·𝜎(x) = y  and  𝜎·𝜏ⱼ·𝜎(y) = x

    → 𝜎·𝜏ⱼ·𝜎·𝜎⋅𝜏ᵢ·𝜎(x) = x
    → 𝜎·𝜏ⱼ·𝜏ᵢ·𝜎(x) = x
    → 𝜏ⱼ·𝜏ᵢ·𝜎(x) = 𝜎(x)
    → 𝜏ⱼ·𝜏ᵢ(z) = z
        
Whatever `𝜎(x) = z` is, we still have a circuit which is dependent only on the
rotors configuration and not the actual input or the `𝜎` function.

Once we detected a cycle we try to find the initial configuration `𝜏₁` such that
`𝜏₃`, `𝜏₇`, `𝜏₂` results in a circuit. We try this for all the possible initial
configurations (which are `26³ = 17,576`).

We can exclude all the configurations that don't close the circuit.

The more circuits we have to test, the fewer spurious configurations are possible.

### Plugboard configuration recovery

Once that we recovered the rotors' configuration we already recovered all the
letters that are not altered by the plugboard (`𝜎(x) = x`), which are 14 out of
26 characters.

By applying the "partial" decryption function to the ciphertext, we end up
recovering ~50% of the plaintext. This helps to deduce the missing characters
and thus finally recover the full plugboard configuration.


## References

- [The Codebreakers](https://en.wikipedia.org/wiki/The_Codebreakers)
- [Enigma museum](http://enigmamuseum.com)
- [How did the Enigma Machine work?](https://www.youtube.com/watch?v=ybkkiGtJmkM)
- https://github.com/cedricbonhomme/pyEnigma
- https://cryptii.com/
