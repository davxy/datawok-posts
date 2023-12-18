+++
title = "Shared Key Cryptography Highlights"
date = "2023-11-26"
modified = "2023-11-26"
tags = ["cryptography", "security", "draft"]
draft = true
+++

## Shared Key Cryptography

Security assumptions:
- attacker is assumed to be passive
- cryptographic scheme design is public
- secret key is distributed using a secure channel

The ciphertext, plaintext and key symbols are taken from a finite alphabet `A`.

`A*` is the set of all possible strings that can be composed of symbols in `A`.

Parameters:
- `m`: plaintext in `P ⊆ A*`
- `c`: ciphertext in `C ⊆ A*`
- `k`: shared key in `K ⊆ A*`
- `E`: encryption function
- `D`: decryption function

    m → [E] → c → [D] → m
         ↑         ↑
         k         k

Generally, the end-goal of an attacker is to discover the plaintext or the
secret key.

Generic encryption and decryption functions:
- `E: K × P → C`
- `D: K × C → P`

Encryption and decryption functions for a fixed key `k`:
- `Eₖ: P → C`
- `Dₖ: C → P`

Requisite for any good encryption scheme:
- For each key `k`, `Dₖ(Eₖ(m)) = m`, i.e. decryption is the inverse of
  encryption. In other words, `Eₖ: P → C` should be **injective**
- Given the key `k`, `Eₖ` and `Dₖ` are *easy* to compute.
- Given the output `c`, is *hard* to find `m` or `k`.

Knowing only the ciphertext or any other public parameter doesn't give too
much information about the plaintext or the key.

## Shared Key Management

Main problems to address:
- key storage
- key distribution

## Network Traffic Security

While a message travels through the network we want to guarantee:
- **Confidentiality**: link or end-to-end encryption.
- **Authentication**: data origin or peer entity authentication.

If the header is in clear-text then we are exposed to traffic analysis.
An alternative is link encryption, i.e. encrypt each link between hops
individually.

In this case we encrypt both the packet payload and header. If the relays
are honest then the traffic analysis problem is solved, but the drawback
here is that we need to trust the intermediate nodes to maintain information
confidentiality.

If one single node is compromised then the full information is disclosed.
Furthermore, we loose the end-to-end authentication property.

A simple strategy is to use a combination of the two approaches.
- We encrypt the payload with a key shared between the source and destination in
  order to get end-to-end confidentiality and data origin authentication (E2E).
- Each link encrypts the whole packet using the link key in order to prevent
  traffic analysis and providing peer entity authentication (P2P).

More advanced strategies exists such as
[Tor circuits](https://support.torproject.org/glossary/circuit/) and
[Mixnet](https://paritytech.github.io/mixnet-spec/). By simplifying a bit,
these strategies involve selecting a random path of relay nodes from the sender
to the recipient. And then encrypt the message using the public keys of all the
nodes starting from the recipient and in reverse order. In this way each relay
will have to remove one layer of encryption to discover who is the next hop
before forwarding the message.


## Key Distribution

A secure channel to distribute the shared key should be deployed.

Distribution techniques:
- *In person*: directly or using a trusted courier.
- *Key distribution center*: a centralized trusted actor.
- *Public key infrastructure*: leverage PKI for symmetric key distribution.

For a big network of `N` nodes key management and distribution can be very
challenging:
- Total number of keys in the network is the number of couples that can be
  formed with `N` nodes: `N·(N-1)/2` or (equivalently) `∑ i` for `i = 1.. (N-1)`
- Each node stores `N-1` keys.
- A new node joining the network requires updating all the others.


### Needham-Schroeder Protocol

Based on a centralized Key Distribution Center (KDC), is the foundation for
**Kerberos** protocol.

The protocol provides:
- key agreement
- mutual authentication
- vertical scalability using hierarchical KDCs.

There are two key types:
- **Master** keys: long-lived keys persistently identifying each node.
- **Session** keys: ephemeral keys that are changed on each session.

Master keys are used to securely distribute the session keys.

Each of the network users shares a master key with the KDC.

Initially, when a user joins the network, he will register within the KDC. The
KDC will then share with the new joiner the master key using a secure channel.

When a node `A` wants to send a message to a node `B`, he asks the KDS for a
session key.

#### Session Key Exchange

1. (`A → KDC`) `A` tells the KDC its intention to communicate with `B`.

    Message = `B || NA`

    - `B`: identifier to specify the intention of `A` to communicate with `B`
    - `NA`: `A`'s nonce, a number which uniquely identifies a session.

2. (`KDC → A`) KDC replies to `A` with a message encrypted with its master key:

    Message = `E_KA(KS || B || NA || TK )`

    - `KA`: `A`'s master key
    - `KS`: ephemeral session key
    - `B`, `NA`: echo of `A`'s request to ensure to `A` that this is the
      response to its request.
    - `TK`: ticket to forward to `B`

3. (`A → B`) `A` forwards the ticket `TK` to `B`:

    Message = `TK = E_KB(KS || A || R)`

    - `KB`: `B`'s master key
    - `KS`: ephemeral session key
    - `A`: identifier of the node who requested the session key
    - `R`: pseudo random number to prevent reusing the ticket

After step 3, a secure channel between `A` and `B` is established.

#### Mutual Authentication

The protocol can be extended to provide mutual authentication using a simple
challenge-response protocol.

4. (`B → A`) `B` sends to `A` a nonce encrypted with `KS` (or a MAC of `NB`)

    Message = `E_KS(NB)`

    - If `A` is able to "correctly" decrypt the message then he's ensured that
      is talking with `B`. Only the real `B` should know `KS`.

5. (`A → B`) `A` sends back to `B` the encrypted nonce incremented by one (or a
   MAC of `NB+1`)

    Message = `E_KS(NB+1)`

#### Known Vulnerability (Replay attack)

The message 3 doesn't have a reference "freshness" value attached to it.

In theory an attacker can sniff a message of type 2 or 3 and work on it
"offline" to discover `KS`. In this case an attacker can then use the ticket to
impersonate `A` in the future.

As a workaround we can use a validity timestamp for the session key and let `B`
accept `TK` only if it is recent enough.


## Key Rotation

The primary goal of rotating encryption keys is not to decrease the probability
of a key being broken. By reducing the amount of data encrypted with a single
key we also reduce the amount of leaked information in the eventuality of a
compromised key (**forward security**).

One popular implementation of the principle is to use an old key to encrypt the
new key.

The key rotation principles apply to asymmetric keys as well, both in the
context of confidentiality and non-repudiation.

For example, key rotation for a key used for digital signatures is typically
performed by enacting a new key and *revoking* an old key (publishing this
event in a trusted key server). Any signature which should be verified using the
revoked key is then rejected and this also applies to the signatures which were
performed while the key was valid.

So revoking the key completely obliterates the attacker efforts as he can't do
absolutely anything with the disclosed key.
