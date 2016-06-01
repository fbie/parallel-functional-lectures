# Parallel Immutable Functional Data Structures #

In lecture two, we introduced the Rope type, which is a binary tree with lists at its leaves. We have looked at how to parallelize a few functions, but there is more work to be done! You can find the source code [here](https://raw.githubusercontent.com/fbie/parallel-functional-lectures/master/2/ropes.rkt).

### Your Task ###

You are required to implement parallel versions of the following functions:

1. ```rope-map-reduce```
2. ```rope-reverse```

The type of ```rope-map-reduce``` is ```(All (A B) (-> (-> A B) (-> B B B) (Ropeof A) B))```. It is a combination of ```rope-map``` and ```rope-reduce``` and where you first apply a function to all elements of the rope and then reduce the elements by means of another function. You can use it to implement ```rope-reduce``` very conveniently:

```
(: rope-reduce (All (A B) (-> (-> A B) (Ropeof A) (Ropeof B))))
(define (rope-reduce f rope)
  (rope-map-reduce (lambda ([a : A]) a) f rope))
```

Furthermore, implement ```rope-back-reduce``` that starts at **the end** of the rope and works backwards to the front! You will need a new function ```list-back-reduce``` to implement this properly.

As a bonus, you can try to implement ```rope-zip-with``` of type:

```(All (A B C) (-> (-> A B C) (Ropeof A) (Ropeof B) (Ropeof C)))```

It does not have to be parallel.

### Predicate Checking ###

Moreover, we want to be able to check whether a predicate (a function of type ```(All (A) (-> A Boolean))```) holds for all or for at least one element of the rope. These functions are called ```rope-for-all``` and ```rope-exists``` and are both of type ```(All (A) (-> (-> A Boolean) (Ropeof A) Boolean))```. Implement these as well and parallelize them. There are different ways to do so, document your choice and implementation.

### Scan ###

To go even further, you can implement a function called ```rope-scan```. Sometimes, *scan* is also called *prefixSums*. It behaves like this:

```
(list-scan + 0 '(1 2 3 4)) -> '(0 1 3 6 10)
(list-scan list-append '() '('(1) '(2) '(3) '(4))) -> '('() '(1) '(1 2) '(1 2 3) '(1 2 3 4))
```

Its type is:

```
(: list-scan (All (A A) (-> (-> A A A) A (Listof A) (Listof A))))
```

You may need to implement ```list-scan``` yourselves.

### Other Requirements ###

You are not required to perform any benchmarking of the parallel code.

### Note ###

If you want to, you are also allowed to do this project in Java, but you must re-implement *all* functions yourself!
