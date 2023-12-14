+++
title = "Basic Encoding Rules"
date = "2017-11-10"
tags = ["standards","encoding"]
toc = true
+++

The Basic Encoding Rules for ASN.1 (BER) give one or more ways to represent
any ASN.1 value as an octets sequence.

There are three methods to encode an ASN.1 value under BER, the choice of
which depends on the type of value and whether the length of the value is
known. The three methods are *primitive definite-length*, *constructed
definite-length* and *constructed indefinite-length*.

Simple non-string types employ the primitive definite-length method; structured
types employ either of the constructed methods; and simple string types employ
any of the methods, depending on whether the length of the value is known.

Types derived by implicit tagging employ the method of the underlying type and
types derived by explicit tagging employ the constructed methods.

In each method, the BER encoding has three or four parts:

- *Identifier* octets. These identify the class and tag number of the ASN.1
  value, and indicate whether the method is primitive or constructed.
- *Length* octets. For the definite-length methods, these give the number of
  contents octets. For the constructed, indefinite-length method, these
  indicate that the length is indefinite.
- *Contents* octets. For the primitive definite-length method, these give a
  concrete representation of the value. For the constructed methods, these
  give the concatenation of the BER encodings of the components of the value.
- *End-of-contents* octets. For the constructed indefinite-length method,
  these denote the end of the contents. For the other methods, these are absent.

## Primitive definite-length

Applies to simple types and types derived from simple types by implicit
tagging. Requires that the length of the value be known in advance.

**Identifier octets**

*Low-tag-number* form. For tag numbers between 0 and 30. One octet.
Bit 8 an 7 specify the class, bit 6 has value "0", indicating that the encoding
is primitive, and bits 5-1 give the tag number.

| Class             | Bit 8 | Bit 7 |
|-------------------|-------|-------|
| Universal         |   0   |   0   |
| Application       |   0   |   1   |
| Context-specific  |   1   |   0   |
| Private           |   1   |   1   |

*High-tag-number* form. Two or more octets. First octet is as the
low-tag-number form, except that bits 5-1 all have value "1". Second and
following octets give the tag number, base 128, most significant digit first,
with as few digits as possible, and with the the bit 8 of each octet except the
last set to "1".

**Length octets**

*Short form*. For lengths between 0 to 127. One octet. Bit 8 has value "0"
and bits 7-1 give the length.

*Long form*. For lengths between 0 and 2^1008-1. Two to 127 octets.
Bit 8 of the first octet has value "1" and bits 7-1 give the number of
additional length octets. Second and following octets give the length, base
256, most significant digit first.

*Note*: the value 11111111(binary) shall not be used. This restriction is
introduced for possible future extension.

**Contents octet **

Gives a concrete representation of the value.

### Constructed definite-length

Applies to simple string types, structured types, types derived by simple
string types and structured types by implicit tagging, and types derived from
anything by explicit tagging. Requires that the length of the value be known in
advance.

**Identifier octets**. Like primitive definite-length except that bit 6 has
value "1".

**Length octets**. As described for primitive definite-length types.

**Content octets**. The concatenation of the BER encodings of the components.
For string types that is the string payload.

### Constructed indefinite-length

Applies to simple string types, structured types, types derived from simple
string types and structured types by implicit tagging, and types derived from
anything by explicit tagging. It does not require that the length of the value
to be known in advance.

**Identifier octets**. Like constructed definite-length types.

**Length octets**. One octet, 0x80

**Content octets**. As described for constructed definite-length types.

**End-of-contents**. Two octets, 0x00 0x00. The two bytes have such a
meaning only when are found in a type/length position.


## Distinguished Encoding Rules

The DER are a subset of BER, and give exactly on way to represent any ASN.1
value as an octet string. DER is intended for applications in which a unique
octet string encoding is needed, as in the case where a digital signature is
computed on an ASN.1 value. DER is defined by X.509.

DER adds the following restrictions to the BER rules:

- The length is encoded using less bytes as possible, possibly short form.
- Indefinite length method is not used.

