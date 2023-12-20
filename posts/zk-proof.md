+++
title = "Zero-Knowledge Proofs"
date = "2023-08-06"
modified = "2023-12-20"
tags = ["cryptography", "zk-proof"]
toc = true
draft = true
+++

Version - v0.1.20

## *Abstract*

Zero-Knowledge Proofs (ZKP) represent a fascinating and influential concept
within the realm of cryptographic protocols. 

At a glance, a ZKP enables one party to demonstrate the correctness of a
statement to another party without revealing any details beside the validity of
the claim itself.

ZKPs find applications in various areas, including secure authentication
protocols, blockchain systems, and secure computation, among others.

Another motivation is philosophical. The notion of a proof is basic
to mathematics and to people in general. It is a very interesting and
fascinating question whether a proof carries with it some knowledge or not.

In this discussion we will go from the most classic mathematical notion of
proof down to proofs which shares zero knowledge.

---

## Classical Proofs

### Introduction to Deductive Reasoning

Deductive reasoning is a fundamental method of logical thinking used across
various disciplines, from philosophy and mathematics to computer science and
law.

It involves deriving specific conclusions from a set of general premises
or known facts. The strength of deductive reasoning lies in its ability to
guarantee the truth of the conclusion, provided the premises are true and the
reasoning process is logically sound.

One of the earliest examples of deductive reasoning can be traced back
to ancient Greek philosophers, particularly *Aristotle*, who formalized the
syllogistic reasoning. A classic example of a syllogism is:

1. All men are mortal (general premise).
2. Socrates is a man (specific premise).
3. Therefore, Socrates is mortal (conclusion).

This example captures the essence of deductive reasoning: if the premises are
true and the reasoning is valid, then the conclusion must also be true.

### Deductive Reasoning in Mathematics

In the realm of mathematics, deductive reasoning takes on a more structured
form known as a mathematical proof.

A **mathematical proof** is a logical argument presented in a systematic way
to verify the truth of a mathematical *statement*. Here, deductive reasoning
is used to derive conclusions from a set of *axioms* (self-evident truths) and
previously established *theorems* (proven statements) by using some *inference
rules* which can be applied in the specific context.

By setting the *conclusion* as the statement we want to prove and the *premises*
as the set of *axioms* and previously proven *theorems*, we can define a proof
as a finite length string encoding the set of logical derivation that
incrementally drives from the premises to the conclusion.

As all the proof reasoning rely on the basic properties of boolean algebra, it
is implicit that Boolean logic axioms and theorems holds as premises for any
reasonable proof systems which we'll analyze in the context of this document.

### Proofs Soundness

A proof is **valid** if the conclusion logically follows the premises,
regardless of whether those promises are true or not.

A proof is **sound** if is valid and all of its premises are true.

Example. Sound proof.

- *Premises*:
  - `A`, `B` and `C` are three sets such that `A ∩ B ⊆ C`;
  - `x ∈ B`;
  - basic properties of set theory hold;

- *Conclusion*: `x ∉ A \ C`.

- *Proof*: 
  - `x ∉ A \ C = ¬(x ∈ A ∧ x ∉ C) = x ∉ A ∨ x ∈ C = x ∈ A → x ∈ C`
  - `A ∩ B ⊆ C ∧ x ∈ B ∧ x ∈ A  →  x ∈ C`

Example. Valid but not sound proof:

- *Premises*:
  - All prime numbers are odd (wrong premise).
  - 2 is a prime number (as it has no divisors other 1 and itself)
- *Conclusion*: 2 is odd
- *Proof*: conclusion follows directly from premises.

As you can see, since the conclusion can be derived from the premises, the proof
is formally correct, but as the second premise is not incorrect it is not sound.

The example emphasize how we can reach incorrect conclusions even though we
constructed an apparently correct proof just because of a bad premise.

### Proof Systems

A **proof system** is a formal and systematic (algorithmic) approach to
construct and evaluate proofs.

It typically consists of the following key components:

- **Statement (x)**: assertion under consideration. It is the proposition that
  one tries to prove or disprove.

- **Proof (π)**: set of arguments, evidence, or logical steps that, when
  processed by the proof system, should establish the validity of the statement.

- **Prover (`P`)**: algorithm to construct a proof for the given statement
  (`P(x) = π`).

