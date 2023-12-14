+++
title = "Buddy Memory Allocator"
date = "2016-05-09"
tags = ["programming","os-dev"]
+++

Buddy memory allocator is a memory management technique that divides memory
into fixed-size blocks and allocates them based on power-of-2 sizes, allowing
efficient allocation and deallocation with minimal fragmentation.


## Introduction

At any point in time, the memory consists of a collection of *blocks* of
consecutive memory, each of which is a size of a power of two. Each block is
marked either *busy* or *free*, depending on whether it is allocated to the
user.

For each block we also know its *order*, that is equal to the logarithm, base 2,
of the "block-size" divided by the "block unit size". The block unit size is the
power of two value representing the minimum block size that is allocable.

The system provides two operations for supporting dynamic memory allocation:

- **Allocation**: finds a free block that satisfies the requested size eventually
splitting a bigger block in smaller power of two blocks, marks is as busy, and
returns a pointer to it.

- **Deallocation**: marks a previously allocated block as free and may merge it
with others to form a larger free block.


## Allocation

The buddy system maintains a list of the free blocks of each order, so that it
is easy to find a block of the desired order, if one is available. If no block
of the requested order is available, *allocate* searches for the first non-
empty list for blocks of at least the size requested. In either case, a block is
removed from the free list.

If the found block is larger that the requested size, say b^k instead of the
desired b^i, with k > i, then the block is split in half, making two blocks of
size b^(k-1). If this is still too large, k-1 > i, then one of the blocks of
size b^(k-1) is split in half. This process is repeated until we have blocks of
size b^(k-1), b^(k-2),..., b^(i+1), b^i. Then one of the blocks of size b^i is
marked as busy and returned to the user. The others are added to the appropriate
free list.

```
        +---------------------------------------------------------------+
    512 |                               S                               |
        +-------------------------------+-------------------------------+
    256 |               S               |               F               |
        +---------------+---------------+-------------------------------+
    128 |       S       |       F       |
        +-------+-------+---------------+
     64 |   S   |   F   |                        S - split
        +-------+-------+                        F - free
     32 | B | F |                                B - busy
        +-------+
```

The allocator user usually asks for a chunk of memory of certain size. It
doesn't know about memory blocks and internal things. Thus, there will be a
wrapper function that takes as parameter a generic size. This size will be
rounded to the next power of two and the buddy allocator is then invoked.

Pseudocode to allocate a block of order n:

```
    block allocate(order n)
        if the list of free blocks of order n is not empty
            return the first block in that list
        else
            B = allocate(n+1)
            <B1,B2> = split(B);
            append B2 to the free-list of order n
            return B1;
```

The only data structure we need at this point is an array a list of free blocks. One array element for each possible order

```cxx
    struct list_link free_list[MAX_ORDER];
```

With the `prev` and `next` pointers for the lists stored directly in the free
blocks themselves.


## Deallocation

When a block is freed, the buddy system checks whether the block can be merged
with any other, or more precisely whether we can undo any splits that were
performed to make this block. Each block B (except the initial block) was
created by splitting another into two halves, B1 and B2. Note that each one is
the unique *buddy* of the other.

The merging process checks whether the buddy of a freed block is also free, in
which case the two are merged; then it checks whether the buddy of the resulting
block is also free, in which case they are merged; and so on.

Because the buddy systems is often used in contexts where the address returned
to the user must be aligned to the unit block (e.g. as a physical page frames
allocator) we cannot store block information within the block itself, but we'll
store the meta-information in a dedicated memory chunk.

Because of the way we split any merge blocks, blocks stay *aligned* relatively
to the first block address. More precisely, the relative address of a block of
size 2^k ends with k zeros. As a result, to find the address of the buddy of a
block of size 2^k we simply flip the (k+1)-st bit from the right.

Once we have the address of the block buddy we must check whether it's free
or not. We could look through the free list of order n, but there could be
thousands of blocks and walking the list is hard on the cache. Instead, we'll
use some extra meta-information.

For each order n we maintain a couple of structures:

- a list of free blocks;
- a bitset representing each possible block (of a given order).

To access to the correct bit in a particular order bitset we infer the
`block_index` using the block address and the block order. Given a unit block
size equal to `1 << unit_bit` then

```cxx
    index = (block_address - base_address) >> (unit_bit + order);
```

That is, we just need to divide the relative block address by `2^(unit_bits+order)`. 

Note that by working on the relative address we are independent of the pool
alignment. Otherwise, it is mandatory to have a base address that is aligned to
the size of the unit block.

The overhead of storing these extra bits is one byte for every 8 blocks of a
given order. But in fact we can do better, we can get by with just half a bit
per block.

For each pair of buddies B1 and B2 we store a single bit representing
`is_free(B1) XOR is_free(B2)`. We can easily maintain the state of that bit by
flipping it each time one of the buddies is freed or allocated.

When we consider making a merge we know that one of buddies is free, because it
is only when a block has just been freed that we consider a merge. This means we
can find out the state of the other block from the xor-ed bit. If it is 0, then
both blocks are free, if it is 1 then it is just our block that is free. Thus,
we've reduced the bitset overhead by a factor of two.


## References

- Simple C [implementation](https://github.com/davxy/buddy-alloc)
- [Linux Physical Page Allocation](https://www.kernel.org/doc/gorman/html/understand/understand009.html)
- [Bitsquid Allocation Adventures](http://bitsquid.blogspot.it/2015/08/allocation-adventures-3-buddy-allocator.html)
