+++
title = "Zero-Knowledge Proofs - v0.1.17"
date = "2023-08-06"
modified = "2023-11-13"
tags = ["cryptography", "zk-proof", "draft"]
toc = true
draft = true
+++

## *Abstract*

Zero-Knowledge Proofs (ZKP) represent a fascinating and influential concept
within the realm of cryptographic protocols. 

At a glance, a ZKP enables one party to demonstrate the authenticity of a
statement to another party without revealing any details beside the correctness
the statement itself.

ZKPs find applications in various areas, including secure authentication
protocols, blockchain systems, and secure computation, among others.

Another motivation is philosophical. The notion of a proof is basic
to mathematics and to people in general. It is a very interesting and
fascinating question whether a proof carries with it some knowledge or not.

In this discussion we will go from the most classic mathematical notion of
proof down to proofs which shares zero knowledge.

---

## Classical Proofs

In *deductive reasoning* the *inference rules* are the set of rules which
allows to reach a *conclusion* from the assumption that other statements, called
*premises*, are true.

In mathematics, a deductive reasoning is usually presented in the form of
a *proof*.

By setting the *conclusion* as the statement we want to prove and the *premises*
as the set of *axioms* and previously proven statements, we can define a proof
as the ordered set of logical derivation that incrementally drives from the
premises to the conclusion.

These logical assertions are derived using logical *inference rules* from a set
of *axioms* or other previously proven statements (theorems).

As all the proof reasoning leverages the basic properties of boolean algebra,
thus is made implicit that Boolean logic axioms and theorems holds as premises
for all the reasonable proof systems.

A proof is **valid** if the conclusion logically follows from the premises. In
other words, if the premises are true, the conclusion must also be always true
based on the rules of logic.

A proof is **sound** if is valid and all of its premises are true.

### Simple Examples

Sound proof:

- *Premises*:
  - `A`, `B` and `C` are three arbitrary sets such that `A ∩ B ⊆ C`;
  - an element `x ∈ B` is given;
  - basic properties of set theory hold;
- *Conclusion*: `x ∉ A \ C`.
- *Proof*: 
  - `x ∉ A \ C  =  ¬(x ∈ A ∧ x ∉ C)  =  x ∉ A ∨ x ∈ C  =  x ∈ A → x ∈ C`
  - `A ∩ B ⊆ C ∧ x ∈ B ∧ x ∈ A  →  x ∈ C`

Valid but not sound proof:

- *Premises*:
  - 4 is an even number
  - all even numbers are prime (wrong)
- *Conclusion*: 4 is prime
- *Proof*: conclusion follows directly from premises.

As you can see, since the conclusion follows from the premises, the proof is valid.
But also the second premise is incorrect, thus is not sound.

As can be seen, the previous examples are also instances of the most classical
version of proofs, which is a **static** sequence of logical deductions.

### Proof Systems

A **proof system** is a systematic (algorithmic) way to construct and analyze
a proof. It typically consists of the following components:

- **Statement (x)**: the assertion or claim under consideration. It is the
proposition that one seeks to prove or disprove.

- **Proof (π)**: a set of arguments, evidence, or logical steps that, when applied
according to the rules of the proof system, should establish the truth or
validity of the statement.

- **Prover (`P`)**: an algorithm which constructs a proof for the statement
(`P(x) = π`).

- **Verifier (`V`)**: an algorithm that, given both the statement and the proof,
decides whether the proof is valid. This algorithm outputs 1 if the proof is
correct and 0 if the proof is not correct (`V(x,π) = 0|1`).

Clear rules and guidelines are essentials when we need to move proof
construction and checking from the potentially ambiguous realm of natural
languages to the realm of formal languages (e.g. programming languages).

Though this lecture we'll mostly stick to the popular convention to refer to the
*prover* as Peggy and the *verifier* as Victor.

### Knowledge Sharing

In a *classical* proof system a proof that some assertion is true also reveals
*why* the assertion is true. This is very intrinsically bound to how the
proof is constructed, i.e. Peggy shares all the logical steps to allow Victor to
independently reach the conclusion.

Follows that the proof provides more knowledge than just the mere fact that the
statement is true, which is what Peggy and Victor are interested in the first
place, regardless of the way this is proven.

For example, to prove that we know the factorization of a number `n`, Peggy can
trivially provide the list of its prime factors `{pᵢ}`. Victor can efficiently
check if `n = ∏ᵢ pᵢ`. In the end, not only Victor is convinced about our
statement, but he also learns the factorization of `n`.

The information which contributes to the construction of the proof is known
as the **witness**. If Peggy shares the witness with Victor then this would be
a classic proof. On contrary, if the witness is kept secret then it is a `ZK`
proof.


### Formalization and Relationship to Complexity Theory

By moving proof systems to the domain of machines, is important to find a
non-ambiguous way to analyze the complexity, and thus the resource requirements,
of the techniques used to prove and verify problems.

Find a clear relationship between proof systems and important complexity classes
like `NP` is fundamental to understanding the tractability of proving and
verifying problems.

In this context, a problem is often associated with a language over a specific
alphabet. This association helps formalize and understand the problems that
computers can solve.

Many interesting problems are formulated as **decision problems**, where the
answer is either "yes" or "no". These problems can be associated with languages
where the strings represent instances of the problem, and membership in the
language indicates a positive answer (yes), while non-membership indicates a
negative answer (no).

For example, consider the *Subset Sum Problem*. The question here is whether
there is a subset of integers that adds up to a target `t`. The alphabet in
this case consists of numerical symbols (integers), and the problem can be
represented as a language:

    L = { (S,t) | S ⊆ ℕ and ∃ X ⊆ S: the elements of X adds up to t } 

In this language representation, a pair `(S,t)` is in the language if and
only if satisfies the language condition.

Key characteristics of proof system `(P,V)` for decisional problems:
- **completeness**: `x ∈ L` if and only if `V(x,π) = 1`;
- **soundness**: `x ∉ L` if and only if `V(x,π) = 1`;
- **efficiency**: `V(x,π)` runs in polynomial time with respect to length of `x`.

Since each problem belongs to a complexity class, once we mapped the problem to
a language, we implicitly associated the language to the same complexity class.

With respect to this, for example, a language `L ∈ NP` if a solution to the
problem associated to `L` can be verified by a deterministic *Turing* machine
in polynomial time, even if finding the solution itself (i.e. constructing the
proof) might be a computationally intensive task (as exponential).

---

## Interactive Proofs

An **interactive proof (IP)** system extends the classical notion of proof
system by moving from a proof conceived as a *static* sequence of symbols to an
*interactive protocol* where Peggy incrementally convinces Victor by actively
exchanging messages.

The concept was first independently proposed in the mid 80s by *Shafi
Goldwasser*, *Silvio Micali*, and *Charles Rackoff* in their seminal paper "The
Knowledge Complexity of Interactive Proof Systems" [GMR^1], which, among other
things, also contains the first definition of zero-knowledge proof and *Laszlo
Babai* in its paper "Trading Group Theory for Randomness"[^BAB].

