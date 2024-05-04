+++
title = "Integer Overflow Detection"
date = "2017-11-07"
modified = "2017-11-07"
tags = ["programming","security"]
+++

The following article is highly inspired by the work of Will Dietz, Peng Li,
John Regehr, and Vikram Adve: 'Understanding Integer Overflow in C/C++'.

The work has been sliced down to the core and amended with some notes.


## Introduction

Mathematically, n-bit two's complement arithmetic is congruent, modulo 2^n,
to n-bit unsigned arithmetic for addition, subtraction, and the n least
significant bits in multiplication. Both kinds of arithmetic "wrap around"
at multiples of 2^n.

On modern processors n-bit signed and unsigned operations both have this
well-defined behavior when an operation overflows: the result wraps around
and condition code bits are set appropriately.

In contrast, integer overflows in C/C++ programs are subtle due to
combination of complex and counter-intuitive rules in the language
standards and undefined behaviors.

C an C++ have undefined semantics for signed overflow and shift past
bit-width: operations that are perfectly defined in other languages such as
Java.

Wraparound operation with signed types have undefined behavior. Today's
compiler may compile these overflows into correct code. But those overflows
are *time bombs* because they remain latent until a compiler upgrade turns
them into observable errors.


## Taxonomy

### Developer intentions categories

- Intentional
- Unintentional

#### Intentional

Inserted to implement a specific function.

Commonly found to implement cryptographic primitives, hash functions,
pseudo random numbers generators, and to find the max value of a type.

```c
    // Rotate right a 32-bit value by 4 bits
    u32rot = (u32 << (32 - 4) | u32 >> 4);
```

#### Unintentional

An overflow that is caused by a coding error (a bug).

```c
    uint8_t i;
    for (i = 0; i < 255; i += 2) // if i = 254 then i += 2 wraps back to 0
        printf("%u\n", i);       // Never ending loop */
```

### Behavior categories

- Well-defined
- Undefined

#### Well-defined behaviors

An operation result evaluates to an expected value.

Example

```c
    uint8_t u8 = 0x80;
    u8 >>= 1;        // Gives 0x40
```

or

```c
    UINT_MAX + 1;    // Gives 0
```

Note that well-defined doesn't mean "portable". Some well-defined values
are *implementation defined*. Meaning that we can rely on a value but only
within the context of a given compiler (or compiler version).

For example `0U - 1` is well-defined and evaluates to `UINT_MAX`, but the
actual value of that constant is *implementation defined*.

Obviously is better to avoid rely on implementation defined behaviors.


#### Undefined behaviors

According to the C99 standard, undefined behavior is:

"Behavior, upon use of a non-portable or erroneous program construct or
erroneous data, which this International Standard imposes no requirements"

Example

```c
    uint32_t u32 = 1;
    u32 = u32 << 32;      // Undefined
```

or

```c
    INT_MAX + 1;     // Undefined, commonly INT_MIN (overflow in sign bit)
    (char) INT_MAX;  // Undefined, commonly -1
```


**Silent Breakage**

When programs execute undefined operations, optimizing compilers may
silently break them in non-obvious and not necessarily consistent ways.

```c
    int foo(int x) { return (x + 1) > x; }

    int main(void)
    {
        printf("%d\n", (INT_MAX + 1) > INT_MAX);
        printf("%d\n", foo(INT_MAX));
        return 0;
    }
```

Compiling without optimizations the results are consistently: 0 and 0.
Compiling with `-O2` optimizations an inconsistent answer is produced: 0 and 1.

**Time bombs**

Code that works under today's compilers, but may break in future versions.

**Bogus Predictability**

Predictable behavior for some undefined operations only under some
optimization levels.

**Informal Dialects**

Support for stronger semantics than are mandated by the standard.

**Non-Standard Standards**

Some kinds of overflow have changed meaning across different versions of
the standards. For example `1<<31` is implementation-defined in C89 and
C++98, while is explicitly undefined by C99 and C11 (assuming 32-bit
integers).


## Overflow Detection

In integer arithmetic operations every integer type is eventually promoted
to int before performing the operation.

### Shift

Checking for overflows in shift operations is pretty straightforward;

`A << B` gives an overflow if `(A & ~((1 << (bitsize(A) - B)) - 1)) != 0`

For example: if `B` is `2` and `bitsize(A)` is `8` then
`~((1 << (bitsize(A) - B)) - 1)` is equal to `11000000` (binary)

