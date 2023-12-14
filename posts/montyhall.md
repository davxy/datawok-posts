+++
title = "The Monty Hall Problem"
date = "2017-07-05"
tags = ["probability"]
+++

The Monty Hall problem is a counter-intuitive statistics puzzle loosely
based on the American television game show *Let's Make a Deal* and named
after its original host, Monty Hall.

## The Game

- There are three doors, behind which are two goats and a car;
- You randomly pick a door;
- Monty, examines the other two doors and always opens one of them with
  a goat.

Do you stick with the original guess or switch to the other unopened door?

Surprisingly, the odds to win the car are 1/3 if you stick with the original one
but goes to 2/3 if you switch the door.

The game is about re-evaluating your decisions as new information emerges.

## Proof

Initially you can pick up one of three doors. Only one with the car.
Assume that the door with the car is W and the other two are B and C.

Let's enumerate the possible cases:

1. If you choose W then Monty removes B or C.
   Thus, if you stick with the original choice you win, else you loose.
2. If you choose B then Monty removes C.
   Thus, if you stick with the original choice you loose, else you win.
3. If you choose C then Monty removes B.
   Thus, If you stick with the original choice you loose, else you win.

As you can see from the evidence:
- If you don't change your choice you loose 2/3 of the times.
- If you change your choice you win 2/3 of the times.

## Generalization

The problem can be generalized to N doors. Where only one has a car behind.

If you stick with the original choice the odds to win are just 1/N, but if
you change your mind, after that Monty has removed N-2 goats, then the odds
to win magically becomes (N-1)/N. Pretty impressive.

To better understand why this works, another, alternative, approach to the
problem is needed.

If you change your initial choice is like if, initially, you are not trying
to pick the door with the car but a door with a goat, which has probability
(N-1)/N). Then Monty will always make you the favor of removing the other
N-2 bad cases and what is left is, eventually, the fortunate case.