In `IP` systems the actual ordered sequence of exchanged messages is known as
the protocol **transcript**. Two runs of the same protocol may have a different
transcript, depending on if the protocol is deterministic or not.

### Sigma Protocols

Any `IP` system with a transcript composed of three messages are called *sigma
protocols*.

A sigma protocol typically has the following flow:
- *commitment*: Peggy shares the first message;
- *challenge*: Victor sends some kind of challenge;
- *response*: Peggy sends a response to the challenge.
- *result* (optional)

The name stems from the Greek letter `Σ` which visualizes the flow of the protocol
in presence of a last result message from the *verifier*.

![sigma-protocol](/companions/zk-proofs/sigma-protocol.png)

This type of protocols is the most widespread when comes to `ZKP`, indeed
every protocol which will be analyzed in the `ZKP` examples section is a *sigma
protocol*.

### Deterministic Interactive Proofs

A *Deterministic IP* is an `IP` which doesn't introduce any form of randomness
in the protocol messages. Victor asks questions and Peggy is expected to always
reply with the same answer.

![deterministic-ip](/companions/zk-proofs/deterministic-ip.png)

At this point Victor:
- computes `y = ⌈N / x⌉` 
- checks if `N = x·y`
- checks if both `x` and `y` are primes via some deterministic algorithm
  (here Victor can't use a probabilistic algorithm as the verification result
   should be deterministic).

**Every deterministic `IP` can be trivially mapped into a static proof and vice
versa.**

To map a static proof to a deterministic `IP` the two parties can just
communicate to incrementally transfer some parts of the proof. Note that a
static is a deterministic IP with one message. This is not very interesting.

To map a deterministic `IP` to a static one is sufficient for the *prover* to
construct a single string which embeds the whole transcript that would be used
in the `IP`. The construction is possible as the transcript is known and fixed.
Victor checks if the set of messages in the string is consistent with
the expected transcript.

![deterministic-ip2](/companions/zk-proofs/deterministic-ip2.png)

From this last result follows that deterministic `IP` systems are not more
powerful than SP with respect to the set of languages that can be proved.

Because this kind of `IP` is not much interesting, we leave the formal
definitions for the next chapter.

### Probabilistic Interactive Proofs

Introduction of randomness to the protocol, in some cases, allows proving the
assertion more efficiently or proving en entire novel class of languages which
can't be proven using deterministic proof systems.

In the formalization described on the GMR paper:
- Peggy is assumed to have unbounded computing power while Victor only
  polynomial time on the size of the statement to prove;
- both Peggy and Victor have access to a **private** random generator.

Since Victor has polynomial computing power is easy to see that only a
polynomial time number of messages can be exchanged between the two.

The result is a probabilistic proof system for `NP`, where Victor is allowed to
make an error during proof evaluation with a small probability.

From now on we'll refer to *probabilistic interactive proof* systems to just
*interactive proof* (`IP`) systems.

More formally.

**Definition**. An `IP` system for a language `L` is a protocol `(P,V)`
for communication between a computationally unbounded machine `P` and a
probabilistic polynomial time machine `V` taking an input statement `x`, a
message history (`hᵢ`) and randomness source (`r`) to produce the next protocol
message:

```
  m₁ = V(x, rᵥ, h₁={})
  m₂ = P(x, rₚ, h₂={m₁})
  m₃ = V(x, rᵥ, h₃={m₁,m₂})
  ...
```

Key characteristics of an `IP` system `(P,V)` for a language `L`:
- **completeness**: if `x ∈ L` then `V(x,π) = 1` with probability at least `1-ε`;
- **soundness**: if `x ∉ L` then `V(x,π) = 1` with probability at most `ε`;
- **efficiency**: the total computation time of `V(x,π)` and total communication
  in `(P,V)` is polynomial with respect to length of `x`.

The value of `ε` represents a bound to the *Validator* error probability.

If for a single protocol execution `ε < 1` then we can always derive another
protocol which executes the original protocol `k` times in a row effectively
exponentially reducing the error probability to an arbitrary value `εᵏ`.

For example, if `ε = 1/10` then by executing the protocol `5` times we reduce
*the error probability to `ε⁵ = 1/100000`. Victor then accepts with probability
`0.99999`.

Writing a proof that can be checked without interaction, when possible, is for
some problems a much harder task. Mostly because in some sense the *prover* has
to answer in advance to all the possible questions from Victor.
As we'll see later, there is an entire class of problems which cannot be proven
via static proofs.

#### Proving Completeness

Completeness is quite easy to prove as if Peggy knows the solution to a problem,
she will eventually convince Victor as its responses during the repeated protocol
executions will be always correct regardless of the number of repetitions.

#### Proving Soundness

Soundness is a bit more difficult to prove.

Protocol soundness is based on the existence of what is known as an
**extractor**; a tool which allows Victor to extract key information used by
Peggy to construct the proof.

If Victor is capable of rewind Peggy's execution (without her to notice) she
will eventually re-execute the protocol exactly in the same way he already did
(also the randomness read will be the same). From the Peggy's perspective the
executions are statistically identical.

If under these conditions a cheating Victor is able to recover some information
which allows him to construct a valid proof then the protocol is sound.

The intuition here is that it is statistically impossible for the *prover*,
to disclose crucial information without actually knowing it. Should be very
lucky making it out of thin air.

Note that the extractor is a tool which must not exist in any real execution
environment for the protocol. For example, if the environment is the real world,
it could be something like a "time machine", if the environment is the digital
world this could be the capability to capture a snapshot of the *prover* program
state at any point in time and restart it from that snapshot (like protocol
execution in a virtual machine).

### Interactive Turing Machines

Let's invest some time in formalizing a bit further the definitions of *prover*
(`P`) and *verifier* (`V`) used in `IP` systems as *Interactive Turing Machines*
(ITM).

**Definition**. An ITM is a *Turing* machine with a read-only input tape, a
read-write work tape, a read-only random tape, a read-only communication tape
and a write-only communication tape.

In an interactive protocol between `P` and `V` the two machines share the same
input tape, which generally contains the encoded assertion to be proven.

The read-only communication tape of one machine is defined to be the write-only
communication tape of the other machine. This type of tape is used to exchange
protocol messages.

![ITM](/companions/zk-proofs/ITM.png)

During the proving protocol, the two machines take turns in being active.

On each step of the protocol the ITM performs some internal computation
using all the readable tapes. Then it writes the output string to the write-only
communication tape (which corresponds to the read-only input of the other
machine).

The last message of every protocol goes from `P` to `V`, which can then accept
or reject.

As previously said `P` is assumed to be computationally unbounded while `V` is
assumed computationally bounded by polynomial time with respect to the input
size.

### Interactive Proof Complexity Class

In this paragraph we're going to give a small insight about the complexity class
which relates to the `IP` systems.