Other restructions that are defined for the particular types are described
when required.

## Notation and Encoding for some types

### NULL

Denotes a 'null value'.

**BER encoding**. Primitive. The contents octets are empty.

**DER encoding**. Always `05 00`.

### INTEGER

An arbitrary integer.

ASN.1 notation:

    INTEGER [{ identifier_1 (value_1) ... identifier_n (value_n) }]

Where `indentifier_1 ... identifier_n` are optional distinct identifiers and
`value_1 ... value_n` are optional integer values. The identifiers, when
present, are associated with values of the type.

**BER encoding**. Primitive. The contents octets give the value of the
integer, base 256, in two's complement form, most signficant digit first, with
the minimun number of octets. The value 0 is encoded as a single 00 octet.

**DER encoding**. Same as BER.

Examples

| Value | Encoding    |
|-------|-------------|
|    0  | 02 01 00    |
|  127  | 02 02 00 7F | (why not 02 01 7F)
|  128  | 02 02 00 80 |
|  256  | 02 02 01 00 |
| -128  | 02 01 80    |
| -129  | 02 FF 7F    |


### BIT STRING

An arbitrary string of bits.

ASN.1. notation:

    BIT STRING

**BER encoding**.

Primitive or constructed. In primitive encoding the first
content octet gives the number of bits by which the length of the bit string is
less than the next multiple of eight (the number of unused bits in the tail).
The second and following octets give the value of the bit string, converted to
an octet string. Padding is eventually done in the tail.

In constructed encoding, the content octets give the concatenation of the BER
encoding of consecutive substrings of the bit string, where each substring
except the last has a length that is a multiple of eight bits.

The padding bits can have any value.

**DER encoding**. Primitive. The content octets are as for a primitive BER
encoding, except that the bit string is padded with zero-valued bits.

Example. Encoding of the same bit string value: "011011100101110111"

    03 04 06 6e 5d c0       DER encoding
    03 81 04 06 6e 5d c0    Long form of length octets
    23 09                   Constructed encoding : "0110111001011101" + "11"
       03 03 00 6e 5d
       03 02 06 c0

### OCTET STRING

An arbitrary string of octets.

ASN.1 notation:

    OCTET STRING [SIZE ({size | size_1 .. size_2})]

where `size`, `size_1 .. size_2` are optional size constraints.
In the form `size_1 .. size_2` the octet string must have between `size_1` and
`size_2` octets.

**BER encoding**

Primitive or constructed. In primitive encoding the contents octet are the
characters in the IA5 string, encoded in ASCII. In constructed encoding,
the contents octets give the concatenation of the BER encodings of consecutive
substrings of the OCTET STRING.

**DER encoding**. Primitive.

### IA5String

An arbitrary string of IA5 characters (same as ASCII).

ASN.1 notation:

    IA5String

**BER encoding**.

Primitive or constructed. In primitive encoding the contents octets give the
value of the octet string, first octet to last octet. In constructed encoding,
the contents octets give the concatenation of the BER encodings of consecutive
substrings of the IA5 string.

**DER encoding**. Primitive.

### PrintableString

An arbitrary string of printable characters from the following character set:

    A .. Z
    a .. z
    0 .. 9
    (space) ' ( ) + , - . / : = ?

ASN.1 notation:

    PrintableString

Encoding is equal to the IA5String encoding.

### OBJECT IDENTIFIER

Is a sequence of integer components that identify a well-known object such as
an algorithm or a directory-name attribute. Can have any number of components
and components can have any non-negative value. There are at least two
components. Values are assigned by *registration authorities*.

ASN.1 notation:

    { [identifier] component_1 ... component_n }

    component_i = identifier_i | identifier_i(value_i) | value_i

Where `value_1 ... value_n` are optional integer values.

The form without `identifier` is the "complete" value with all its components;
the form with `identifier` abbreviates the beginning components with another
object identifier value.

The identifiers `identifier_1 ... identifier_n` are intended for documentation,
but they must correnspond to the integer value when both are present.
These identifiers can appear without integer values only if they are among a
small set of identifiers defined in X.208.