- **Verifier (`V`)**: algorithm that, given both the statement and the proof,
decides whether the proof is valid. This algorithm outputs `1` if the proof is
correct and `0` if the proof is not correct (`V(x,π) = 0|1`).

Clear rules and guidelines are essentials when we need to move proof
construction and checking from the often ambiguous and nuanced domain of natural
languages to the precise realm of formal languages.

Though this discussion, we'll mostly adhere to the popular convention of
referring to the *prover* as Peggy and the *verifier* as Victor.

### Knowledge Sharing

In a *classical* proof system a proof that some assertion is true inherently
reveals *why* it is true. This aspect is deeply bound with how the classical
mathematical proof systems works: *Peggy* shares all the logical steps to allow
*Victor* to independently reach the same conclusion.

Follows that the proof provides more knowledge than just the mere fact that the
statement is true, which is what Peggy and Victor are interested in the first
place, regardless of the way this is proven.

For instance, consider the task of proving knowledge of the factorization of
a natural number `n`, Peggy could simply provide the list of its prime factors
`{pᵢ}`. Victor can efficiently check if `n = ∏ᵢ pᵢ`. In the end, not only
Victor is convinced about our statement, but he also gains knowledge the
factorization of `n`.

The information which facilitates the construction of the proof is known as
the **witness**. In a classical proof system, sharing the witness with
the verifier equates to providing a standard proof. However, if the witness
remains confidential, the proof is known as a Zero-Knowledge(`ZK`) proof.

### Formalization and Relationship to Complexity Theory

As proof systems transition into the domain of computational machines, it
becomes crucial to define a non-ambiguous method for analyzing their complexity,
including the resources required for proving and verifying the problems.

Find a clear relationship between proof systems and important complexity classes,
such as `NP`, is essential for understanding the tractability of some problems
in terms of proof construction and verification.

In computational theory, problems are often associated with languages over
specific alphabets. This association helps to formalize and understand the
range of problems that computers can solve.

Many interesting problems are formulated as **decision problems**, where the
answer is either *true* or *false*. These problems can be associated with
languages where strings represent instances of the problem, and membership in
the language indicates a positive answer (*true*), while non-membership indicates
a negative answer (*false*).

Consider the *Subset Sum Problem* (SSP) as an example. The core question is
whether there is a subset of integers that adds up to a target `t`.

The problem can be represented as the language:

    L = { x = (S,t) | S ⊆ ℕ and ∃ V ⊆ S: sum of elements in V equals t }

In this language, a pair `x = (S,t)` (a string) belongs to the language `L`
if and only if satisfies the language condition, i.e. there is a subset of `S`
which adds up to `t`.

Key characteristics of proof system `(P,V)` for decision problems:
- **Completeness**: `x ∈ L` if and only if `V(x,π) = 1`;
- **Soundness**: `x ∉ L` if and only if `V(x,π) = 0`;
- **Efficiency**: `V(x,π)` runs in polynomial time with respect to length of `x`.

Since each problem belongs to a complexity class, once we mapped the problem
to a language, we implicitly associated the language to the same complexity
class. For instance, a language `L` belongs to `NP` if a solution to the
problem associated to `L` can be verified by a deterministic *Turing* machine
in polynomial time, even though finding the solution itself (constructing the
proof) may be a way more computationally intensive task.

---

## Interactive Proofs

An **interactive proof (IP)** system extends the classical notion of proof
system by transitioning from a proof conceived as a *static* sequence of symbols
to an *interactive protocol* where Peggy incrementally convinces Victor by
actively exchanging messages.

The concept was first proposed in the mid-1980s by *Shafi Goldwasser*,
*Silvio Micali*, and *Charles Rackoff* in their seminal paper "The Knowledge
Complexity of Interactive Proof Systems" [GMR85]. This paper not only
introduced interactive proofs but also presented the first formal definition of
zero-knowledge proofs.

Is worth noting that Laszlo Babai independently contributed to the development
of this field approximately during the same period with his paper "Trading Group
Theory for Randomness"[^BAB].

In `IP` systems, the complete ordered sequence of messages exchanged during the
protocol is referred to as the **transcript**. Two runs of the same protocol
can result in different transcripts. This variability depends on whether the
protocol is deterministic or probabilistic.

### Sigma Protocols

Any `IP` system with a transcript composed of four messages is called a *sigma
protocol*.

