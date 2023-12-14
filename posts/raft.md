+++
title = "Raft Consensus"
date = "2018-09-11"
tags = ["distributed-systems"]
+++


A shorter version of the official [Raft whitepaper](https://raft.github.io).


## Introduction

Crash Fault Tolerant (CFT) algorithm for replicated state machines.

Raft primary goal is **understandability**.

Novel features:
- Strong leadership: log entries only flow from the leader to other nodes.
- Leader election: randomized timers to elect leaders.
- Membership changes: joint consensus approach to change the cluster nodes set.

Randomized approaches introduce nondeterminism, but also reduces the algorithm
possible state spaces.


## Replicated state machines

Nodes in a cluster compute identical copies of the same state and can continue
operating even if some of the nodes are down (crash fault).

Replicated state machines are typically implemented using a replicated log. Each
node stores a log containing a series of commands, which its state machine
executes in order, thus producing the same result.

Since the state machines are deterministic, each computes the same state and the
same sequence of outputs. As a result the nodes appear to form a single reliable
state machine.

Keeping the replicated log consistent is the job of the consensus algorithm.

Properties:
- Safety: under all **non-Byzantine** conditions including network delays,
  partitions, packet loss, duplication and reordering.
- Availability: as long as any majority of the nodes are operational. Nodes can
  fail and recover from state on stable stora to rejoin the cluster.
- Time-free: delays and clock failures can, at worst, cause availability
  problems.
- A command can be executed as soon as the majority has confirmed the operation.
  A minority of slow nodes do not impact the overall system performances.


## Consensus Algorithm

First a leader is elected. The leader has complete responsibility for managing
the replicated log.

Leader accepts new log entries from the clients, replicates them on other nodes
and tells nodes when is safe to apply log entries to their state machines.

If a leader fails, a new leader shall be elected.

Separation of key elements of consensus:
- **Leader election**: a new leader is chosen when an existing leader fails.
- **Log replication**: leader shall accept new log entries from the clients and
  manage their replication across the cluster.
- **Safety**: if a node has applied a log entry to its state machine, then no
  other node may apply a different command for the same log index.

Raft guarantees that each of these properties is true at all times:
- *Election Safety*: at most one leader can be elected in a given term (because of
  the majority rule).
- *Leader Append-Only*: a leader never overwrites or deletes entries in its log.
- *Log Matching: if two logs contain an entry with the same index and term, then
  the logs are identical in all entries up through the given index.
- *Leader Completeness*: if a log entry is commited in a given term, then that
  entry will be present in the logs of the leaders for all higher-numbered
  terms.
- *State Machine Safety*: if a node has applied a log entry at a given index, no
  other node will ever apply a different entry for the same index.


## Raft Basics

At any given time each node is in one of three states:
- *Candidate*
- *Leader*
- *Follower*

In normal operation there is exactly one leader and all the other nodes are
followers.

Followers are passive, they simply respond to requests from leaders and
candidates.

The leader handles all client requests. If a client contacts a follower it will
redirect the request to the leader.

Time is divided into *terms* of arbitrary length and numbered with consecutive
integers. Each term begins with an *election*, in which one or more candidates
attempt to become leader. If a candidate wins the election if will become the
leader for the rest of the term. In case of "split-vote" the term will have
no leader and a new term will begin shortly.

Different nodes may observe the transitions between terms at different times,
and in some situations a node may not observe an election or even entire terms.

Terms act as logical clock as they allow nodes to detect obsolete information.
Each node stores a current term number which increases monotonically over time.
Current terms are exchanged whenever nodes communicate; if a node finds that its
term is smaller than the other, it updates its value. If a candidate or a
leader discovers its term is out of date, it reverts to follower. If a node
receies a request with an outdated term, it just drops it.

Raft requires only two RPC types:
- `RequestVote`: sent by candidates during elections;
- `AppendEntries`: sent by leaders to replicate log entries and as "heartbeat".


## Leader Election

When a node starts up it begins as a follower. It remains in follower state as
long as it receives valid RPCs from a leader or candidate. Leaders send periodc
heartbeats (empty `AppendEntries` messages) to maintain their authority.

If a follower doesn't receive any message over a period of time (*election
timeout*) then it assumes there is no leader and begins a new election.
The election is started by incrementing its `term` value and transitioning to
candidate state. It sends a `RequestVote` message and votes for itself.
Possible outcomes:
- it wins the election,
- another node wins the election,
- a period of time goes by with no winner.