Example
    
    { iso(1) member-body(2) 840 113549 }
    { 1 2 840 113549 }

**BER encoding**.

Primitive. the contents octets are the concatenation of n-1
octet strings, where n is the number of components in the complete object
identifier.

The first subidentifier is encoded base 40: `40⋅value_1 + value_2`. Thus
`value_2` is limited to the range 0 to 39.

The other identifiers are encoded, base 128, most significant bit first,
with as few digits as possible, and with bit 8 of each octet except the last
set to `1`.

**DER encoding**

Same as BER.

Example. Encoding of { 1 2 840 113549 1 }

    1 * 40 + 2 = 42 = 0x2A
    840 = 0x86, 0x48
    113549 = 0x86, 0xF7, 0x0D

    Encoding (TAG,LEN,VAL): 06 07 2A 86 48 86 F7 0D 01

### ANY

Denotes an arbitrary value of an arbitrary type.

ASN.1 notation:

    ANY [DEFINED BY identifier]

where *identifier* is an optional identifier. In the `ANY` form, the actual type
is indeterminate. The `ANY DEFINED BY` identifier can only appear in a component
of a `SEQUENCE` or `SET` type for which *identifier* identifies some other
component with type `INTEGER` or `OBJECT IDENTIFIER`. In that form, the actual
type is determined by the value of the other component, either in the
registration of the object identifier value, or in a table of integer values

**BER/DER encoding**. Same as BER/DER encoding of the actual value.

### CHOICE

A union of one or more alternatives.

ASN.1 notation:

    CHOICE {
        [identifier_1] Type_1
        ...
        [identifier_n] Type_n
    }

Where `identifier_1`, ..., `identifier_n` are optional, distinct identifiers
for the alternatives, and `Type_1`, ..., `Type_n` are the types alternatives.

The types must have distinct tags (explicit/implicit tagging may be required).

**BER/DER encoding**. Same as BER/DER encoding of the chosen alternative.


### Tagged types

Tagging allows to specify the presence of an optional parameter withing a
data structure. The mechanism allows to avoid ambiguity in the case that
one optional element preceeds another with the same type.

With tagging the decoder can decide whether the value is for the optional
element or for the element that follows. That is, we assign a special tag
to the optional element.

#### Implicit

Is a type derived from another by changing the tag of the underlying type.
Implicit tagging is mainly used for optional SEQUENCE components.

ASN.1 notation:

    [[class ]number] IMPLICIT Type

    class = UNIVERSAL | APPLICATION | PRIVATE

Where *Type* is a type, *class* is an optional class name, and *number* is the
tag number within the class, a non-negative integer. If the class name is
absent, then the tag is CONTEXT-SPECIFIC.

**BER/DER encoding**. Primitive or constructed, depending on the underlying
type. Content octets are as for the BER/DER encoding of the underlying value.

With implicit tags the decoder must, implicitly, know the type of the
underlying type, this is because the real type has been masked by the tag.
The advantage of implicitly tagged types is that they require less space to
be serialized.

### Explicit

Is a type derived from another by adding an outer tag (and length = 1) to the
underlying type. Indeed is encoded like a constructed type with one element.

ASN.1 notation:

    [[class ]number] EXPLICIT Type

    class = UNIVERSAL | APPLICATION | PRIVATE

Where *Type* is a type, *class* is an optional class name, and *number* is the
tag number within the class, a non-negative integer. If the class name is
absent, then the tag is CONTEXT-SPECIFIC.

If the IMPLICIT/EXPLICIT keyword is not specified then EXPLICIT is taken as
the default.

**BER/DER encoding**. Constructed. Contents octets are the BER/DER encoding of
the underlying value.

With explicit tags the decoder will be able to decode the type even without
known, a priori, the type of the tagged value. Another importand advantage
of explicit tags is that the type con be changed in the future without
changing the tag.

## References

- [Layman's Guide to ASN1](http://luca.ntop.org/Teaching/Appunti/asn1.html)