The name of the protocol is inspired by the Greek letter `Σ`, which shape
mirrors the sequence of the protocol's steps:
1. *Commitment*: Peggy initiates the protocol by sending the first message.
2. *Challenge*: Victor responds by issuing a challenge to Peggy.
3. *Response*: Peggy replies to the Victor's challenge.
4. *Result* (optional): Victor sends a message with the verification outcome.

![sigma-protocol](/companions/zk-proofs/sigma-protocol.png)

The names of these steps were chosen to reflect their functional roles in
the execution of typical proofs, particularly in the `ZK` context. For the
moment the detailed mechanics and purpose of each step are left open.

This type of protocols is the most widespread when comes to `ZKP`, indeed
every protocol which will be analyzed in the `ZKP` examples section is a *sigma
protocol*.

For completeness, note that some sources describe sigma protocols with just
three messages, excluding the optional fourth "result" step.

### Deterministic Interactive Proofs

A **deterministic** `IP` is an interactive proof which doesn't introduce any
randomness in the protocol messages. In such a system, Victor asks questions and
Peggy is expected to always reply with the same answers.

As an example, consider the protocol where Peggy wants to prove that she
knows that a number is the product of two primes.

Using a transcript similar to the sigma protocol:
1. *Commitment*: Peggy asserts she knows the factors of a number `N`.
2. *Challenge*: Victors asks for the smaller (or the bigger) factor.
3. *Response*: Peggy sends the smaller (or the bigger) factor.
4. *Result* (optional): Victor accepts or reject.

![deterministic-ip](/companions/zk-proofs/deterministic-ip.png)

The verification of the proof is quite simple and fast:
- compute `y = ⌈N / x⌉` 
- check if `N = x·y`
- check if both `x` and `y` are primes via some deterministic algorithm
  (can't use a probabilistic algorithm as the verification result
   should be deterministic).

> **Every deterministic `IP` can be trivially mapped into a static classic proof
and vice versa.**

To convert a static proof into a deterministic `IP`, the two parties can just
communicate to incrementally transfer one or more chunks of the proof. Note that
a static proof is essentially a deterministic IP with a single message exchange.
This mapping is not very interesting.

To convert a deterministic `IP` to a static proof is sufficient for the *prover*
to construct a single string encapsulating the entire protocol transcript. This
construction is feasible because of the deterministic nature of the transcript,
where every message sent by Victor is predictable. Victor, just have to check if
the set of messages in the transcript is consistent with the expected ones.

![deterministic-ip2](/companions/zk-proofs/deterministic-ip2.png)

From this last result follows that deterministic `IP` systems are not more
powerful than static proofs with respect to the set of languages that can be
proven.

Due to the limited interest in deterministic `IP`s, we will save formal
definitions for the next chapter.

### Probabilistic Interactive Proofs

In the probabilistic version of the proving system, the steps mirror those of
the deterministic counterpart, but with additional elements of randomness
introduced by either the prover, the verifier, or both.

The introduction of randomness into the protocol can, in some scenarios, lead
to more efficient proofs or enable to prove en entire new class of languages
which can't be proven using deterministic proof systems.

As outlined in the seminal GMR paper:
- Peggy is assumed to have unbounded computational resources, while Victor
  operates within polynomial time constraints relative to the size of the
  statement to prove.
- Given Victor's polynomial computational limitations, the number of messages
  exchanged between the two must also be polynomial.
- Both Peggy and Victor have access to a **private** random generator.

More formally.

> A probabilistic `IP` system for a language `L` is a protocol `(P,V)`
for communication between a computationally unbounded machine `P` and a
probabilistic polynomial time machine `V` taking an input statement `x`, a
message history (`hᵢ`) and randomness source (`r`) to produce the next protocol
message:

    m₁ = V(x, rᵥ, h₁={})
    m₂ = P(x, rₚ, h₂={m₁})
    m₃ = V(x, rᵥ, h₃={m₁,m₂})
    ...

As a shortcut, from now on we'll refer to *probabilistic interactive proof*
systems just as *interactive proof* (`IP`) systems.

Key characteristics of an `IP` system `(P,V)` for a language `L`:
- **Completeness**: If `x ∈ L`, then `V(x,π) = 1` with probability at least `1-ε`.
- **Soundness**: If `x ∉ L` then `V(x,π) = 1` with probability at most `ε`.
- **Efficiency**: Both the total computation time of `V(x,π)` and the overall
  communication in `(P,V)` is polynomial with respect to length of `x`.

