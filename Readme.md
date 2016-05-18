# Parallel Functional Programming Lectures #

Code and slides (and code for slides) for four lectures on parallel functional programming in Typed Racket and Java. In the Java world, we will also look at concurrency.

## Lecture 1: Functional Programming in Racket ##

### Content ###

This lecture briefly introduces functional programming in Typed Racket. We want to look at persistent data types, such as classical *cons*-lists and binary trees, and higher-order functional programming, the option type and manual typing.

We will not cover topics such as monads (even though we will look at the *Maybe* type), lenses and function composition in general. Mostly, we want to get familiar with the, to most of you, unfamiliar syntax of Typed Racket.

### Reading Material ###

- [Slides for lecture 1](https://github.com/fbie/parallel-functional-lectures/raw/master/1/slides/1.pdf)
- [The Racket Guide: Types in Typed Racket](https://docs.racket-lang.org/ts-guide/types.html)

## Lecture 2: Parallel Computations on Immutable Data Structures ##

#### Content ####

Parallel programming is difficult to get right if there is a lot of mutable state involved. In particular, programmers have to decide in advance how they want to distribute work across the available threads.

With modern thread schedulers and the concept of *Futures* however, we can leave the problem of distributing work to the run-time scheduler. To do so in a functional language, we need to represent arrays in a way that lets us use the scheduler efficiently.

One such way is the *Rope* data structure. A rope is a binary tree with lists (or arrays) at its leaves. In this lecture, we will look at how to define commonly used operations on container types, such as concatenation, ```map```, ```zip``` and ```fold``` and how to parallelize those which can be parallelized.

#### Reading Material ####

- [Michael Erdmann: **Parallelism, Cost Graphs, and Sequences**, lecture notes](http://www.cs.cmu.edu/~15150/resources/lectures/19/Parallelism.pdf)
- [Hans-J. Boehm et al.: **Ropes: an Alternative to Strings**](http://citeseerx.ist.psu.edu/viewdoc/download;jsessionid=02A88073F0332A35BA9A5EA132887B13?doi=10.1.1.14.9450&rep=rep1&type=pdf) (optional)

#### Installing Racket ####

If you are on Ubuntu Linux, you can install Racket and DrRacket via the command line:

```
$ sudo apt-get install drracket
```

On MacOSX you can use brew:

```
$ brew install racket
```

On Windows, you will have to download the file from the web-site and install it manually.

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

In lecture two, we introduced the Rope type, which is a binary tree with lists at its leaves. We have looked at how to parallelize a few functions, but there is more work to be done! You can find the source code [here](https://raw.githubusercontent.com/fbie/parallel-functional-lectures/master/2/ropes.rkt).

You are required to implement parallel versions of the following functions:

1. ```rope-reduce```
2. ```rope-map-reduce```
3. ```rope-reverse```

Is it possible to parallelize ```rope-fold```?

Moreover, we want to be able to check whether a predicate (a function of type ```(All (A) (-> A Boolean))```) holds for all or for at least one element of the rope. These functions are called ```rope-for-all``` and ```rope-exists``` and are both of type ```(All (A) (-> (-> A Boolean) (Ropeof A) Boolean))```. Implement these as well. There are different ways to do so, explain your choice and implementation.

As a bonus, you can try to implement ```rope-zip-with``` of type ```(All (A B C) (-> (-> A B C) (Ropeof A) (Ropeof B) (Ropeof C)))```, in sequential and in parallel. This is probably a bit more difficult.

The most difficult task is to implement a function called ```rope-scan```. Sometimes, *scan* is also called *prefixSums*. The definition is (in pseudo-code):

```
(list-scan + 0 '(1 2 3 4)) -> '(0 1 3 6 10)
(list-scan list-append '() '('(1) '(2) '(3) '(4))) -> '('() '(1) '(1 2) '(1 2 3) '(1 2 3 4))
```

First, implement this function sequentially, without any futures. Then, read this paper on parallelizing prefix-sums computations: [Guy Blelloch: Prefix sums and their applications ](http://repository.cmu.edu/cgi/viewcontent.cgi?article=3017&context=compsci) (sections 1 and 2 only). Try to see whether you can apply what you have learned from reading sections 1 and 2 to parallelize your implementation of ```rope-scan```.

You are not required to perform proper benchmarking of the parallel code. You are of course allowed to, if you want to, but it is not a requirement. We would like to see however that you use the [Future Visualizer](https://docs.racket-lang.org/future-visualizer/index.html) to see how much parallelism you achieve. Document your results and include them in your hand-in.

### A Tiny Language Implementation ###

The file [mathlang.rkt](https://github.com/fbie/parallel-functional-lectures/blob/master/projects/lang/mathlang.rkt) implements a tiny arithmetic language with Racket-style syntax. You can execute a statement in this language by using the ```parse``` and ```eval``` functions:

```
(eval (parse '(+ 1 2)) '())
(eval (parse '(let (x 5) (+ x x))) '())```
```

(```'()``` is the empty environment or value store for the start of the execution.)

The language consists of two steps: a parser that turns the expression into an abstract syntax tree (AST) and an interpreter that traverses the AST and executes the commands in it.

Your task in this project is to extend the ```eval``` and ```parse``` functions in various ways:

1. Implement the remaining arithmetic operators.

2. Add a new operator ```neg``` which takes only one argument and produces the negative value of it.

3. Add boolean expressions, just like we have arithmetics, called ```Bool```. We need ```=``` ```<``` and ```>``` operators. Make sure to change the type of ```Env``` to ```(U Number Boolean)``` to also be able to store booleans. Also, you need to change the return type of eval to ```(U Number Boolean)```.

4. What fun are boolean expressions without if-statements? Implement an if-expression called ```Cond```, with the following syntax: ```(if b e1 e2)``` (you can parse it using ``` `(if ,b ,e1 ,e2)``` to match the expression). If ```b``` evaluates to true, execute ```e1```, otherwise execute ```e2```.

5. What would it take to add lambda expressions and application to the language? Can you implement it? Give it a try! It would be nice if you could bind lambdas to names using ```let```.  All lambdas should only be of type ```(-> Number Number)```.

6. The file also contains the definition of a very simple and tiny type inference algorithm. Because our language is not polymorphic, it only contains types for numbers and booleans. Extend it such that all the new functions you have added can be type checked. For extra points, you can also implement polymorphic functions and then implement Hindley-Milner type inference for them.

Some test expressions:

For 1:
```
(eval (parse '(* 2 5)) '())
(eval (parse '(let (x (* 2 5) (/ x x)))) '())
```

For 2:
```
(eval (parse '(neg 3)) '())
(eval (parse '(let (x 4) (neg x))) '())
```

For 3:
```
(eval (parse '(< 3 4)) '())
(eval (parse '(let (x 123) (= x 123))) '())
```

For 4:
```
(eval (parse '(if (< 1 2) 1 2)) '())
(eval (parse '(let (x 3) (let (y 2) (if (= x 0) y (/ y x))))) '())
```

For 5:
```
(eval (parse '(let (f (lambda (x) x)) (f 1))) '())
(eval (parse '(let (f (lambda (x) (* 2 x))) (f 2))) '())
```

For 6:
```
(type (parse '(let (x 2) (+ x x))) '())
(type (parse '(let (x 0) (if (= x 0) 1 x))) '())
```

## Useful Links ##

- [The Racket Website](http://racket-lang.org/)
- [The Racket Guide: Types in Typed Racket](https://docs.racket-lang.org/ts-guide/types.html)
- [The Racket Guide: Parallelism with Futures](https://docs.racket-lang.org/guide/parallelism.html)
- [Documentation for Java 8  ```java.util.concurrent```](http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/package-summary.html)
- [Documentation for Java 8 ```java.util.streams```](http://docs.oracle.com/javase/8/docs/api/java/util/stream/package-summary.html)
- [Documentation for Java 8 functional interfaces](http://docs.oracle.com/javase/8/docs/api/java/util/function/package-summary.html)
