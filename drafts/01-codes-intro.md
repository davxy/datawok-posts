+++
title = "Introduction to Codes"
date = "2023-11-18"
modified = "2023-11-18"
tags = ["codes", "draft"]
draft = true
+++

Real world communication channels have properties which are in stark contrast with
the ideal.

While we aim for channels which are:
- **economic**
- **secure**
- **reliable**

Real world channels are:
- **limited**: bandwidth to transmit information is not infinite;
- **insecure**: information may be read and maliciously altered;
- **unreliable**: data may be altered because of physical limitations.

In order to try to resolve these issues, we typically resort to codes,
**reversible** functions which transform a message in order to gain some
properties.

The most important family of codes are:
- **compression codes** to improve throughput;
- **cryptographic codes** to improve channels security;
- **error detection and correction codes** to improve channels reliability.

A typical communication protocol stack encodes the information to transmit in
the following order:
1. compression codes
2. encryption codes
3. error detection and correction codes

Compression generally works by removing redundancy from the data to be
transmitted and since it is a characteristic of a good encryption code to remove
patterns (thus redundancy) by scrambling the data, is a general good practice to
apply encryption after compression.

Error correction codes are applied at the bottom of the stack, just above
the physical communication channel. Error codes usually augment the data with
some redundancy applied to the right places. We don't want to disrupt it by
encrypting or compressing the data. Furthermore, data that is compromised can't
be generally decrypted nor decompressed.

Encoding techniques are often studied by two academic disciplines:
- **information security**: mostly focused on cryptographic codes;
- **information theory**: mostly focused on compression and error-correction codes.

The two disciplines foundations are not disjointed and often the same subject is
studied from a different perspective.

Information theory and modern cryptography (as we know it today) ideas were
initially introduced by **Claude Shannon** in 1948 in its seminal paper "A
Mathematical Theory of Communication". His work introduced concepts such as
information entropy and channel capacity.