The parameter `ε` represents a cap on the *verifier*'s error probability,
an is popularly known as the **soundness error**.

If for a single protocol execution `ε < 1`, then we can always derive another
protocol which executes the original one `k` times consecutively, thus
exponentially reducing the error probability to an arbitrary value `εᵏ`.

For instance, if `ε = 1/10`, executing the protocol `5` times would reduce the
error probability to `ε⁵ = 1/100000`, allowing Victor to accept with a
probability of `0.99999`.

Constructing a static proof for some problems can be significantly more
challenging. This is partly because the *prover* has to answer in advance to all
the possible questions from Victor and encapsulate all the potential Peggy's
responses in one single message. This is not always possible given the
polynomial nature of the verifier.

As we'll see later, there is an entire class of problems which cannot be
practically proven via static proofs.

#### Proving Completeness

Completeness is quite easy to prove.

If Peggy knows the solution to a problem, she will eventually convince Victor
as its responses during the repeated protocol executions will be always correct
regardless of the number of repetitions and the value of `ε`.

#### Proving Soundness

Soundness is a bit more challenging to prove.

A proper proof of protocol soundness generally requires an **extractor**, a
hypothetical tool tailored for the specific protocol which allows Victor to
extract key information used by Peggy to construct the proof.

Imagine Victor being capable of 'rewind' Peggy's execution without her
knowledge. In such a case, Peggy would re-execute the protocol exactly as
before, even using the same random values as in the previous execution.
From Peggy's perspective, these executions would appear statistically
indistinguishable.

If under these conditions Victor is able to recover some information which
allows him to construct a valid proof then the protocol is sound.

The intuition here is that it is statistically impossible for a dishonest Peggy
to disclose crucial information without actually possessing it. Should would
require an extraordinary stroke of luck to fabricate this information out of
thin air.

It is important to note that the extractor is a theoretical construct, not meant
to be present in any real-world execution of the protocol. For example, if the
environment is the *real world*, it could be something like a "time machine". In
the *digital world*, it could be the capability to snapshot and restart a *prover*
state at any point.

### Interactive Turing Machines

Let's invest some time formalizing a bit further the execution environment for
the interactive proofs, i.e. the interactive proof system. 

> An **Interactive Turing Machine** (`ITM`) is a *Turing* machine with a
read-only input tape, a read-write work tape, a read-only random tape, a
read-only communication tape and a write-only communication tape.

In an `IP` system, both the *prover* (`P`) and the *verifier* (`V`) are defined
as `ITM` who share the same input tape, which generally contains the encoded
assertion to be proven.

The read-only communication tape of one machine is defined to be the write-only
communication tape of the other machine. This type of tape is used to exchange
protocol messages.

![ITM](/companions/zk-proofs/ITM.png)

During the proving protocol, the two machines take turns in being active.

With each protocol step, the `ITM` utilizes all its readable tapes as inputs
for internal computations. It then writes the resulting output to the write-only
communication tape (which corresponds to the read-only input of the other
machine).

The final message of every reasonable protocol goes from `P` to `V`, which can
then accept or reject the proof.

Consistent with our earlier discussions, `P` is considered to have unlimited
computational resources, while `V` operates under a computational constraint,
which are polynomially bounded by the size of the assertion being proved.

### Interactive Proof Computational Complexity Class

In this section, we give a small insight about the complexity class associated
with `IP` systems. This topic is highly theoretical and falls somewhat outside
the primary focus of this document.

> The `IP` complexity class is defined as a class of languages for which there
exists an `IP` system whose proofs can be verified in polynomial time with
respect to the length of the statement to prove.

    IP = { L | L has an interactive proof }

This class can be further divided based on the protocol's characteristics. For
instance, `IP[k]` denotes the class of languages that can be decided by an
interactive proof with `k` rounds.

