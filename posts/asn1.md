+++
title = "Abstract Syntax Notation 1"
date = "2017-03-02"
tags = ["standards","encoding"]
+++

ASN.1 is a standard notation syntax defined in ITU-T X.680 to describe
rules and structures for representing data in telecommunications and
computer networking.

ASN.1 itself does not mandate any encoding or parsing rules, but usually
ASN.1 data structures are encoded using the Basic Encoding Rules (BER),
described in ITU-T X.690, or the Distinguished Encoding Rules (DER), a
subset of BER.

There is generally more than one way to BER-encode a given value
but there is only one way to DER-encode it.

The formal rules enable representation of objects that are independent
of a machine-specific encoding techniques. Thus facilitates the exchange
of structured data, particularly between programs separated by networks.

DER and BER encodings are binary Tag-Length-Value (TLV) encodings that
are quite concise compared to other popular description formats such
as XML, JSON, etc.

## Notation

- Layout is not significant; multiple spaces and line breaks can be
considered as a single space.
- Comments are delimited by a pairs of hyphens (--), or a pair of hypens
  and a line break.
- Identifiers (names of values and fields) and type references (names of
  types) consist of upper- and lower-case letters, digits, hyphens, and
  spaces; identifiers begin with lower-case letters; type references begin
  with upper-case letters.

## Types and Values

In ASN.1, a type is a set of values. For some types, there are a finite
number of values, and for other types there are an infinite number.
A value of a type is an element of the type's set.

There are four kinds of type:
- simple: atomic types with no components;
- structured: have components;
- tagged: derived from other types;
- others: CHOICE and ANY type.

Types and values can be given names with the ASN.1 assignment operator
(`::=`), and those names can be used in defining other types and values.

Every type, other than CHOICE and ANY has a **tag**, which consists of a
class and a non negative tag number. There are four classes of tag:
- *Universal*: for types whose meaning is the same in all applications.
- *Application*: for types whose meaning is specific to an application.
- *Private*: for types whose meaning is specific to a given enterprise.
- *Context-specific*: for types whose meaning is specific to a given
  structured type; context-specific tags are used to distinguish between
  component types with the same underlying tag within the context of a
  given structured type. Component types in two different structured
  types may have the same tag and different meanings.

Types with universal tags are defined in X.208, which also gives the
types universal tag numbers. Some common types and their universal-class tags:

| Type                      | Tag |
|---------------------------|-----|
| INTEGER                   | 2   |
| BIT STRING                | 3   | 
| OCTET STRING              | 4   |
| NULL                      | 5   |
| OBJECT IDENTIFIER         | 6   |
| SEQUENCE and SEQUENCE OF  | 16  |
| SET and SET OF            | 17  |
| PrintableString           | 19  |
| IA5String                 | 22  |
| UTCTime                   | 23  |


### Simple types

Relevant types, for PKCS standards, are:
- BIT STRING, an arbitraty string of bits.
- IA5String, an arbitraty string of IA5 (ASCII) characters.
- INTEGER, an arbitrary integer.
- NULL, a null value.
- OBJECT IDENTIFIER, a sequence of integer components that identify an
  arbitrary object (e.g. an algorithm or a type)
- OCTET STRING, an arbitrary string of octets (eight bit values)
- PrintableString, an arbitrary string of printable characters
- UTCTime, a "coordinated universal time" or GMT value.

Simple types fall into two categories: string types and non-string types.
The string types can be given size constraints limiting the length of
values.

### Structured types

ASN.1 defines four.
- SEQUENCE, an ordered collection of one or more types.
- SEQUENCE OF, an ordered collection of zero or more occurrences of a given
  type.
- SET, an unordered collection of one or more types.
- SET OF, an unordered collection of zero or more occurrences of a given
  type

Structured types can have optional components, possibly with default values.

### Tagged types

Tagging is useful to distinguish component types within an application; it is
also commonly used to distinguish component types within a structured type. For
instance, optional components of a SET or SEQUENCE type are typically given
distinct context-specific tags to avoid ambiguity.

There are two ways to tag a type: implicitly and explicitly.
Implicitly tagged types are derived from other types by changing the tag of the
underlying type. Explicitly tagged types are derived from other types by adding
an outer tag to the underlying type. In effect, explicitly tagged types are
structured types consisting of one component, the underlying type.

ASN.1 syntax for implicit tagged type
    [class number] IMPLICIT

ASN.1 syntax for explicit tagged type
    [class number] EXPLICIT

When not specified, the keyword `[class number]` alone, defaults to explicit,
except when the "module" in which the ASN.1 type is defined has implicit tagging
by default.

For purposes of encoding, an implicitly tagged type is considered the same as
the underlying type, except that the tag is different.

Implicit tags result in shorter encodings, but explicit tags may be necessary to
avoid ambiguity if the tag if the underlying type is indeterminate (e.g. the
underlying type is CHOICE or ANY).

### Other types

Other types include the CHOICE and ANY types. CHOICE type denotes a union of
one or more alternatives; the ANY type denotes an arbitrary value of an
arbitrary type.


## Example

Data structures of (a fictitious) Foo Protocol defined using ASN.1
notation:

    FooProtocol DEFINITIONS ::= BEGIN

    FooQuestion ::= SEQUENCE
    {
        id          INTEGER(0..255),
        question    VISIBLE STRING
    }

    FooAnswer ::= SEQUENCE
    {
        id          INTEGER(0,255),
        answer      BOOLEAN
    }

    END


## References

- [Layman's Guide to ASN1](http://luca.ntop.org/Teaching/Appunti/asn1.html): good ASN.1 tutorial.