This is a very theoretical subject and beyond the scope of this document.

**Definition**. The **IP** complexity class is defined as a class of languages
for which there exists an interactive proof system whose proofs can be verified
in polynomial time with respect to the length of the statement to prove.

    IP = { L | L has an interactive proof }

The class can be further divided depending on the characteristics of the protocol:
`IP[k]` is the class of languages which can be decided by a *k*-round interactive
proof. 

Lund, Fortnow, Karloff and Nisan [LFKN] proved that `PH ⊂ IP`, which shows
that interactive proofs can be very powerful as they contain the union of
all complexity classes in polynomial hierarchy. Shortly later, Shamir [SH]
proved that in fact `IP = PSPACE`, which gave a complete characterization of
interactive proofs.

`PSPACE` includes, for example, [`co-NP`](https://en.wikipedia.org/wiki/Co-NP)
the class of problems whose complement is in `NP`.

A natural consequence is that using an interactive proof system we are able to
verify solutions to problems which are outside `NP`.

In some cases, the interaction between Peggy and Victor can lead to a more
efficient verification process, allowing Victor to accept a proposed solution
without the need for Peggy to reveal the entire solution.

### Arthur-Merlin Protocols

An [Arthur-Merlin](https://en.wikipedia.org/wiki/Arthur-Merlin_protocol)
introduced by Babai [BAB85], is an `IP` system with tPeggy
that the *prover* and Victor's share the same randomness source. In this
contextPeggyr* is cPeggyrlin andVictoris callVictorThe practical implication is that both the actors can see the randomness
(like coin tosses) of the other party. ![AM](/companions/zk-proofs/AM.png)
GVictorSipser](https://en.wikipedia.org/wiki/Arthur%E2%80%93Merlin_protocol)
proved that all languages with interactive proofs of arbitrary length with
private randomness (`IP`) also have interactive proofs with publVictor(`AM`) and
vice versa.
However, is worth anticipating that even though general `IP` with secret random
sources are notPeggyul with respect to the set of languages they can prove, they
offer a feature whichs is fundamental in proving staVictort
sharing any knowledge (aka `ZKP`).

#### VictorThPeggy in e set of decisional problems that can be verified in
polynomial time by an `AM` protocol with one single message is called `MA`.
Generic `MA` protocol steps:
1. *Merlin* sends to *Arthur* the pro2. *Victorcides
`MA` protocols are similar to traditional `NP` proofs with the addition that
*Arthur* (the *prover*) can use a public randomness source to construct its
proof.

#### AM Protocol

The set of decisional problems that can be decided in polynomial time by an `AM`
protocol with `k` messages is called `AM[k]`.

For all `k > 1`, `AM[k] = AM[2]`. This result is due to the fact that *Merlin*
can observe *Arthur* randomness source during the whole protocol execution, and
thus this doesn't affect *Merlin* messages.

`MA` is strictly contained in `AM`, since `AM[2]` contains `MA` and `AM[2]`
cannot be reduced to `MA`

Goldwasser and Sipser [GS] proved that for any generic `IP` protocol and for any `k`
`AM[k] ⊂ IP[k] ⊂ AM[k + 2]`. And because `AM[k + 2] = AM[k] = AM[2]` follows that
`IP[k] = AM[2]`.

In other words, for every language `L` with a `k`-round `IP` system, `L` has a
`k = 2` round *public-coin* `IP` system.

The key characteristics of an `AM` proof system `(P,V)` for a language `L` are
the same as for a generic `IP` systems with respect to *completeness*,
**soundness* and efficiency* properties.

### Examples

#### Tetrachromacy

Tetrachromacy is a condition that allows some individuals to perceive a broader
spectrum of colors than the typical trichromat, who has three types of cone
cells in their eyes for color vision. Tetrachromats have an additional type of
cone cell, enabling them to perceive a wider range of colors.

Peggy wants to prove to Victor that she is tetrachromat by showing that she's
able to distinguish between the two marbles which are equal to Victor but 
different for her.

Protocol:
- Peggy puts the two marbles in from of Victor and turns her back.
- Victor tosses a coin and, depending on the result may swap the position of
  the marbles.
- Peggy tells Victor if the marbles were swapped.

The probability for Peggy to cheat (aka *soundness error*) is `ε = 1/2`.

We can lower this probability arbitrarily by repeating the protocol `k` times,
the probability to cheat becomes `1/2ᵏ`.

Note that in this proof a malicious Victor may put another, apparently equal,
marble in front of the *prover* and infer if that is equal or not to the other.

#### Quadratic Non-Residuosity Problem

`y ∈ Zₘ*` is a quadratic residue if `∃x ∈ Zₘ*` such that `x² ≡ y (mod m)`.
Otherwise, `y` is called a quadratic non-residue modulo `m`.

We define the languages:

    QR  = { y | y ∈ Zₘ* is a quadratic residue }
    QNR = { y | y ∈ Zₘ* is a quadratic non-residue }

It is considered to be a hard problem to tell if `y ∈ QR` (or `QNR` by
exclusion) without knowing the factorization of `y`.

Notice that both `QR` and `QNR` problems belong to `NP`, and thus they have
a classic proof system: Peggy just needs to send to Victor the factorization of
`y` without any further interaction.

If instead the *prover* wants to prove that `y ∈ QNR` without sharing the
factorization of `y` this is actually possible only via an `IP` system.

The protocol is based on the simple fact that if `y ∈ QNR` then `y·k² ∈ QNR` for
any `k ∈ Zₘ*`.

Protocol:
- Victor chooses a random number `r ∈ Zₘ*`, and flips a coin. If the coin result
  is 'heads' then `t = r² mod m` else `t = y·r² mod m`. He sends `t` to Peggy.
- Peggy, which has unrestricted computing power, finds if `t` is a quadratic
  residue (i.e. if `t = r² mod m`) and tells Victor what was his coin toss
  result.

If `y ∉ QNR` then `y ∈ QR` and thus `t ∈ QR` as well. In this case Peggy has no
way to recover the coin toss results Victor. In fact Peggy has `ε = 1/2`
probability of guessing correctly.

As usual, the soundness error probability can be arbitrarily reduced by
performing multiple protocol runs.

Unfortunately, this protocol also shares some extra information. If `y ∈ QNR` a
malicious Victor can send to Peggy any number `k` and learn from the response if
`k ∈ QR` or not.

---

## Zero Knowledge Proofs

Now that we defined the interactive class of proof system is finally time to
better discuss the core topic of this lecture: *how much knowledge should be
communicated to prove a statement?*

The first serious approach to the problem was first proposed in the 80s by
*Goldwasser*, *Micali*, and *Rackoff* in their GMR85[^1] paper (yes, the same
paper which introduced the `IP` systems).

Before the GMR paper, most of the effort on `IP` systems area focused on
the *soundness* of the protocols. That is, the sole conceived weakness was a
malicious Peggy attempting to trick Victor into approving a false statement.
What *Goldwasser*, *Micali* and *Rackoff* did was to turn the problem into: what
if instead Victor is malicious?

The specific concern they raised was about *information leakage*. Concretely,
how much extra information is Victor going to learn during the execution of the
protocol beyond the mere fact that the statement is true.

Obviously, in the context of `ZKP` protocols is assumed that Peggy knows some
*secret information* which she doesn't want to share with Victor.

The primary goal of Peggy in a *zero-knowledge proof* (`ZKP`) system is to
convince Victor that a certain fact is true, without revealing *any* additional
information.

Very naively, we may think that *any* additional information only consists of
specific details about *how* and *why* the proven statement is true, but the
requirement is much stronger as it includes **any** information that Victor is
not already capable of computing by himself and this also includes facts not
directly related to the proof.

More formally.

**Definition**. A proof system for a language `L` is **zero-knowledge** iff
`∀x ∈ L`, the *prover* shares with the *verifier* just that `x ∈ L` (i.e. one
bit of information).

The definition applies even when Victor is not honest and tries to trick (with
its polynomial time limits) Peggy.

Key characteristics of a `ZKP` system `(P,V)` for a language `L`:
- **completeness**: if `x ∈ L` then `V(x,π) = 1` with high probability;
- **soundness**: if `x ∉ L` then `V(x,π) = 1` with negligible probability.
- **efficiency**: the total computation time of `V(x,π)` and total communication
  in `(P,V)` is polynomial with respect to length of `x`.
- **zero-knowledgeness**: The proof does not reveal any additional information
  other than the fact that the statement is true.

Of most importance is the following theorem found in the [GMW] paper:

**Theorem (GMW)**. For any problem in `NP` there exist a `ZKP` system.

The theorem is the sweet consequence of the existence of a `ZKP` system for a
well known `NP` (TODO: link to the example).

### Proving *Zero-Knowledgeness*

The proof is based on the existance of what is known as a **simulator** and the
idea is quite similar to the one used to prove [*soundness*](#proving-soundness)
via the *extractor*.

A *simulator* is a tool which allows Peggy to convince any *verifier* that a
statement is true, and thus about the knowledge of some key information, when in
reality she doesn't possess any knowledge.

The key intuition here is: if regardless of how many rounds the protocol is
executed, Peggy is **always** capable of convincing Victor without knowing any
key information then the protocol doesn't leak any information to Victor as he
is not able to distinguish if Peggy posses any knowledge via the protocol.

As for the *extractor* the implementation of a *simulator* is based on rewinding
the Victor's execution in order to gain some advantage without him noticing.

From Victor's perspective, the *simulator* is statistically indistinguishable
from any real execution of the protocol.

### Commitment Protocols

The only cryptographic tool used in the `ZKP` systems proposed in this paper
is a **commitment protocol**

A commitment protocol allows one party, the sender, to commit to a value to
another party, the receiver, with the latter not learning anything meaningful
about the value.

Such a protocol consists of two phases.

The first is the commit phase, following which the sender is bound to some value v, while the
receiver cannot determine anything useful about v. In particular, this means that the receiver
cannot distinguish between the case v = b and v = b0 for all b and b0 . This property is called
hiding. Later on, the two parties may perform a decommit or reveal phase, after which the receiver
obtains v and is assured that it is the original value; in other words, once the commit phase has
ended, there is a unique value that the receiver will accept in the reveal phase. This property is
called binding.

In the digital world, commitments can be based on any one-way function and are fairly efficient
to implement. Both the computational complexity and the communication complexity of such
protocols are reasonable and in fact one can amortize the work if there are several simultaneous
commitments.

A very simple commitment scheme example for a value `x` is to generate some
random salt and share the value `c = Hash(salt || x)`. To open the commitment
the value of `x` and the salt is revealed. This is secure under the assumption
that the hash function is secure.

### Additional Takeaways

The protocol must run in an environment where the construction of both an
*extractor* or *simulator* is not possible. Allowing the construction of these
tools clearly breaks the proof *soundness* and *zero-knowledgeness*.

That is, if Victor is able to construct an *extractor* then it will be able to
extract knowledge from the proof, and thus voids *zero-knowledgeness.
If instead Peggy is able to construct a *simulator* then she will be able to
generate valid proofs without any knowledge, and thus voids *soundness*.

An important consequence is given that a re-played protocol breaks
*zero-knowledgeness* and *soundness* properties, that we can't use a recording
of the protocol execution to convince a third party about the authenticity of
a proof.

The third party has no way to tell if the recorded execution is genuine or if
the protocol steps were *edited* (which in practice is a way of rewinding the
execution).

Peggy is able to convince only Victor who actively participates by executing the
protocol interactively and in real-time.

This is often a feature of ZKP systems. Indeed, the pure definition of
interactive ZKP system Peggy wants to convince just Victor and not any third
party.

### Distinguishability for probability distributions

Consider the family of random variables `U = { U(x) }` where the parameter `x`
is from a language `L ⊆ {0,1}*`. All random variables take values in `{0,1}*`

Let `U` and `V` be two families of random variables. 

We sample a value `s` either from `U(x)` or `V(x)` and a judge should decide if
`s ∈ U(x)` or if `s ∈ V(x)`.

`U(x)` becomes **replaceable** with `V(x)` if the judge opinion becomes
meaningless as `x` length increases. That is, its opinion will be random.

There are two important parameters for the judge:
- the *size* of the sample `s`;
- the *time* he can take to decide.

Two families or random variables `U` and `V` are:
- **Equal**: if the judge verdict is meaningless regardless of the time he can
  take and the size of the sample.
- **Statistically indistinguishable**: if the verdict becomes meaningless if he
  has infinite time but only samples with polynomial size with respect to `|x|`.
- **Computationally indistinguishable**: if the verdict becomes meaningless if
  both time and samples size values are polynomial with respect to `|x|`.

For our purposes we'll consider **indistinguishable** any two families of random
variables which are computationally indistinguishable.

### Knowledge computable from a communication

Informally a communication conveys knowledge if it transmits outputs of an
infeasible computation, i.e. a computation which we cannot perform ourselves.

We want to derive an upper bound (in bits) for the amount of knowledge that a
polynomially bounded *verifier* can extract from the communcation.

Any Turing machine `M` generates the ensemble `M[·] = {M[x]: x ∈ I}`. Where
`M[x]` is the set of possible outputs of `M` for inputs `x ∈ I` taken with the
probability distribution induced by `M`'s coin tosses.

`(P,V)[·]` the ensemble associated to an interactive pair of Turing machines.

**Definition**. Let `(P,V)` be an interactive pair of Turing machines and `I`
the set of its inputs. Let `V` be polynomial time and `f: N → N` be a non-
decreasing function.

`P` communicates at most `f(n)` bits of knowledge to `V` if there exist a
probabilistic polynomial-time machine `M` such that the `I`-ensembles `M[·]` and
`(P,V)[·]` are at most `1-1/2^f(n)` distinguishable.

`P` communicates `f(n)` bits of knowledge if for all poly-time ITM's `V'`, `P`
communicates at most `f(n)` bits of knowledge of `V'`.

For example with `f(n) = 0` we have that are 0-distinquishable.

Example.

A crime has happened. `V` is a reporter and `P` is a police officer. `P` tries
to not communicate too much knowledge.

If the knowledge doesn't exceed 2 bits then the conversation that the reporter
will have with a police officer will be 3/4 distinguishable from a "real"
conversation about the crime. ????????

## Intuitive ZK Protocols

While "toy-examples" exists, keep in mind that *real world* proofs are generally
based on complex mathematical constructs and cryptographic primitives.

In this section we present some of the most intuitive examples of `ZK`
protocols. We start from the ones which doesn't require any technical knowledge
but at the same time are good to relay the intuition and the power of `ZK`
proofs.

Some of the examples protocols have a quite high soundness error `ε`, however
the protocols can be repeated indefinitely to increase the *verifier* confidence.

### Where is Waldo?

["Where is Waldo?"](https://en.wikipedia.org/wiki/Where%27s_Wally%3F) is a famous
kid's puzzle where, given a very detailed illustration with many different
characters the goal is to find Waldo, the main character.

The *prover* asserts he knows where Waldo is and should convince the *verifier*
without revealing any additional information.

A proof for the problem has been proposed by Naor and Reingold in their *"How
To Convince Your Children You Are Not Cheating"*[^NR] paper and consists of a
very simple and low tech protocol.

Given some illustration like:

![waldo-problem](/companions/zk-proofs/waldo-problem.png)

Original Protocol (NR):
- The *prover* covers the illustration with a big sheet of paper (bigger that
  the one with the illustration) which has a little hole in the center. The hole
  is positioned above Waldo in the illustration.
- The *verifier* accepts if he sees Waldo through the hole.

![waldo-zk-proof](/companions/zk-proofs/waldo-zk-proof.png)

Even if the verifier can't infer the position of Waldo in the illustration as its
relative position is not known, this (non-interactive) protocol is not really sound.
How can ensure the *verifier* that behind the cover there is the original
illustration and not just another illustration or just the Waldo face?

Extended Protocol:
- *Commitment*. The *prover* performs the same step as the original protocol
  with the hole in a random place and not in the center, then he covers
  everything with an even bigger sheet of paper, without any hole. The
  illustration should be at a distance from the border at least equal to the
  size of the white sheet of paper (to better hide relative positions during
  the proof).
- *Challenge*. The *verifier* toss a coin and depending on the result asks to
  *prover* either to show the illustration by removing **together* both the
  covers or to remove the bigger top cover to see Waldo face.
- *Response*. The *prover* performs the requested action.
- *Result*. The *verifier* accepts or reject based on the evidence.

This new protocol is both sound and zero-knowledge as is possible to construct
*an extractor* and a *simulator* for it.

In one run, the protocol has soundness error `ε = 1/2`.

### The Ali Baba Cave

This protocol is a classic when explaining the basics `ZKP` protocols and is
due to *Quisquater* and others in their paper *"How to Explain Zero-Knowledge
Protocols to Your Children"*[^QUI].

To summarize, the story is about Ali Baba and a cave with one entrance which in
the middle bisects in two. The two branches are in the end connected via a magic
door which opens with a magic spell. Ali Baba knows the spell and can prove it.

Protocol:
- *Commitment*. Ali Baba enters the cave while the *verifier* wait outside and
  takes one of the two paths, randomly.
- *Challenge*. The *verifier* enters the cave and goes to the bisection. Toss
  a coin and depending on the result will ask Ali Baba to come out from one of
  the paths.
- *Response*. Ali Baba satisfy the *verifier* request as, if required, he can
  open the magic door.
- *Result*. The *verifier* checks the expectation.

![ali-baba-cave](/companions/zk-proofs/ali-baba-cave.png)

In one run, the protocol has soundness error `ε = 1/2`.

Notice that Peggy could prove to Victor that she knows the magic word, without
revealing it to him, in a single trial. If both Victor and Peggy go together
to the mouth of the cave, Victor can watch Peggy go in through A and come out
through B. This would prove with certainty that Peggy knows the magic word,
without revealing the magic word to Victor. However, such a proof could be
observed by a third party, or recorded by Victor and such a proof would be
convincing to anybody. In other words, Peggy could not refute such proof by
claiming she colluded with Victor, and she is therefore no longer in control of
who is aware of her knowledge.

### Sudoku

The general problem of solving a Sudoku puzzle with `n²⨯n²` cells of `n⨯n`
blocks is known to be NP-complete.

Finding a solution to this problem is considered hard, while verifying it
is an easy task.

Given a Sudoku puzzle the *prover* wants to convince the *verifier* that he
knows the solution.

The protocol has been officially proposed by Ronen Gradwhol et.all in the
paper *Cryptographic and Physical Zero Knowledge Proof Systems for Solutons of
Sudoku Puzzles* [^GNPR]

There is a very good visual demonstration of the protocol at this [link](https://www.wisdom.weizmann.ac.il/~naor/PAPERS/SUDOKU_DEMO)

Protocol:
- *Commitment*. The *prover* places three cards on each cell. On filled-in cells
  of the puzzle he places three cards with the assigned value, faced up (this
  can be done by the *verifier* as well). On the rest of the cells the *prover*
  places the cards according to the solution, faced down.
- *Challenge*. For each row, column and subgrid, the *verifier* chooses (at
  random) one of the three cards of each cell in the corresponding row/column/
  subgrid and makes 27 packets out of the chosen cards (9 rows + 9 columns +
  9 subgrids).
- *Response*. The *prover* shuffles each of the 27 packets separately, and hands
  the shuffled packets to the verifier.
- *Result*. The *verifier* checks that in each packet all numbers appear.

The soundness error for this protocol is `ε = 1/9`. The proof is a bit involved
and not reported here.

The protocol is also zero-knowledge as for any verifier a simulator can be
easily constructed by first observing what are the *verifier*'s chosen cards
by then re-running the protocol with the cards positioned ad-hoc to pass the
verification step.

The puzzle can be easily expressed as a graph coloring problem. For example,
3⨯3 Sudoku is mapped to a graph with `81` vertices, one vertex for each cell.

The vertices are labeled with ordered pairs `(x,y)`, where `x` and `y` are integers
between `1` and `9`. Two distinct vertices labeled by `(x₁,y₁)` and `(x₂,y₂)`
are joined by an edge if and only if:
- `x₁ = x₂` (same column) or,
- `y₁ = y₂` (same row) or,
- `⌈x₁/3⌉ = ⌈x₂/3⌉` and `⌈y₁/3⌉ = ⌈y₂/3⌉` (same `3⨯3` block)

A valid solution assigns an integer between `1` and `9` (the colors) to each
vertex, such that vertices that are joined by an edge do not have the same
integer assigned to them.

Sudoku solution grid is also a [Latin square](https://en.wikipedia.org/wiki/Latin_square)
There are significantly fewer Sudoku grids than Latin squares because Sudoku
imposes additional regional constraints.

### Graph Three Coloring

The [problem](http://en.wikipedia.org/wiki/Graph_coloring) is about deciding if
a given graph vertices can be colored such that no two adjacent vertices have
the same color.

The protocol has been introduced by the Goldreich, Micali and Wigderson in (GMW2)
and allows proving that we know a solution to the three coloring in ZK.

The solution is independent of the specific colors.

Protocol:
- *Commitment*. The *prover* draws the graph, assigns to the solution the colors
  randomly and covers the vertices with hats.
- *Challenge*. The *verifier* asks the *prover* to reveal the color of two
  adjacent vertices of its choice.
- *Response*. The *prover* will reveal the colors behind the chosen vertices.
- *Result*. If the colors are not equal the *verifier* accepts.

Given a graph with `E` edges, the soundness error probability is `ε = (E-1)/E`.
As usual, this value can be reduced arbitrarily by repeating the protocol.

For example, if `E = 1000` and the *verifier* wants `ε < 0.1` then the protocol
should be iterated for `k` rounds where `(999/1000)ᵏ < 1/10` → `k > 2301`.

As for the *verifier*, even if he takes notes between runs, there is no way for
him to link the data as on each run the colors are randomly assigned according
to the solution.

You can find a nice app showing this proof in action [here](http://web.mit.edu/~ezyang/Public/graph/svg.html).

### Proofs for all NP

The problems proofs presented above may not be very interesting per-se but
some of them, such as the *graph three coloring problem* are well known NP-
complete problems.

What this means is that **any other** NP problem can be translated to an
instance to the three-coloring problem, and thus there exist a ZK-proof for any
problem in NP.

Obviously, the naive approach of taking an NP problem and translating it to
the three-coloring problem to provide a ZK-proof works but is very expensive
and for some problems more specialized solutions exists.

(TODO: remove...) The transformation of an NP problem to the graph is probably
performed by first mapping the problem into a boolean circuit which is satisfied
iff we know the correct input. The circuit is then mapped into a graph.

## More Abstract ZK Protocols

### Graph Isomorphism

A more abstract example of a `ZKP` is the *Graph Isomorphism Problem* (`GI`).

Two graphs `G₀` and `G₁` are isomorphic if there is a bijective mapping `f: G₀ →
G₁` such that for all the edges `(v,w) ∈ G₀` iff `(f(v),f(w)) ∈ G₁`.

If two graphs are isomorphic, find an isomorphism problem is in `NP` but, at the
current state of knowledge, not `NP`-complete.

In this context, the *prover* wants to prove that two graphs `G₀` and `G₁` are
isomorphic without revealing the mapping `G₁ = f(G₀)`.

The proposed protocol has been introduced by the Goldreich, Micali and Wigderson
([GMW2]) and uses a permutation of the vertices `π` as the bijective mapping.

Protocol:
- *Commitment*. The *prover* choses a random `a ∈ {0,1}`, a random permutation
  `π₀` and sends `H = π₀(Gₐ)` (permutation of `G₀` or `G₁`) to the *verifier*.
- *Challenge*. The *verifier* choses a random `v ∈ {0,1}` and sends it to the *prover*.
- *Response*. The *prover* sends a permutation `π₁` such that `π₁(H) = Gᵥ`.
- *Result*. The *verifier* checks if `π₁` gives the expected result.

For one single protocol run the soundness error is `ε = 1/2`.

- *Completeness*: if `G₀` and `G₁` are isomorphic then doesn't matter what `bᵥ`
  is, the *prover* will always send a valid permutation.
- *Soundness*: the *verifier* constructs an *extractor* by sending `bᵥ = 0`,
  to get `π₁` which maps `H` to `G₀`. Then he re-execute from the *challenge*
  by sending `bᵥ = 1`, to get `π₁'` which maps `H` to `G₁`. He then recovers the
  isomorphism permutation from `G₀` to `G₁` as `π = π₁·π₁'`.
- *Zero knowledgeness*: the *prover* constructs a *simulator* which sends
  `H = π₀(G₀)`, if the *verifer* sends `bᵥ = 1` he re-executes the protocol by
  sending `H = π₀(G₁)`.

### Graph Non-Isomorphism

The `GNI` problem is the complement of `GI` problem, thus is in `co-NP` (note
that at the current state of knowledge is not known whether `NP = co-NP`, that
is a complement of a problem in `NP` may not be in `NP`).

Unlike the `GI` problem, where if we ignore the `ZK` property, it can be solved
using a traditional proof system by simply sharing the permutation `π` to map
`G₀` to `G₁`, the `GNI` problem based on our current knowledge is not in `NP`
and can't be solved without an `IP` system.

To prove the graph non-isomorphism, the *prover* uses its infinite resources.

Protocol:
- *Challenge*. The *verifier* choses a random `a ∈ {0,1}`, a random permutation
  `π` and sends `H = π(Gₐ)` to the *prover*.
- *Response*. The *prover*, using its infinite computing power can infer
  if `H` is a permutation of `G₀` or `G₁` (can't be of both as they are not
  isomorphic). Thus sends to the *verifier* the bit `b`
- *Result*. The *verifier* accepts if `a = b`.

For one single protocol run the soundness error is `ε = 1/2`.

Note that this protocol doesn't make use of a commitment and indeed its `ZK`
property is a bit flawed. The *verifier* can send any random `H` and use the
*prover* as an oracle to understand if is a permutation of one of the two
graphs.

Is essential that the randomness `(a, π)` of the *verifier* is hidden from the
*prover*. Otherwise, the soundness of the protocol will fall apart as well.

### QR Protocol

The *verifier* wants to prove that `x ∈ Zn*` is a quadratic residue given that
he knows `w ∈ Zn*` such that `w² = x`.

Protocol:
- *Commitment*. Peggy chooses a random `r ∈ Zn*` and sends `y = r²`.
- *Challenge*. Victor tosses a coin, chooses `b ∈ {0,1}` and sends it.
- *Response*. If `b = 0` then Peggy sends `z = r` else she sends `z = r·w`.
- *Result*. Victor accepts if:
  - `b = 0` and `z² = y`, or
  - `b = 1` and `z² = x·y`

For on run, the soundness error probability is `ε = 1/2`.

- *Completeness*. If `x` is a quadratic residue then Victor will be definitely
  convinced.
- *Soundness*. Victor can construct an *extractor* which rewinds the protocol
  execution to send to Peggy both `1` and `0` for the same run. It will thus
  acquire both `r` and `r·w` which allows recovering `w = r⁻¹·(r·w)`.
- *Zero Knowledge*. Peggy can construct a *simulator* such that if Victor's
  challenge is `1`, then rewinds the protocol execution, uses as *commitment*
  `y = r²·x⁻¹` and as challenge *response* `z = r`.
  In this way `x·y = x·(r²·x⁻¹) = r² = z²` satisfies Victor's check.

## Cryptographic ZK Protocols

We finally reached the section where we can apply what we've seen so far to a
practical real-world protocol which in the end leads to one of the most used
digital signature schemes in use today.

### Schnorr's Protocol

A proof of knowledge invented by *Claus-Peter Schnorr* in the 1980s which is the
basis of many modern signature schemes.

The context is in the realm of public key cryptography that relies on the
hardness of the discrete logarithm problem.

Given a cyclic group `G` with prime order `q` and generator `g`, Peggy wants to
prove to Victor that he knows the discrete logarithm `x ∈ Zq*` for some number
`y = gˣ ∈ G` without revealing any additional information.

Protocol:
- *Commitment*. Peggy picks a random `k ∈ Zq*` and sends `r = gᵏ`.
- *Challenge*. Victor picks a random `c ∈ Zq*` and sends it.
- *Response*. Peggy computes `s = x·c + k mod q` and sends it.
- *Result*. Victor accepts if `yᶜ·r = gˢ = g^(x·c + k)`.

Security considerations:
- Peggy can't cheat as the only way to construct a valid `s` is to know `x`. If
  the challenge `c` is sent before `r` then he can easily cheat by constructing
  `r = gˢ·y⁻ᶜ mod q` for any arbitrary `s`. But this is not allowed since he
  requires to first commit the value `r` before he knows `c`.
- Victor can't infer the value of `x` as it only receives `r`, an apparently
  random value, and `s`. To extract `x` from `s` he must compute `x = (s - k)·c⁻¹`.
  But this requires to compute the discrete logarithm of `r` which is considered
  unfeasible.

More formal versions of the core properties follows.

#### Soundness Proof

Victor needs to construct an **extractor**. If he's able to rewind Peggy
execution to the challenge step after she performed the response step then an
extractor is constructed by sending Peggy a different challenge `c₂` to trick
her to create a different `s₂` using the same value for `k`:

    s₁ = x·c₁ + k mod q
    s₂ = x·c₂ + k mod q

    → s₁ - s₂ = x·(c₁ - c₂) mod q
    → x = (s₁ - s₂)·(c₁ - c₂)⁻¹ mod q

**Security Note**. The soundness proof shows a very important assumption for
the protocol soundness. Peggy must **never reuse the same value for `k`** in two
different runs of the protocol, as otherwise her secret can be easily recovered.

#### Zero-Knowledgeness Proof

We need to construct a **simulator**.

If Peggy can rewind Victor's execution after he shared the challenge `c` then
she can easily convince him without knowing the secret by committing a value `r`
computed as:

    r = gˢ·y⁻ᶜ mod q

For any arbitrary value `s`.

Victor is convinced as: `yᶜ·r = yᶜ·gˢ·y⁻ᶜ = gˢ`

The proof assumes that the *verifier* is honest (**HVZK**), which in this
context means that `c` is not chosen in function of the value `r`. If this is
the case, then `y^f(r)·r = yʷ·r = yʷ·gˢ·y⁻ᶜ ≠ gˢ` and thus the *simulator*, as
we've defined it, doesn't work as the simulation is no longer indistinguishable
from the real transcript.

Some stronger `ZKP` systems are zero-knowledge even when the verifier is
malicious.

### Non-Interactive Schnorr's Protocol

Interactive protocols add some non-negligible overhead as they require several
messages (potentially over the network) and add unbounded delays, unless the
two participants are online at the same time. Due to this, a non-interactive
protocol is often preferable.

Turning the *Schnorr* protocol into a non-interactive proof seems initially quite
difficult, since it fundamentally relies on Victor picking a true random
challenge. But in practice there is a smart trick we can use.

In the 1980s, *Amos Fiat* and *Adi Shamir* developed a technique [FS] to convert
an interactive protocol to a non-interactive proof in the random oracle model.

The technique is popularly known as the [Fiat-Shamir heuristic](https://en.wikipedia.org/wiki/Fiat%E2%80%93Shamir_heuristic)
or transformation.

We move the proof system to what is known as the *Random Oracle Model* (ROM),
an "imaginary" environment where the randomness source is replaced with a
cryptographically secure hash function output.

The ROM introduction is quite
[controversal](https://blog.cryptographyengineering.com/2011/09/29/what-is-random-oracle-model-and-why-3/)
but has successfully used in practice for quite a while and to implement a
lot of strong cryptographic primitives. The assumption is that the Peggy can't
predictably control the hash output in any way.

The idea is to replace the *verifier*'s random challenge `c` with the output of
a cryptographically secure hash function `H`, which is modeled as a random
oracle, with input the prover random value `r`.

Protocol:
- Peggy picks a random `k ∈ Zq*` and computes `r = gᵏ`.
- Peggy computes the challenge `c = H(r) ∈ Zq*`.
- Peggy computes `s = x·c + k mod q`.

Any *verifier* accepts if `yᶜ·r = gˢ = g^(x·c + k)`.

The theoretical repercussion of this protocol is that it completely breaks the
assuptions used by the soundness and zero-knowledgeness proofs of Schnorr protocol.

The good news is that the proof still hold in the ROM. For the sake of the
proof, when constructing the *extractor* and the *simulator* the random oracle
can be programmed.

**Implications to Soundness**

The interactive *extractor* relies on the fact to be able to generate two different
challenges `r` for the same commitment `c`. This doesn't apply here as `c = H(r)`.

The proof still holds in the ROM, where the *extractor* programs the oracle
to return two different values `c₁` and `c₂` for the same challenge `r`.

**Implications to Zero-Knowledgeness**

The interactive *simulator* relies on the fact to be able to get the same challenge `r`
for two different commitments `r₁` and `r₂`. This doesn't apply here as `c = H(r)`.

The proof still holds in the ROM, where the *simulator* programs the oracle
to return the value of choice `c` (thus not in function of `r`).

Obviously the ROM is a trick which helps to restore the proof validity in an
imaginary world, in the real world the random oracle is implemented with a
(non-programmable) cryptographically secure hash function such as SHA-256.
This is why the ROM is loved and hated at the same time by cryptographers.

#### Schnorr Signature Scheme

The Schnorr NIZK proof can be easily transformed into a signature scheme by
binding a message `m` to the challenge `c`:

    c = H(r || m)

The rest of the scheme works as the Schnorr NIZK proofs

### Zero Knowledge Proofs of Computation

DRAFT

We could also prove the correct execution of any program even if we removed
some of the inputs or outputs.

General-purpose ZKPs allow Peggy to convince Victor about the integrity of
an execution trace (the inputs of a program and the outputs obtained after
its execution) while hiding some of the inputs or outputs involved in the
computation.

An example of this is a Prover trying to prove that a sudoku can be solved.

TODO: some notes about ZK-SNARKs and its bleeding edge applications.

Outsourcing of computation. Outsource an expensive computation and validate that
the result is correct without redoing the execution. This opens up a whole new
category of trustless computing.

#### Applications In Blockchain context

- Anonymous ring signatures
- Fast chain synching
- Light clients verification



## Appendix

### Relationship to Entropy (mia idea ... sbagliata?)

We can express ZK proofs using entropy.

If `s` is some secret information and `H(s)` is the entropy associated to its
value. Then a proof `p` is zero knowledge if `H(s) = H(s|p)`.

That is, the proof doesn't leak any bit of information.

The mutual information is thus `I(s;p) = H(s) - H(s|p) = 0`.

### Complexity Classes

**NP-complete** problems are a set of problems to each of which any other
NP problem can be reduced in polynomial time and whose solution may still be
verified in polynomial time.

Informally, an NP-complete problem is an NP problem that is at least as "tough"
as any other problem in NP.

The first natural problem proven to be NP-complete was the Boolean
satisfiability problem, also known as SAT (Cook–Levin theorem).

**NP-hard** problems are those at least as hard as NP problems; i.e., all NP
problems can be reduced (in polynomial time) to them. NP-hard problems need not
be in NP; i.e., they need not have solutions verifiable in polynomial time.

Zero Knowledge relies on the notion of NP completeness, as well as the view of
NP as a proof system.

#### P ≠ NP

The relation between the complexity classes P and NP is studied in computational
complexity theory, the part of the theory of computation dealing with the
resources required during computation to solve a given problem. The most common
resources are time (how many steps it takes to solve a problem) and space (how
much memory it takes to solve a problem).

### Random Oracle Model

TODO: some notes inspired by Matthew Green article


## Insights to integrate

Proving an NP-statement `x` is equivalent of saying that `x ∈ L` with `L` a
language such that `L ⊆ NP`.

One of the most important innovation which IP brings to the table is not about
proving new problems which doesn't have a proof in NP (indeed most of the
interesting problems already have a *static* proof in NP) but is about how much
knowledge is shared between the *prover* and the *verifier*.

Coin flip ≡ read next bit from random tape

Rename Alice(A), Bob(B) to Peggy(P)/Victor(V)

IP. def ...
P and V take turns being active. V is active first

[GMW] every language in NP has an IP system NP ⊂ IP

Example of a language in IP but not known to be in NP is the "graph nonisomorphism" ([GMW]).

AM ⊆ IP is immediate since in IP the *verifier* can send to the *prover* an arbitrary function
of the randomness source output f(R) while in AP is only allowed to send f(R) = R.

[GS] proven that AM = IP. All languages with an interactive proof with private
coins (IP) also have an interactive proof with public coints (AM.)

Conjecture. Though the ability to make secret random choices doesn't allow
recognizing more languages but seems crucial to recognize languages in ZK.

ZK: Given any *verifier* B', the distribution that B' sees on its tapes is
indistinguishable from a distribution which can be computed from input x in
polynomial time.

### Applications

- [A zero-knowledge protocol for nuclear warhead verificaiton](https://www.nature.com/articles/nature13457)
- Voting: completely transparent vote counting
- Identification protocols: originating from work of Fiat and Shamir.
  An alternative approach is through digital signatures (TODO: WHY DIG SIG are not ZK)


## Lightweight Readings

- [Zero Knowledge Proofs - An Illustrated Primer](https://blog.cryptographyengineering.com/2014/11/27/zero-knowledge-proofs-illustrated-primer) - Matthew Green (2014)

- [What is the Random Oracle Model and why should you care](https://blog.cryptographyengineering.com/2011/09/29/what-is-random-oracle-model-and-why-3/) - Matthew Green (2011)

- [Zero Knowledge Proofs](https://www.cs.princeton.edu/courses/archive/fall07/cos433/lec15.pdf) - Boaz Barak (2007)

- https://zkproof.org/

- https://github.com/ZeroKnowledgefm/ZeroKnowledgeBasics

## References

- [GMR85] S.Goldwasser, S.Micali, C.Rackoff - [The Knowledge Complexity of Interactive Proof-Systems](https://people.csail.mit.edu/silvio/Selected%20Scientific%20Papers/Proof%20Systems/The_Knowledge_Complexity_Of_Interactive_Proof_Systems.pdf).

- [BAB85] L.Babai - [Trading group theory for randomness](https://dl.acm.org/doi/10.1145/22145.22192).

- [GS] S.Goldwasser and M.Sipser - [Private coins versus public coins in interactive proof systems](https://pages.cs.wisc.edu/~jyc/710/Goldwasser-Sipser.pdf). In Proceedings of the eighteenth annual ACM symposium on Theory of computing, pages 59–68. ACM, 1986.

- [GMW] [Goldreich Micali Wigderson]...how to play any mental game?

- [GMW2] O.Goldreich, Silvio Micali, Avi Wigderson. [All Languages in NP Have Zero-Knowledge Proof Systems](https://www.researchgate.net/publication/220431215_Proofs_that_Yield_Nothing_But_Their_Validity_for_All_Languages_in_NP_Have_Zero-Knowledge_Proof_Systems). (1991)

- [QUI] [How to Explain Zero-Knowledge Protocols to Your Children](https://www.researchgate.net/publication/221355016_How_to_Explain_Zero-Knowledge_Protocols_to_Your_Children) - Kean-Jacques Quisquater et.all (1989)

- [PET] [Why and How zk-SNARK Works](https://arxiv.org/pdf/1906.07221.pdf) - Maksym Petkus (2019)

- [BFM88] Manuel Blum, Paul Feldman, and Silvio Micali. [Non-Interactive Zero-knowledge and Its Applications](https://dl.acm.org/doi/10.1145/62212.62222).

- [WAL] Moni Naor, Yael Naor, Omer Reingold. [How to Convince Your Children You Are Not Chaeating](http://www.wisdom.weizmann.ac.il/~naor/PAPERS/waldo.pdf) (1999).

- [FS] Amos Fiat, Adi Shamir. [How To Prove Yourself](https://link.springer.com/chapter/10.1007/3-540-47721-7_12)

- [LFKN] C. Lund, L. Fortnow, H. Karloff, and N. Nisan. Algebraic methods for interactive proof systems. In Proceedings of the 31st Annual Symposium on Foundations of Computer Science, pages 2–10. IEEE, 1990.

- [SH] A. Shamir. IP = PSPACE. In Proceedings [1990] 31st Annual Symposium on Foundations of Computer Science, pages 11–15. IEEE, 1990.

- [NR] M.Noar, Y.Noar, O.Reingold - [How to Convince Your Children You Are Not Cheating](https://www.wisdom.weizmann.ac.il/~naor/PAPERS/waldo.pdf)

- [GNPR] R.Gradwhol, M.Naor, B.Pinkas, G.Rothblum - [Cryptographic and Physical Zero Knowledge Proof Systems for Solutons of Sudoku Puzzles](https://link.springer.com/article/10.1007/s00224-008-9119-9)