At the beginning of 90s, Carsten Lund, Lance Fortnow, Howard Karloff and Noam
Nisan [LFKN] proved that `PH ⊂ IP`, which shows that interactive proofs can be
very powerful as they contain the union of all complexity classes in *polynomial
hierarchy*, including `P`, `NP`, [`co-NP`](https://en.wikipedia.org/wiki/Co-NP).

Shortly later, Adi Shamir [SH] proved that in fact `IP = PSPACE`, which gave a
complete characterization of the capabilities of interactive proofs.

As a direct outcome, employing an interactive proof system enables to verify
solutions for problems that fall outside of `NP` and even beyond the scope of
`PH`.

In some cases, the interaction between Peggy and Victor can also lead to a more
efficient verification process, allowing Victor to accept a proposed solution
without the need for Peggy to share the entire solution (`ZK` proofs).

### Arthur-Merlin Protocols

An [Arthur-Merlin](https://en.wikipedia.org/wiki/Arthur-Merlin_protocol) protocol,
initially introduced by Babai [BAB85] in 1985, is an `IP` system with the
additional constraint that the *prover* and the *verifier* share the same
randomness source.

In this context, *Merlin* is the *prover*, *Arthur* is the *verifier* and both
of them are allowed to see the randomness source of the other party.

![AM](/companions/zk-proofs/AM.png)

The fundamental attributes of an `AM` proof system `(P,V)` for a language `L`,
such as *completeness*, *soundness*, and *efficiency*, align with those of
general `IP` systems.

#### MA Protocol

The set of decision problems that can be verified in polynomial time using a
single message `AM` protocol forms the `MA` set.

Steps for a generic `MA` protocol:
1. *Merlin* sends to *Arthur* the proof
2. *Arthur* decides

`MA` protocols are very similar to traditional `NP` proofs with the addition
that the *prover* can use a public randomness source to construct its proof.

#### AM Protocol

The set of decision problems that can be decided in polynomial time by an `AM`
protocol with `k` messages is called `AM[k]`.

For all `k ≥ 2`, `AM[k]` is equivalent to `AM[2]`. This result is due to the
fact that *Merlin* can observe *Arthur* randomness source during the whole
protocol execution, and thus it doesn't affect *Merlin* messages.

`MA` is strictly contained in `AM`, since `AM[2]` contains `MA` but `AM[2]`
cannot be reduced to `MA`

Shafi Goldwasser and Michael Sipster [GS] proved that for any language with
an interactive proof protocol with private randomness (`IP`) also have an
interactive proof with public randomness (`AP`). In particular, for any `k`
`AM[k] ⊂ IP[k] ⊂ AM[k + 2]`. And because `AM[k + 2] = AM[k] = AM[2]` follows
that `IP[k] = AM[2]`.

In short, any language with a `k`-round *private coin* `IP` system has a
`k = 2` round *public-coin* `AM` system.

Said that, is worth anticipating that even though general `IP` with secret
random sources are not more powerful in terms of the range of languages they can
prove, the secrecy of the randomness becomes crucial for proving statements
without sharing any knowledge.

### Examples

#### Tetrachromacy

Tetrachromacy is a condition enabling some individuals to perceive a broader
spectrum of colors than the typical trichromat, who has three types of cone
cells for color vision. Tetrachromats have an additional cone cell type,
allowing them to see a wider range of colors.

In this scenario, Peggy claims to be tetrachromat and wants to prove it to
Victor by showing that she's able to distinguish between two marbles who
appear identical to Victor.

Protocol:
1. Peggy places the two marbles in from of Victor and turns her back.
2. Victor flips a coin. Based on the outcome, he may swap the position of the
   marbles.
3. Peggy, facing the marbles again, tells Victor whether their positions were
   swapped.

The likelihood of Peggy falsely claiming to distinguish the marbles and being
able to cheat (soundness error) is `ε = 1/2`. By repeating this protocol `k`
times, the probability of Peggy cheating reduces to `1/2ᵏ`.

Note that in this protocol a malicious Victor may put another, apparently equal,
marble in front of the *prover* and infer if that is equal or not to the other.

#### Quadratic Non-Residuosity Problem

A number `y ∈ Zₘ*` is a quadratic residue if there exists an `x ∈ Zₘ*` such that
`x² ≡ y (mod m)`. If no such `x` exists, `y` is a quadratic non-residue modulo `m`.

We define the languages:

    QR  = { y | y ∈ Zₘ* and is a quadratic residue }
    QNR = { y | y ∈ Zₘ* and is a quadratic non-residue }

It is considered to be a hard problem to tell if `y ∈ QR` or `y ∈ QNR` without
knowing the factorization of `y`.

Notice that both `QR` and `QNR` languages belong to `NP`, and thus they have
a classic proof system: Peggy just needs to send to Victor the factorization of
`y` without any further interaction.

If instead the *prover* wants to prove that `y ∈ QR` or that `y ∈ QNR` without
sharing the factorization of `y` this is actually possible only via an `IP`
system.

A protocol to show that `y ∈ QNR` is based on the fact that if `y ∈ QNR` then
`y·k² ∈ QNR` for any `k ∈ Zₘ*`.

Protocol:
1. Victor selects a random number `r ∈ Zₘ*` and flips a coin. If the coin
   shows 'heads' he sets `t = r² mod m` else `t = y·r² mod m`. He sends `t`
   to Peggy.
2. Peggy, which has unrestricted computing power, finds if `t` is a quadratic
   residue (i.e. if `t = r² mod m`) and tells Victor what was his coin toss
   result.

If `y ∉ QNR` then `y ∈ QR` and thus, regardless of the coin toss result,
`t ∈ QR` as well. In this case Peggy has no way to recover the coin toss
results. In fact Peggy has `ε = 1/2` probability of guessing correctly.

As usual, the soundness error probability can be arbitrarily reduced by
performing multiple protocol runs.

Note that in this protocol Peggy also reveals some extra information.
If `y ∈ QNR` a malicious Victor can send to Peggy any number `k` and learn from
the response if `k ∈ QR` or not.

As we'll see in the next sections we can prove both `y ∈ QR` or `y ∈ NQR`
without sharing any information using an interactive zero knowledge proof.

---

## Zero Knowledge Proofs

Now that we defined the interactive class of proof system is finally time to
better discuss the core topic of this lecture: *the quantity of knowledge
required to validate a statement*.

The concept of Zero-Knowledge Proofs (ZKP) was first rigorously defined in the
1980s by *Shafi Goldwasser*, *Silvio Micali*, and Rackoff in their seminal paper
GMR85 (notably, the same paper that introduced Interactive Proof systems).

Before the GMR paper, most of the effort on `IP` systems area focused on
the *soundness* of the protocols. That is, the sole conceived weakness was a
malicious Peggy attempting to trick Victor into approving a false statement.
What *Goldwasser*, *Micali* and *Rackoff* did was to turn the problem into: *what
if instead Victor is malicious?*

The specific concern they raised was about **information leakage**. Concretely,
how much extra information is Victor going to learn during the execution of the
protocol beyond the mere fact that the statement is true.

In the realm of `ZKP`, the primary goal of Peggy is thus to convince Victor that
a certain fact is true, without revealing *any* additional information.

Naively, it might seem that *any* additional information in a proof only
pertains to the specific details regarding the how and why the statement
being proven is true. However, the criterion in `ZKP` is more stringent. It
encompasses any piece of information that Victor cannot independently compute,
extending even to facts that are not directly related to the proof itself.

More formally.

> **Definition**. A proof system for a language `L` is considered
**zero-knowledge** if, for all `x ∈ L`, Peggy reveals to Victor only the fact
that `x ∈ L` (i.e., a single bit of information).

This definition holds true even when Victor is not honest, bounded by his
polynomial-time capabilities.

Key attributes of a `ZKP` system `(P,V)` for a language `L`:
- **Completeness**: If `x ∈ L` then `V(x,π) = 1` with high probability.
- **Soundness**: If `x ∉ L` then `V(x,π) = 1` with negligible probability.
- **Efficiency**: The total computation time of `V(x,π)` and total communication
  in `(P,V)` is polynomial with respect to length of `x`.
- **Zero-Knowledgeness**: The proof does not reveal any additional information
  other than the fact that the statement is true.

Of most importance is the following theorem found in the [GMW] paper:

> **Theorem**. For any problem in `NP` there exist a `ZKP` system.

The theorem is the sweet consequence of the existence of a `ZKP` system for
the [graph three coloring](#graph-three-coloring) problem, which is known
to be `NP` complete.

### Proving *Zero-Knowledgeness*

The proof is based on the existence of a **simulator** and the idea is quite
similar to the one used to prove [*soundness*](#proving-soundness) with the
*extractor*.

A *simulator* is a hypothetical tool which allows Peggy to convince Victor that
a statement is true, and thus about the knowledge of some key information, when
in reality she doesn't possess any knowledge.

The key intuition here is that if Peggy can consistently convince Victor of the
statement's truth across multiple protocol rounds without any actual knowledge,
then the protocol itself can't reveal any information to Victor. In essence,
Victor cannot discern whether Peggy truly holds any knowledge based on the
protocol's execution.

Similarly to the *extractor*, the implementation of the *simulator* is based
on rewinding Victor's execution in order to gain some advantage without him
noticing.

From Victor's perspective, the outputs produced by the *simulator* are
statistically indistinguishable from any genuine protocol execution.

### Probability Distributions Distinguishability 

(TODO: completely review)

The core idea is to define when two random variables are considered
**indistinguishable** to a particular observer. In the context of interactive
proofs, these observers are usually computationally bounded (polynomial time)
verifiers.

This concept is crucial for `ZK` proofs, where a prover tries to convince a
verifier of a statement's validity without revealing any other information.
The indistinguishability of random variables ensures that whatever the verifier
observes during this process doesn't give them any knowledge beyond the fact
that the statement is true.

Consider the family of random variables `U = { U(x) }` where the parameter `x`
belongs to a language `L ⊆ {0,1}*`. Each random variable in this family takes
values in `{0,1}*`

Given two such families of random variables, `U` and `V`, imagine a scenario
where a value `s` is sampled from either `U(x)` or `V(x)`. A judge should
decide if `s ∈ U(x)` or `s ∈ V(x)`.

The concept of **replaceability** comes into play when the judge's decision
becomes effectively random as the length of `x` increases. In such cases, `U(x)`
is said to be replaceable with `V(x)`.

The judge's decision-making process is influenced by two crucial factors:
- The *size* of the sample `s`.
- The *time* available for making the decision.

Based on these parameters, two families of random variables `U` and `V` can be
classified as:
- **Equal**: if the verdict is random regardless of the decision time the sample
  size.
- **Statistically indistinguishable**: if the verdict becomes random when given
  infinite time and samples with polynomial size with respect to `|x|`.
- **Computationally indistinguishable**: if the verdict becomes random when both
  time and samples size are polynomially bounded by `|x|`.

To ensure that no additional information is leaked, it's crucial that whatever
the verifier observes during the interaction is indistinguishable from what
they would observe in a simulation that doesn't involve the actual witness (the
secret information proving the statement's truth). In other words, the verifier
cannot distinguish between the real interaction and a simulated one.

A ZK proof often involves a simulation argument, where it is shown that for
every possible interaction in the actual proof system, there is a corresponding
(probabilistically similar) interaction that could be generated by a
simulator without access to the secret.

If these two sets of interactions are indistinguishable from each other, then
the proof system is zero-knowledge.

In practice, given the verifier (judge) polynomial bounds, practical `ZK` proofs
are often concerned with computational indistinguishability

In an interactive `ZK` proof, the prover and verifier exchange messages. The
indistinguishability concept ensures that, through these exchanges, the verifier
learns nothing more than the fact that the statement is true. Each step of the
interaction is designed such that it doesn't leak any extra information.

This concept is also widely used in generic cryptographic applications.
When constructing secure cryptographic protocols, taking into account 
indistinguishability property ensures that different protocol paths or choices
do not reveal additional information to potential adversaries.

In general, indistinguishability property ensures that, while Victor (the judge)
become convinced that I know the witness he doesn't learn any additional
information as the proof presented by the Peggy is indistinguishable from
random data.

### Additional Takeaways

Any `ZK` protocol must be run in an environment which preclude the feasibility
of constructing either an *extractor* or a *simulator*. The existence of these
tools fundamentally compromise the proof's *soundness* and *zero-knowledgeness*.

If Victor is able to construct an *extractor* then it will be able to
extract knowledge from the proof, and thus undermine *zero-knowledgeness.
Conversely, if Peggy is able to construct a *simulator* she will be able to
forge valid proofs without any knowledge, and thus undermine *soundness*.

Since re-playing a protocol breaks the fundamental properties, we can't use
a recording of the protocol execution to convince a third party about the
authenticity of a proof. Such a party has no way to tell if the recorded
execution is genuine or if the protocol steps were *edited* (which in practice
is a way of rewinding the execution).

Follows that in the context of a `ZKP` system Peggy is able to convince only the
verifier who actively participates by executing the protocol interactively and
in real-time.

This limitation is often regarded as a feature of some ZKP systems and indeed
reflects the pure definition found in the original paper.

### Commitment Protocols

TODO: Maintain this paragraph?

In all the `ZKP` protocols discussed in this paper, the only overarching
cryptographic required tool is a **commitment protocol**.

This protocol consists of two phases:

1. **Commit Phase**. During this phase, the sender commits to a certain value
   `v` without revealing its details to the receiver. Crucially, the receiver
   should not be able to determine anything useful about `v`.
2. **Reveal Phase**. Later on, the two parties may perform a reveal phase,
   where the receiver learns the value of `v`. There should only one value of
   `v` which is compatible with the committed value.

A very simple commitment scheme example for a value `x` is to generate some
random salt and share the value `c = Hash(salt || x)`. To open the commitment
the value of `x` and the salt is revealed. This is secure under the assumption
that the hash function is secure.

Both the computational complexity and the communication complexity of such
protocols are reasonable and in fact one can amortize the work if there are
several simultaneous commitments.

---

## Intuitive ZK Protocols

While *real-world* `ZK` proofs often rely on intricate mathematical structures
and cryptographic techniques, there are simpler, more intuitive examples that
effectively convey the core principles of `ZK` proofs.

In this section, we'll present some of the most accessible and intuitive
protocols. We start from the ones which doesn't require any technical knowledge
but at the same time are good to relay the intuition and the power of `ZK`
proofs.

### Where is Waldo

["Where is Waldo?"](https://en.wikipedia.org/wiki/Where%27s_Wally%3F) is a famous
kid's puzzle where, given a very detailed illustration with many different
characters the goal is to find Waldo, the main character.

Peggy asserts she knows where Waldo is and should convince Victor without
revealing any additional information.

*Moni Naor*, *Yael Naor* and *Omer Reingold*, in their *"How To Convince Your
Children You Are Not Cheating"*[^NR], proposed an ingenious `ZK` proof or this
problem.

Given some illustration like:

![waldo-problem](/companions/zk-proofs/waldo-problem.png)

Original Protocol (as found in the paper):
1. Peggy covers the illustration with a large sheet of paper (bigger that the
   one with the illustration) which has a little hole in the center, positioned
   exactly over Waldo's face.
2. Victor is convinced if he sees Waldo through the hole.

![waldo-zk-proof](/companions/zk-proofs/waldo-zk-proof.png)

However, this initial protocol does not adequately address soundness concerns.
How can the verifier be sure the covered illustration is the original one?

This is an extended protocol designed to be sound:
1. Peggy covers the illustration with bigger sheet having a 
   randomly positioned hole, then it covers this with an even bigger sheet
   without any hole. The illustration should be at a distance from the border
   at least equal to the size of the first sheet of paper (to better hide
   relative positions during the proof).
2. Victor flips a coin and depending on the outcome, asks to
   Peggy either the removal of both layers to reveal the full illustration
   or just the top layer to reveal Waldo through the hole.
3. Peggy complies with the challenge.
4. Victor accepts or reject based on the evidence.

This new protocol is both sound and zero-knowledge as it makes possible to
construct both an *extractor* and a *simulator*.

In one run, the soundness error is `ε = 1/2`, meaning that Peggy has a 50%
change to cheat.

--- RESTART HERE --

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

- [NR] M.Naor, Y.Naor, O.Reingold. [How to Convince Your Children You Are Not Cheating](http://www.wisdom.weizmann.ac.il/~naor/PAPERS/waldo.pdf) (1999).

- [FS] Amos Fiat, Adi Shamir. [How To Prove Yourself](https://link.springer.com/chapter/10.1007/3-540-47721-7_12)

- [LFKN] C. Lund, L. Fortnow, H. Karloff, and N. Nisan. Algebraic methods for interactive proof systems. In Proceedings of the 31st Annual Symposium on Foundations of Computer Science, pages 2–10. IEEE, 1990.

- [SH] A. Shamir. IP = PSPACE. In Proceedings [1990] 31st Annual Symposium on Foundations of Computer Science, pages 11–15. IEEE, 1990.

- [GNPR] R.Gradwhol, M.Naor, B.Pinkas, G.Rothblum - [Cryptographic and Physical Zero Knowledge Proof Systems for Solutons of Sudoku Puzzles](https://link.springer.com/article/10.1007/s00224-008-9119-9)