Similar check can be performed to detect an overflow on the right side.

#### Truncated shift count

```c
    int8_t i8 = 1;      // Hex values are unsigned, warning
    i8 = i8 >> 8;       // No warnings due to type promotion

    int32_t i32 = 1;
    i32 = i32 >> 32;    // Waning: right shift count >= width of type
```

For types with a size greater than the size of a `int`, if the shift
count is greater that the width of the type, then the shift value is taken
modulo the size, in bits, of the destination type.

```c
    i32 = 2;
    i32 = i32 >> 32;         // gives 2 (same as >> 0)
    i32 = 2;
    i32 = i32 >> (32 + 1);   // gives 1 (same as >>1)
    i32 = 2;
    i32 = i32 >> (32 + 2);   // gives 0 (same as >>2)
```

The same happens with a `int64_t` value, but modulo 64.

Note that there isn't, in any case, a binary digit rotation or rollover.

```c
    i32 = 1;
    i32 = i32 >> 2;          // gives 0
```

Exactly the same behavior happens in case of left shift.

#### Sign extension

To respect the arithmetic meaning of a right shift, that is division by 2,
the right shift operator when applied to signed integer with the most
significant bit set (negative values) the bit sign is extended.

```c
    i8 = -4;                // 11111100 (binary)
    i8 = i8 >> 1;           // gives -2 = 11111110 (binary)
```

Without sign extension the result would be arithmetically wrong.

### Addition

Addition or subtraction of two n-bit integers may require n+1 bits of
precision.

    (2^n - 1) + (2^n - 1) = 2^(n+1) - 2 = 2⋅(2^n - 1)
    
Worst case example (binary)

    1111 + 1111 = [1]1110
                   ^carry

**Precondition test**

Given two signed integers i1 and i2, signed addition will wrap if and only
if the following expression is true.

```c
    ((i1 > 0) && (i2 > 0) && (i1 > (INT_MAX - i2))) ||
    ((i1 < 0) && (i2 < 0) && (i1 < (INT_MIN - i2)))
```

The above can be simplified in

```c
    ((i2 > 0) && (i1 > (INT_MAX - i2))) || // i1 > 0 is implicit
    ((i2 < 0) && (i1 < (INT_MIN - i2)))    // i1 < 0 is implicit
```

**Unsigned test**

This test can be done to detect overflows on addition of two unsigned
integers

```c
    (u1 + u2) < u1
```

--------------------------------------------------------------------------------

### Multiplication

Multiplication of two n-bit integers may require 2n bit of precision.

    (2^n - 1) ⋅ (2^n - 1) = 2^(2n) - 2^(n+1) + 1 = 2^(n+1) ⋅ (2^(n-1) - 1) + 1

    1111 ⋅ 1111 = [1110]0001
                      ^carry

**Precondition text**

Given two signed integers one trivial test that can detect an overflow is
(assuming i2 != 0)

```c
    x = i1 * i2;
    if (i2 != 0 && x / i2 != i1) { overflow }
```

**Separate hi/lo word**

Given two 64-bit integers i1 and i2, in the worst case the result requires
128 bit. Such a huge width are not defined by standard C language.
To detect overflow we can split the 64-bit integer in two 32-bit parts.

```c
    #define LO(x) ((x) >> 32)
    #define HI(x) ((x) & ((1 << 32) - 1))

    uint64_t x, s0, s1, s2, s3;
    uint64_t h, l;

    x = LO(i1) * LO(i2);
    s0 = LO(x);
    x = HI(i1) * LO(i2) + HI(x); 
    s1 = LO(x);
    s2 = HI(x);

    x = s1 + LO(i1) * HI(i2);
    s1 = LO(x);

    x = s2 + HI(i1) * HI(i2) + HI(x);
    s2 = LO(x);
    s3 = HI(x);

    l = (s1 << 32) | s0; // optionally truncated result
    h = (s3 << 32) | s2; // carry
```

### Generic detection

**CPU flag test**

Most processor contain hardware support for detecting overflow.
It is not possible to inspect processor flags in a portable ANSI C code.

**Width extension post-condition**

If an integer datatype with wider bit-width than the values being operated
on is available, overflow can be trivially detected by converting i1 and i2
into the wider type before performing the operation and assign the result
to a wider type temporary variable.

For addition the wider type must have at least n+1 bits. For multiplication,
it must have at least 2n bits.