Candidate wins if it receives votes from the majority of the nodes for the same
term. The majority rule ensures that at most one candidate can win the election
for one term (Election Safety property).

While waiting for votes, a candidate may receive an `AppendEntries` RPC from
another node claiming to be leader. It the leader term is greater than or
equal the candidate term then the candidate becomes a follower. If the term is
smaller it just drops the message.

In the eventuality of a vote split that prevents to reach a majority then the
candidate will time out and starts a new election by incrementing its term and
sending a new `RequestVote` message.

To prevent the vote split issue from happening again a randomized election
timeout is used (between 150ms and 300ms). This probabilistic approach ensures
that splits votes are rare
and resolved quickly.


## Log Replication

Each log entry contains a command to be executed by the replicated state
machines. The leader appends the command to its log as a new entry, then
broadcasts an `AppendEntries` message. When the entry has been safely replicated
the leader applies the entry to its state machine.

If followers crash or run slowly the leaders retries `AppendEntries`
indefinitely until all followers eventually store all log entries.
(TODO: the majority is not sufficient?)

Each log entry stores a state machine command along with the term number when
the entry was received by the leader. The term number in log entries is used to
detect inconsistencies between logs.

Leader decides when it is safe to *commit* a new log entry. A log entry is
commited once the leader that created it has replicated it on a majority of
nodes. This also commits all preceding entries in the leader's log, including
entries created by previous leaders.
(TODO: approfondire)

The leader keeps track of the highest index it knows to be committed, and it
includes that index in future `AppendEntries` RPCs. Once a follower learns that
a log entry is committed, it applies the entry to its local state machine (in
log order).

*Log Matching* property: if two entries in different logs have the same index
and term, then:
- they store the same command,
- their logs are identical in all preceding entries.

The first property follows the fact that each term can have only one leader
and a leader creates at most one entry with a given log index.

The second property is guaranteed by a consistency check performed by
`AppendEntries`. The leader includes the index and term of the entry in its log
that immediately precedes the new entries. If the follower doesn't find an entry
with same index and term then it refuses the new entries.

As a result, id `AppendEntries` returns successfully the leaders knows that the
follower's log is identical to its own log up through the new entries.

During normal operation, the logs of the leader and followers stay consistent.
However, leader crashes can leave the logs inconsistent.

When a new leader comes to power it may find the following situations:
- a follower log is missing some entries the leader have,
- a follower may have extra uncommited entries the leader doesn't have,
- both the cases in a single follower's log.

The leader handles inconsistencies by forcing the followers logs to duplicate
its own. This means that conflicting entries in follower logs will be
overwritten with entries from leader's log.

The leader must first find the latest log entry where the the two logs agree.

The leader maintains a `next-index` for each follower, which is the index of the
next log entry the leader will send to that follower. When a leader comes to
power it initialized all `next-index` values to the index just after the last
one in its log.

If a follower log is inconsistent with the leaders's, the next `AppendEntries`
message consistency check will fail and the leader decrements its `next-index`
and retries. Eventually `next-index` will reach a point where the leader and
follower log matches, when this happens the follower removes any conflicting
entries and appends entries from the leader's log.

Optimization: when the follower rejects an `AppendEntries` request, it can
include the term of the conflicting entry and the first index it stores for that
term. This allows the leader to skip some messages.

