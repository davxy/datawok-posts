+++
title = "Object-Oriented Programming in C"
date = "2015-03-22"
modified = "2015-03-22"
tags = ["programming"]
toc = true
+++

In this exploration, we delve into the realms of object-oriented programming
(OOP) through an unconventional lens: employing the standard C programming
language.

Traditionally, C is perceived as a procedural language, lacking the built-in
features that support OOP directly. However, this post aims to bridge that
gap by demonstrating how one can implement four cornerstone concepts of
object-oriented programming in C:
- Data Abstraction
- Encapsulation
- Inheritance
- Polymorphism

Through creative use of C's capabilities, we'll showcase how the language can
be stretched beyond its conventional boundaries, offering a fresh perspective
on its versatility. This journey not only highlights the adaptability of C but
also provides valuable insights into the core principles of OOP, making them
accessible to those who primarily operate in a procedural programming context.


## Data Abstraction

Data abstraction is a pivotal programming paradigm that emphasizes the
separation between an object's interface and its underlying implementation.

Consider the concept of a person. Generally, when we think about a person
(excluding medical professionals), we overlook the internal workings and focus
instead on the interactions we have with them, essentially their interface.

The essence of a type interface lies in detailing the actions an object can
perform. For a person, these actions might include talking, walking, eating,
and dancing.

Object-oriented languages typically offer specialized syntax to define a
type interface, encapsulating functionality within the class through public
functions, often referred to as methods.

To illustrate, we will create a stack container type, equipped with a suite
of methods:

- Constructor
- Destructor
- Obtaining the current size
- Adding an element to the top (push)
- Removing the top element (pop)
- Retrieving the top element (peek)

In C++, the definition for such a type might look like this:

```cpp
    class stack {
    private:
        value_type *data;
        size_t      size;

    public:
        typedef float value_type;

        stack();
        ~stack();
        size_t size() const;
        void push(value_type val);
        value_type pop();
        value_type peek() const;
    };
```

A key aspect here is that, when a method of an object is called, the compiler
automatically passes a hidden parameter, often named "this," which is a pointer
to the object being manipulated.

In C, which lacks built-in support for this object-oriented construct, data and
interface are inherently separate. Nonetheless, we can mimic object-oriented
behavior by explicitly passing a pointer to the object structure for each
function that forms part of the interface.

Structure definition:

```c
    typedef float stack_value_t;

    typedef struct stack {
        stack_value_t  *data;
        size_t          size;
    } stack_t;
```

And the corresponding stack interface:

```c
    void stack_construct(stack_t *self);
    void stack_destroy(stack_t *self);

    size_t stack_size(const stack_t *self);

    void stack_push(stack_t *self, stack_value_t val);
    stack_value_t stack_pop(stack_t *self);
    stack_value_t stack_peek(const value_t *self);
```


## Encapsulation

Encapsulation refers to the practice of concealing the intricacies and design
choices within a piece of code. This concept proves particularly beneficial
in library development, where there's a need to shield users from internal
complexities or when those internals might evolve over time.

A common method to achieve encapsulation is through **information hiding**.
This involves keeping structure definitions within the source file rather than
exposing them in the header file. As a result, users are allowed to interact
with the data type exclusively via its defined interface, remaining oblivious to
its internal structure.

Such an approach often employs what is known as an **opaque** pointer, which
points to a structure defined in the source file but remains hidden from the
user.

While this method enhances safety by preventing direct access to the object's
structure, it also imposes certain limitations. Specifically, objects can no
longer be instantiated as global variables or on the stack. Instead, users must
dynamically create these objects through specific functions that allocate memory
on the heap. This characteristic may not always be desirable.

Additionally, with dynamic allocation comes the responsibility for users to
free the memory associated with these objects when they are no longer needed,
introducing a manual memory management requirement.

```c
    object_type *obj = object_create(); /* the only way to create the object */
    /* use it ... */
    object_delete(obj); /* remember to delete it */
```

**Example**

Building on the data abstraction example, encapsulating the stack type involves
moving its structure definition from the header file to the source file. In
the header file, we retain a forward declaration of the opaque structure. This
informs the compiler of the type's existence without disclosing its composition.

```c
    struct stack;
    typedef struct stack stack_t;
```


## Inheritance

Inheritance is a foundational concept in object-oriented programming that
allows for the creation of new types by building upon existing ones. This
process involves inheriting the behaviors and implementations of a base type,
encapsulated in the idea that a derived type "is a" specialization of its base
type.

While C does not natively support inheritance as seen in object-oriented
languages, developers can mimic this feature. This emulation leverages a
straightforward aspect of C's structure layout: the first member of a structure
aligns with the start of that structure. By placing a supposed base class
structure as the first member within a derived class structure, two key outcomes
are achieved:
- The derived class incorporates all members of the base class.
- A pointer to the derived class also functions as a pointer to the base class.

These characteristics effectively allow for the use of the derived type in any
context where the base type is applicable, thus realizing a form of inheritance.

**Example**

Consider a base class `person`:

