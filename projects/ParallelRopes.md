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

#### Note ####

If you want to, you are also allowed to do this project in Java, but you must re-implement *all* functions yourself!
