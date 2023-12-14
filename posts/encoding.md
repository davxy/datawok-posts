+++
title = "Information Bits Encoding"
date = "2014-09-18"
tags = ["standards", "encoding"]
+++

Encoding of binary data in a signal that the transmission line is able to
carry. Assume we are working with two discrete signals: high and low.

Boud rate: the rate of signal transitions on the link.
Bit rate: the rate of bits transmission on the link


## NRZ

Non-Return to Zero (NRZ) encoding maps the data value 1 onto the high
signal and the data value 0 onto the low signal.

    Bits    0   1   0   1   1   0   0   1
               ___     _______         ___
    NRZ    ___|   |___|       |_______|   

The encoding has two problems caused by long strings of 1s or 0s.
- *baseline wander*: the receiver keeps an average of the signal it has seen
  so far, and uses this average to distinguish between low and high
  signals. Long strings of equals values alter this mean to the point that
  the receiver is unable to distinguish the opposite value.
- *clock recovery*: the receiver uses frequent transitions from high to low
  to be in sync with the transmitter whether a separate line is not used to
  transmit the clock.

The baud rate is equal to the bit rate.


## NRZI

Non-Return to Zero Inverted (NRZI) encoding makes a transition from the
current signal to encode a 1 and stay at the current signal to encode a 0.

    Bits    0   1   0   1   1   0   0   1
               _______     ___________
    NRZI   ___|       |___|           |___

The encoding solves the problem of consecutive ones but not of consecutive
zeros.


## Manchester

The internal clock signal is XOR-ed with the NRZ-encoded data. The 0 is
thus encoded as a low-to-high transition and 1 being encoded as a
high-to-low transition.

With Manchester both 0s and 1s encoding results in a transition of the
signal.

    Bits    0   1   0   1   1   0   0   1
               ___     _______         ___
    NRZ    ___|   |___|       |_______|
             _   _   _   _   _   _   _   _ 
    Clock  _| |_| |_| |_| |_| |_| |_| |_| |
             ___     ___   _     _   ___   
    Manch  _|   |___|   |_| |___| |_|   |_|

The problem is that it doubles the rate at which signal transitions are
made on the link. Thus the bit rate is half of the bound rate.


## Differential Manchester

A 1 is encoded with the first half of the signal equal to the last half of
the previous bit's signal and 0 is encoded with the first half of the
signal opposite to the last half of the previous bit's signal.

Same advantages and disadvantages of the Manchester encoding.


## 4B/5B

The idea is to insert one extra bit into the bit stream to break long
sequences of 0s or 1s. Specifically, every 4 bits of data are encoded in
5-bit code. The 5-bit codes are selected so that each one has no more than
one leading 0 and no more than two trailing 0s. Thus, no pair of 5-bit
codes results in more than three consecutive 0s being transmitted.

The resulting 5-bit codes are then transmitted using NRZI.

Of the 4B/5B codes, 16 are used to encode the 4-bit payloads, 11111 is used
when the line is idle, 00000 corresponds to a deadline, 00100 is the mean
halt. Of the remaining 13 codes, 7 of them are not valid because they
violate the constraint rule, and the other 6 represents various control
symbols. Some framing protocols (e.g. FDDI) make use of these control
symbols.

4B/5B solves the "clock recovery" and the "baseline wander" issues by
loosing the 20% of efficiency (4/5=0.8). Baud rate is 5/4 of bit-rate.

Other popular similar encodings are
- 8B/10B: Used by Gigabit Ethernet