```c
    typedef struct person {
        char        *name;
    } person_t;
```

And a derived class `student` that extends `person`:

```c
    typedef struct student {
        person_t    super;
        int         number;
    } student_t;
```

With `student_t` structured this way, any `student_t` pointer is inherently a
`person_t` pointer as well, due to the shared memory location of their first
member, enabling a `student_t` to be utilized wherever a `person_t` is expected.

The constructors and destructors for these classes emphasize managing inherited
properties alongside derived-specific attributes:

```c
    void person_construct(person_t *person, const char *name) {
        person->name = malloc(strlen(name) + 1);
        strcpy(person->name, name);
    }
    
    void person_destruct(person_t *person) {
        free(person->name);
        person->name = NULL;
    }
```

```c
    void student_construct(student_t *student, const char *name, int number) {
        person_construct(&student->super, name);
        student->number = number;
    }

    void student_destruct(student_t *student) {
        person_destruct(&student->super);
    }
```

A function meant for the person interface demonstrates how inherited members are accessed:

```c
    void person_print(person_t *person) {
        printf("name: %s\n", person->name);
    }
```

```c
    student_t stud;
    student_construct(&stud, "Davide", 123456);
    person_print((person_t *) &stud);   /* explicit cast to prevent compiler warnings */
    student_destruct(&stud);
```


## Polymorphism

Polymorphism enables the interaction with different data types through a uniform
interface. Imagine having a collection of individuals, where each individual
could be either a simple person (the base class) or a student (a derived class).
The goal is to ensure that when we call a shared function across these types,
the behavior adapts depending on whether the individual is a student or not.

In object-oriented programming languages, this flexibility is typically achieved
by incorporating a table of function pointers (commonly referred to as the
**vtable**) within the base class. Additionally, "wrapper" functions serve as
intermediaries, directing calls to the appropriate function as indicated by
the vtable entries. These indirectly invoked functions are known as **virtual
functions**.

Adapting this mechanism to C, we draw inspiration from the object-oriented
paradigm. Building upon the "inheritance" example, we augment the base `person`
class to include a pointer to a table of function pointers, effectively
introducing a virtual table:

```c
    typedef struct person {
        const void  *vtab;      /* pointer to virtual table */
        char        *name;
    } person_t;
```

Accordingly, the 'student' class is defined as an extension of 'person':

```c
    typedef struct student {
        person_t    super;      /* superclass */
        int         number;
    } student_t;
```


To override a function in a derived class, a distinct virtual table for that
subtype is established and linked to the base class's `vtab` pointer. Notably, a
virtual table is typically instantiated just once per type and shared across all
instances of that type.

Defining virtual table and function pointers types:

```c
    /* Virtual functions pointers type alias */
    typedef void (*person_destroy_f)(person_t *self);
    typedef void (*person_print_f)(const person_t *self);

    /* Person virtual table structure */
    typedef struct person_vtab {
        person_destroy_f destroy;
        person_print_f   print;
    } person_vtab_t;
```

Implementation of the virtual table, constructors, and destructors for `person`:
    
```c
    static const person_vtab_t person_vtab = {
        person_destroy,
        person_print
    };

    void person_construct(person_t *person, const char *name) {
        person->vtab = &person_vtab;    /* assign the person vtab */
        person->name = malloc(strlen(name) + 1);
        strcpy(person->name, name);
    }

    void person_destroy(person_t *person) {
        free(person->name);
        person->name = NULL;
    }

    void person_print(person_t *person) {
        printf("I'm a person\n");
    }
```
    
Implementation of the virtual table, constructors, and destructors for `student`:

```c
    static const student_vtab_t student_vtab = {
        (person_destroy_f) student_destroy,
        (person_print_f) student_print
    };

    void student_construct(student_t *student, const char *name, int number) {
        person_construct(&student->super, name); /* construct the superclass */
        student->super.vtab = &student_vtab;     /* set the student vtab */
        student->number = number;
    }

    void student_destroy(student_t *student) {
        person_destroy(&student->super);         /* destroy the superclass */
        /* Optionaly destroy resources managed by this subclass */
    }

    void student_print(student_t *student) {
        printf("I'm a student\n");
    }
```

The virtual table itself does not include constructors due to their
non-polymorphic nature. However, wrappers for virtual functions are essential to
achieve runtime polymorphism. These wrappers invoke the correct function based
on the virtual table entry associated with the specific instance:

```c
    void person_vdestroy(person_t *person) {
        ((person_vtab_t *)person->vtab)->destroy(person);
    }

    void person_vprint(const person_t *person) {
        ((person_vtab_t *)person->vtab)->print(person);
    }
```

Example usage demonstrates how polymorphism is practically applied:

Usage example:

```c
    person_t *stud = (person_t *) student_create("Davide", 3801831);
    person_vprint(stud);    /* calls student_print */
    person_vdelete(stud);   /* calls student_destroy */
```


## References


- Tibor Miseta [notes](https://ooc-coding.sourceforge.net/docs/ooc.pdf)
- [Companion Sources](/companions/cplus.tar.gz)