A leader never overwrites or deletes entries in its own log (Leader Append-Only
property).


## Safety

The mechanisms described so far are not sufficient to ensure that each state
machine executes exactly the same commands in the same order.
For example, a follower may not be available when a leader commits a log entry,
then it becomes leader and overwrites this entry with a new one (because of
leader append-only property).

A constraint shall be added to restrict which nodes that may be elected as
leaders. The restriction ensures that the leader for any given term contains all
the entries committed in the previous terms (Leader Completeness property).

### Election Restriction

The leader must eventually store all of the committed log entries.

Raft guarantees that all the committed entries from previous terms are present
on each leader from the moment of its election, without the need to transfer
those entries to the new leader.

This means that log entries only flow in one direction, from leaders to
followers, and leaders never overwrite existing entries in their logs.

The algorithm prevents a candidate from winning an election unless its log
contains all committed entries.

A candidate must contact a majority of the cluster in order to be elected, which
means that every committed entry must be present in at least one of those nodes
(entries are committed only when are present on at least the majority of nodes).

If the candidate's log is at least as up-to-date as any other log in that
majority then it will hold all the committed entries.

In short, a voter denies its vote if its own log is more up-to-date than the
candidate's one.

Which log is more up-to-date is determined by comparing the index and term of
the last entries in the logs.
If the logs have last entries with different terms, then the log with the later
term is more up-to-date.
If the logs end with the same term, then whichever log is longer is more
up-to-date.

### Committing entries from previous terms

A leader knows that an entry from its current term is committed once that entry
is stored on a majority of the servers.

If a leder crashes before committing an entry, future leaders will attempt to
finish replicating the entry. However a leader cannot immediately conclude that
an entry from a previous term is committed once it is stored on a majority of
servers (example on fig.8 of the whitepaper).

To overcome the issue nodes never commits log entries from previous terms by
counting replicas. Only entries from leader's current term are committed by
counting replicas. Once an entry from the current term has been committed in
this way then all prior entries are committed indirectly because of the Log
Matching property.

### Safety argument

By contradiction, we assume that the Leader Completeness property doesn't hold.

Suppose leader for term T (leaderT) commits an entry for its term, but that log
entry is not stored by the leader of some future term.

Consider the smallest term U > T whose leaderU does not store the entry.

... refer to 5.4.3 of the official Raft whitepaper.


## Follower and candidate crashes

In case of follower or candidate crashes the future `RequestVote` and
`AppendEntries` RPC sent will fail.

Raft handles these failures by retrying indefinitely.


## Timing and availability

Safety must not depend on timing. Availability inevitably depends on timing.

Without a steady leader Raft cannot make progress.

E.g. If messages exchange takes longer than longer than the typical time between
server crashes, candidates will not stay up long enough to win an election.

Raft is able to maintain a steady leader as far as the following condition is
satisfied:

```
    broadcast_RTT_time << election_timeout << MTBF
```
- broadcast_RTT_time: average time it takes a server to send RPCs in parallel
  and receive their responses (RTT: round trip time). An order of magnitude less
  than the election timeout
- election timeout: range used by followers to start an election. The values in
  the range must be few orders of magnitude less than the MTBF.
- MTBF: mean time between failures for a single server.

Broadcast time and MTBF are properties of the underlying system while election
timeout is something we can configure.

E.g. If broadcast time is ~0.5/20ms then the election timeout should be
somewhere between 100ms and 500ms. Typical node MTBF are several months or more.


## References

- Extended Raft [paper](https://raft.github.io/raft.pdf)
- PingCap Raft [course](https://github.com/pingcap/talent-plan/blob/master/courses/dss/raft/README.md)
- MIT 6.824 Raft courses:
  [lab2:raft](http://nil.csail.mit.edu/6.824/2018/labs/lab-raft.html) and
  [lab3:kvraft](http://nil.csail.mit.edu/6.824/2018/labs/lab-kvraft.html)
