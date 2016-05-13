# Parallel Functional Programming Lectures #

Code and slides (and code for slides) for four lectures on parallel functional programming in Typed Racket and Java. In the Java world, we will also look at concurrency.

## Lecture 1: Functional Programming in Racket ##

### Content ###

This lecture briefly introduces functional programming in Typed Racket. We want to look at persistent data types, such as classical *cons*-lists and binary trees, and higher-order functional programming, the option type and manual typing.

We will not cover topics such as monads (even though we will look at the *Maybe* type), lenses and function composition in general. Mostly, we want to get familiar with the, to most of you, unfamiliar syntax of Typed Racket.

### Reading Material ###

TBA

## Lecture 2: Parallel Computations on Immutable Data Structures ##

#### Content ####

Parallel programming is difficult to get right if there is a lot of mutable state involved. In particular, programmers have to decide in advance how they want to distribute work across the available threads.

With modern thread schedulers and the concept of *Futures* however, we can leave the problem of distributing work to the run-time scheduler. To do so in a functional language, we need to represent arrays in a way that lets us use the scheduler efficiently.

One such way is the *Rope* data structure. A rope is a binary tree with lists (or arrays) at its leaves. In this lecture, we will look at how to define commonly used operations on container types, such as concatenation, ```map```, ```zip``` and ```fold``` and how to parallelize those which can be parallelized.

#### Reading Material ####

TBA

## Lecture 3 ##

#### Content ####

TBA

#### Reading Material ####

TBA

## Lecture 4 ##

#### Content ####

TBA

#### Reading Material ####

TBA

## Projects ##

We have a number of practical projects to choose from. You should choose one project in groups of 2 - 3 students, not more and not less.

### Typing an Untyped Racket Library ###

Your task is to chose an untyped library from [the Racket Package Repository](https://pkgs.racket-lang.org/) and to provide the types for it. You should annotate the package's source code with the correct types and the Typed Racket type checker should be able to check the program.

Please let me know which package you have chosen in advance, so that I can make sure that the package is not too large for you to type over the course of the project. Use the [DrRacket IDE](http://racket-lang.org/) to edit the source files and to type check the code.

### Parallel Immutable Functional Data Structures ####

In lecture two, we introduced the Rope type, which is a binary tree with lists at its leaves. We have looked at how to parallelize a few functions, but there is more work to be done!

