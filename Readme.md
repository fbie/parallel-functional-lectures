# Parallel Functional Programming Lectures #

Code and slides (and code for slides) for four lectures on parallel functional programming in Typed Racket and Java. In the Java world, we will also look at concurrency.

## Lecture 1: Functional Programming in Racket ##

### Content ###

This lecture briefly introduces functional programming in Typed Racket. We want to look at persistent data types, such as classical *cons*-lists and binary trees, and higher-order functional programming, the option type and manual typing.

We will not cover topics such as monads (even though we will look at the *Maybe* type), lenses and function composition in general. Mostly, we want to get familiar with the, to most of you, unfamiliar syntax of Typed Racket.

### Reading Material ###

- [The Racket Guide: **Types in Typed Racket**](https://docs.racket-lang.org/ts-guide/types.html)
- [Slides](1/slides/1.pdf)
- [Code from the lecture](1/1.rkt)_

### Installing Racket ###

If you are on Ubuntu Linux, you can install Racket and DrRacket via the command line:

```
$ sudo apt-get install drracket
```

On MacOSX you can use brew:

```
$ brew install racket
```

On Windows, you will have to download the file from the web-site and install it manually.

## Lecture 2: Parallel Computations on Immutable Data Structures ##

#### Content ####

Parallel programming is difficult to get right if there is a lot of mutable state involved. In particular, programmers have to decide in advance how they want to distribute work across the available threads.

With modern thread schedulers and the concept of *Futures* however, we can leave the problem of distributing work to the run-time scheduler. To do so in a functional language, we need to represent arrays in a way that lets us use the scheduler efficiently.

One such way is the *Rope* data structure. A rope is a binary tree with lists (or arrays) at its leaves. In this lecture, we will look at how to define commonly used operations on container types, such as concatenation, ```map```, ```zip``` and ```fold``` and how to parallelize those which can be parallelized.

#### Reading Material ####

- [Herb Sutter: **The Free Lunch is Over**, Dr. Dobb's Journal](http://www.gotw.ca/publications/concurrency-ddj.htm)
- [Michael Erdmann: **Parallelism, Cost Graphs, and Sequences**, lecture notes](http://www.cs.cmu.edu/~15150/resources/lectures/19/Parallelism.pdf)
- [Hans-J. Boehm et al.: **Ropes: an Alternative to Strings**](http://citeseerx.ist.psu.edu/viewdoc/download;jsessionid=02A88073F0332A35BA9A5EA132887B13?doi=10.1.1.14.9450&rep=rep1&type=pdf)
- [Slides](2/slides/2.pdf)
- [Parallel expressions in Racket](2/parexpr.rkt)
- [Rope code from the lecture](2/ropes-lecture.rkt)

## Lecture 3: Java 8 Streams ##

#### Content ####

We will be looking at (parallel) higher order functional programming in Java.

- Brief review of Java's anonymous inner classes.
- Java 8 lambda expressions.
- Java 8 functional interfaces.
- Higher-order functional programming using lazy streams.

Java 8 streams are lazy, higher-order, declarative programming abstractions and a great tool for data-parallel programming in Java.

#### Reading Material ####

- [The Java Tutorials: **Streams and Parallelism** ](http://docs.oracle.com/javase/tutorial/collections/streams/parallelism.html)
- [Slides](3/slides/3.pdf)
- [Functional interfaces example code](3/FunctionalInterfaces.java)
- [Streams example code](3/Streams.java)
## Projects ##

We have a number of practical projects to choose from. You should choose one project in groups of 2 - 3 students, not more and not less.

Hand-in date is **2016-07-13**. Please write around two pages of explanations for your solution (in English) and hand them in by e-mail.

- [Typing an Untyped Racket Library](projects/LibraryTypes.md)
- [Parallel Immutable Functional Data Structures](projects/ParallelRopes.md)
- [A Tiny Math Language Implementation With Racket-Style Syntax](projects/MathLang.md)

**You are very welcome to propose your own project ideas, especially if they also involve Java 8 Streams!**

## Useful Links ##

- [The Racket Website](http://racket-lang.org/)
- [The Racket Guide: Types in Typed Racket](https://docs.racket-lang.org/ts-guide/types.html)
- [The Racket Guide: Parallelism with Futures](https://docs.racket-lang.org/guide/parallelism.html)
- [Documentation for Java 8  ```java.util.concurrent```](http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/package-summary.html)
- [Documentation for Java 8 ```java.util.streams```](http://docs.oracle.com/javase/8/docs/api/java/util/stream/package-summary.html)
- [Documentation for Java 8 functional interfaces](http://docs.oracle.com/javase/8/docs/api/java/util/function/package-summary.html)
