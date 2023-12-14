+++
title = "Regular Expressions Essentials"
date = "2016-01-16"
tags = ["regex"]
+++

A regular expression is a sequence of characters that define a search pattern.

Each character in a regular expression is understood to be: a *metacharacter* or
a regular character. Pattern-matches can vary from a precise equality to a very
general similarity (controlled by the metacharacters).

If there exists at least one regular expression that matches a particular set
then there exists an infinite number of other regular expression that also match
it, the specification is not unique.

Regular expressions look a lot like the file matching patters the shell uses.
They even act almost the same way.

Meta characters are expanded before the shell passes the arguments to the
program. To prevent this expansion, the special characters in a regular
expression must be quoted when passed as an option from the shell.

## Structure

There are three important parts.
- **Anchors** - used to specify the position of the pattern in relation to a
line of text;
- **Character Sets** - match one or more characters in a single position;
- **Modifiers** - specify how many times the previous character set is repeated

There are also two types of regular expressions: basic and extended. Few
utilities like `awk` and `egrep` use the extended expression.

## Anchors

Most Unix text facilities are line oriented. The end of line character is not
included in the block of text that is searched. It is a **separator**.

Regular expressions examine the text between the separators. Anchors are used to
search for a pattern that is at one end or at the other.

The character `^` is the starting anchor, and the character `$` is the end
anchor. The regular expression `^A` will match all lines that start with a
capital `A`. The expression `A$` will match all lines that end with the capital
`A`.

If an anchor is not used at the proper endo of pattern, then they no longer act
as anchors. If you need to match a `^` at the beginning of the line, or a `$` at
the end of a line, you must escape the special characters with a backslash.

Another anchor is the world boundary `\b`. This anchor matches a word boundary
position such as whitespace, punctuation, or the start/end of a string.

Character Sets
--------------

The simplest character set is a character. The regular expression `the` contains
three character sets: `t`,`h` and `e`. It will match any line with the string
`the` inside it.

Some characters have a special meaning in regular expressions. If you want to
search for such character, escape it with a backslash.

The character `.` is one special meta character. By itself it will match any
character, except the end of line character that is always used as separator.

To match a specific character set, the square brackets are used. You can use the
hyphen (`-`) between two characters to specify a range. The pattern that will
match any line that contains exactly one number is:

```
    ^[0-9]$
```

Explicit characters can be intermixed with character ranges. This pattern
matches a single character that is a letter, a number, or an underscore:

```
    [0-9a-zA-Z_]
```

Character sets can be combined by placing them next to each other. For example

```
    ^T[a-z][aeiou]
```

Match any word that: start with a capital letter `T`, is the first word of the
line, the second letter is a lower case letter, the third letter is a vowel, and
is exactly three characters long.

Like the anchors in places that can't be considered an anchor, the characters
`]` and `-` do not have a special meaning if they directly follow `[`.

| Expression   | Matches              |
| ------------ | -------------------- |
| `[0-9-]`     | any number or a `-`  |
| `[]0-9]`     | any number or a `]`  |
| `[0-9-z]`    | any number or any character between `9` and `z` |
| `[0-9\-a\]]` | Any number or  a `-`, a `a` or a `]` |

### Exceptions

All characters except those in the square brackets are searched by putting a `^`
as the first character after the `[`. To match all characters except vowels use:

```
    [^aeiou]
```


## Modifiers

Modifiers are used to specify how many times the previous character set should
be considered.

#### `*` modifier

The special character `\*` matches zero or more copies of a character set. For
example `p[a-zA-z]*ers ` matches any word that starts with a `p` and ends with
`ers`.

#### `\{` and `\}` modifiers

To specify the minimum and the maximum number of occurrences of a character set
you should include those two numbers between `\{` and `\}`. For example, the
regular expression to match 4,5,6,7 or 8 lower case letters is

```
    [a-z]\{4,8\}
```

Any numbers between 0 and 255 can be used, and the second one may be omitted,
removing the upper limit. If the comma is also removed, then the pattern must be
duplicated the exact number of times specified by the first number.

Remember that modifiers like `*` and `\{min,max\}` only act as modifiers if they
follow a character set. If they were at the beginning of a pattern, they would
not be modifiers.

| Expression    | Matches                                   |
|---------------|-------------------------------------------|
| `*`           | any line with an asterisk                 |
| `\*`          | any line with an asterisk                 |
| `\\`          | any line with a backslash                 |
| `^*`          | any line starting with an asterisk        |
| `^A*`         | any line (starting with 0+ `A` chars)     |
| `^A\*`        | any line starting with an `A\*`           |
| `^AA*`        | any line starting with an `A`             |
| `^AA*B`       | any line starting with one or more `A`s followed by a `B` |
| `^A\{4,8\}B`  | any line starting with 4 to 8 `A`s followed by a `B`      | 
| `^A\{4,\}B`   | any line starting with 4 or more `A`s followed by a `B`   |
| `^A\{4\}B`    | any line starting with `AAAAB`            |
| `\{4,8\}`     | any line with `{4,8}`                     |

#### `\<` and `\>` modifiers

To match a word one can put spaces before and after the first and the last
letter respectively. However, this does not match words at the beginning and at
the end of the line. And does not match the case where there is a punctuation
mark after the word.

The characters `\<` and `\>` are similar to the line anchors, as they don't
occupy a position of a character. As an example the pattern to search for the
world `the` or `The` would be `\<[tT]he\>`.

#### Back-references

Another pattern that requires a special mechanism is searching for repeated
words. The expression `[a-z][a-z]` will match any two lower case letters.

Part of a pattern can be marked using `\(` and `\)`. You can recall part of
a pattern with `\` followed by a single digit. Therefore, to search for two
identical letters, use `\([a-z]\)\1`. You can have 9 different remembered
patterns. Each occurrence of `\(` starts a new pattern. The regular expression
that would match a 5 letter palindrome, (e.g. `radar`) would be

```
    \([a-z]\)\([a-z]\)[a-z]\2\1
```


## References

- [Bruce Barnet Tutorial](http://www.grymoire.com/Unix/Regular.html): excellent regular expressions article.
- [RexExr](http://regexr.com): online tool to learn, build and test regular expressions.
