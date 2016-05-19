#lang typed/racket

;; Script for Programming Languages Seminar at UCAS, spring 2016.
;; For questions or feedback, please e-mail me at fbie@itu.dk.

(require typed/racket)

;; Racket is a Scheme-dialect. In Scheme, all expressions are lists.
;; A list is interpreted as a function call, if the first element of
;; the list is a function.

1       ;; Evaluates to 1.
"UCAS"  ;; Evaluates to "UCAS".
#t      ;; Evaluates to #t, means true.
#f      ;; Evaluates to #f, means false.
(+ 1 2) ;; Evaluates to 3.
;(+ 1 "UCAS") ;; Error! You cannot add numbers to strings.

;; We can define functions via the define keyword.

(define (add-one [n : Integer])
  (+ n 1)) ;; No return-statement needed. The last expression is the
           ;; return value of the body.

;; And then we can just call it:

(add-one 42) ;; Evaluates to 43.
(add-one 23) ;; Evaluates to 24.

;; Q: How would you write a function times-two?

;; Q: Functions also have types. What type does add-one have?

add-one

;; Typed Racket has (limited) type-inference capabilities. This means
;; that you do not need to annotate a function with all types, because
;; the compiler can infer the types of the parameters based on how you
;; use them. For instance, if you write x + 3.14, then x must be a
;; Real, because you can only add Reals to Reals.

;; This works only to some extent and usually, in Typed Racket you
;; need to annotate quite a bit. We will look at this again at a later
;; point in time during the course.

;; Assignment is done by let-bindings. A bound value is only
;; accessible in the body of the let binding. This is comparable to
;; the scope of a variable in Java, where you would say int x2 = 2 * x;:

;; The type of the function can be written like this, above the
;; "define" line. -> means function, the last type in the list is the
;; return type, the others are parameter types.
(: double-and-add (-> Integer Integer Integer))
(define (double-and-add x y)
  (let ([x2 (* 2 x)]  ;; Compute 2 * x and bind it to x2.
        [y2 (* 2 y)]) ;; Compute 2 * y and bind it to y2.
    (+ x2 y2)))       ;; Add the two results.

(double-and-add 42 23)

;; In functional programming languages, state is immutable. If you
;; bind a value to a name via let, you are not allowed to change it
;; again. Therefore, we cannot use for-loops with counters as you know
;; them from Java or C. Instead, we use recursion to implement
;; functions like is-even? or fib:

(: is-even? (-> Integer Boolean))
(define (is-even? n)
  (if (< 0 n)
      (is-even? (- n 2))
      (= n 0)))

;; Q: What does this function do? How does it do it?

(is-even? 42)
(is-even? 23)

(: fib (-> Integer Integer))
(define (fib n)
  (if (< n 1)
      1 ;; Nothing to do, return 1.
      (+ (fib (- n 2)) (fib (- n 1))))) ;; Recurse left and right and multiply results.

(fib 1)
(fib 2)
(fib 4)
(fib 8)

;; We can also define our own data structures with the struct keyword:

(struct None ())           ;; This struct contains nothing.
(struct (A) Some ([a : A]) ;; This struct contains one value of type
                           ;; A. Types must be inlined for structs. It
                           ;; is like a generic class in Java.
  #:transparent)

;; (#:transparent means that we can see what's inside the instance
;; when we print it to the console.)

;; We can define a type for which None and Some are constructors:

(define-type (Maybe A) (U None (Some A)))

;; Q: What is this type good for?

;; A Java approximation of our Maybe type:

;; public static abstract class Maybe<A> {}
;;
;; public static class None<A> extends Maybe<A> {
;;   public None() {}
;; }
;;
;; public static class Some<A> extends Maybe<A> {
;;   public final A a;
;;   public Some(A a) {
;;     this.a = a;
;;   }
;; }

;; In Java 8, this is called Optional<T>. The Maybe type is sometimes
;; also called option-type, optional or similar. Its constructors are
;; sometimes also called Nil instead of None of Just instead of
;; Some. The principle remains the same: either the instance has a
;; value or doesn't.

;; We can write a divide function, maybe-divide, which
;; This makes sense when we want to model that a computation failed
;; without throwing an exception, as in maybe-divide:

(: maybe-divide (-> Real Real (Maybe Real)))
(define (maybe-divide n d)
  (if (= d 0)
      (None)
      (Some (/ n d))))

(maybe-divide 42 23)
(maybe-divide 42 0)

;; We can use a Maybe instance to only perform a computation if a
;; value actually is present. We can PATTERN-MATCH on an instance of
;; Maybe to find out which constructor we used to instantiate it:

(: has-value? (-> (Maybe Any) Boolean))
(define (has-value? m)
  (match m
    [(None) #f]
    [(Some _) #t]))

(has-value? (maybe-divide 42 23))
(has-value? (maybe-divide 42 0))

;; This is the definition of a singly-linked list. It is either a
;; constructed list or nil, which is the end-element for all lists.
(define-type (LinkedList A) (U Nil (Cons A)))

;; Nil is nothing, it is the end of the list.
(struct Nil ())

;; Cons constructs a new linked list, taking a linked list as its
;; tail and an element. The definitions are mutually recursive.
(struct (A) Cons ([a : A] [tail : (LinkedList A)])
  #:transparent)

;; Q: What would the Java equivalent of LinkedList look like?

;; A:

;; public abstract class LinkedList<A> {}
;;
;; public class Nil<A> extends LinkedList<A> {
;;   public Nil() {}
;; }
;;
;; public class Cons<A> extends LinkedList<A> {
;;   public final A a;
;;   public final LinkedList<A> tail;
;;   public Cons(A a, LinkedList<A> tail) {
;;     this.a = a;
;;     this.tail = tail;
;;   }
;; }


;; Now, we can put values in our new list.

(ann (Cons 3 (Nil)) (LinkedList Integer))
(ann (Cons 5 (Cons 3 (Nil))) (LinkedList Integer))
;; (ann (Cons "what" (Cons 5 (Cons 3 (Nil)))) (LinkedList Integer)) ;; Types don't match!

;; We might want to know, how many elements are there in the list,
;; just as in Java, where you can use arr.length.

;; In functional programming languages, state is immutable. Therefore,
;; we cannot use for-loops with counters as you know them from Java or
;; C. Instead, we need to use recursion to build functions that
;; operate on the "recursive decomposition" of a data
;; structure. Length is a polymorphic function. You can compare it to
;; a generic method in Java.
(: Length (All (A) (-> (LinkedList A) Integer)))
(define (Length as)
  (match as
    [(Nil) 0]
    [(Cons _ tail) (+ 1 (Length tail))]))

(Length (Cons 'a (Cons 'b (Cons 'c (Nil)))))

;; Maybe we have two lists that we want to add to each other. That
;; happens often. So let's look at how to write an append function for
;; to lists.
;;
;; Q: How would you go about doing that? What are the invariants?

(: Append (All (A) (-> (LinkedList A) (LinkedList A) (LinkedList A))))
(define (Append lhs rhs)
  (match lhs
    [(Nil) rhs] ;; Nothing to do, because the left list is empty.
    [(Cons a tail) (Cons a (Append tail rhs))])) ;; Put the current element in the beginning and recurse.

(Append
 (Cons 'a (Cons 'b (Nil)))
 (Cons 'x (Cons 'y (Cons 'z (Nil)))))

;; Q: Do you start seeing a pattern?
;;
;; It seems that we always have to look at two cases:
;; - Nil, for when the list is empty. Here, we stop and return a default value.
;; - Cons, for when there is at least one element in the list left. We
;;     handle the element and then we proceed to the next element of the
;;     list, which might be either Nil or again Cons.

;; Q: Implement a function that reverses the order of elements in a
;; list, such that (Reverse (Cons 'a (Cons 'b (Nil)))) == (Cons 'b
;; (Cons 'a (Nil))). Hint: You may use Append here.

(: Reverse (All (A) (-> (LinkedList A) (LinkedList A))))
(define (Reverse as)
  (match as
    [(Nil) (Nil)]
    [(Cons a tail) (Append (Reverse tail) (Cons a (Nil)))]))

(Reverse (Cons 'a (Cons 'b (Cons 'c (Nil)))))

;; Consider the function get-first. It returns Some first element of
;; the list, or None:

(: get-first (All (A) (-> (LinkedList A) (Maybe A))))
(define (get-first as)
  (match as
    [(Nil) (None)]             ;; Nothing there.
    [(Cons a tail) (Some a)])) ;; Get the first element of the list.

;; Q: What would be a Java equivalent of get-first? Implement it using
;; the Java-class of Maybe which you saw earlier.
;;
;; public class LinkedList<A> {
;;   ...
;;   public static Maybe<A> getFirst(LinkedList<A> as) {
;;     // TODO: Your code here.
;;   }

;; As it turns out, this is a bit more cumbersome in Java, because you
;; need to explicitly check what the "a" field of the LinkedList
;; instance is set to.

;; This is a good spot for a break.

;; Let us look at higher-order functions in Racket. In Java 8, you
;; have lambda expressions, such as:
;;
;; Function<Integer, Integer> fun = (int n) -> 2 * n;
;;
;; We can do similar things in Racket:

(: fun (-> Real Real))
(define fun (lambda (n) (* 2 n)))

;; We can just call this again as usual:

(fun 23)
(fun 42)

;; But we can also pass around functions as parameters.  For example,
;; we want to execute some function only if there actually is a value
;; present:

(: maybe-map (All (A B) (-> (-> A B) (Maybe A) (Maybe B))))
(define (maybe-map f m)
  (match m
    [(None) (None)]           ;; No value, nothing to do.
    [(Some a) (Some (f a))])) ;; Call f on a and wrap result in Some.

(maybe-map fun (maybe-divide 42 23))
(maybe-map fun (maybe-divide 42 0))

;; maybe-do is a higher-order function. It accepts as parameter
;; another function, which it might execute. This is a very important
;; concept in functional programming. You can change the actual
;; behavior of a function by changing the function you pass to it.

;; Using this technique, you can apply a function to all elements of a
;; list. Say you have a list of grades for students, but you graded
;; them too low. Everyone should get 10% more. So you write:

(struct Student ([name : String] [grade : Integer]) #:transparent)

(: better-grade (-> Student Student))
(define (better-grade s)
  (Student (Student-name s) (+ (Student-grade s) 10))) ;; Increase current grade by ten.

;; Remember, you cannot change the old list.
(: everyone-better-grade (-> (LinkedList Student) (LinkedList Student)))
(define (everyone-better-grade ss)
  (match ss
    [(Nil) (Nil)] ;; End of list, nothing to do.
    [(Cons s tail) (Cons
                    (better-grade s) ;; Change the current student's grade.
                    (everyone-better-grade tail))])) ;; Continue to the next.

(: students (LinkedList Student))
(define students (Cons (Student "A" 34)
                       (Cons (Student "B" 80)
                             (Cons (Student "C" 73)
                                   (Nil)))))

;; Uh, oh. You need at least 40% in order to pass in this course...
;; Let's make a new list with the same students but better grades!
(everyone-better-grade students)

;; Okay, that was easy. But you also have a bunch of books that you
;; want to sell on the internet. You have the author and the title and
;; want to know how much they cost when purchased new. So you go:

(struct Book ([title : String] [author : String]))

(: get-book-price (-> Book Number))
(define (get-book-price b)
  (+ 100 (random 500))) ;; The mighty book price oracle has spoken.

(: get-book-prices (-> (LinkedList Book) (LinkedList Number)))
(define (get-book-prices bs)
  (match bs
    [(Nil) (Nil)]
    [(Cons b tail) (Cons (get-book-price b) (get-book-prices tail))]))

(: books (LinkedList Book))
(define books (Cons (Book "Spreadsheet Implementation Technology" "Peter Sestoft")
                    (Cons (Book "Java Concurrency in Practice" "Brian Goetz")
                          (Cons (Book "Computers and Intractability" "Michael Garey and David Johnson")
                                (Nil)))))

(get-book-prices books)

;; Do you see, what happened? We have defined two functions that
;; operate on lists and perform an action on each of the lists
;; elements. The functions look very similar: either, we have Nil and
;; the list is empty. Or, we have Cons, so there is at least one more
;; element which we can apply the function to.
;;
;; Q: Do you think we can generalize this pattern? If so, how?
;;
;; In functional programming, there are some well known higher-order
;; functions that abstract such repeating patterns. One of these is
;; Map.

(: Map (All (A B) (-> (-> A B) (LinkedList A) (LinkedList B))))

;; Map takes a function of type (-> A B) and a list of As and then
;; returns a list of Bs. This means that it applies the function to
;; each element of the original list and returns a new list. That is
;; exactly what we want, so let's take a look at how to do that.

(define (Map f as)
  (match as
    [(Nil) (Nil)]
    [(Cons a tail) (Cons (f a) (Map f tail))]))

;; And now we repeat the operations, using the smaller functions on
;; single (sometimes also called scalar) values as parameter:

(Map better-grade students)
(Map get-book-price books)

;; Now we have learned that we can apply any function on single
;; elements to a collection of elements, such as a linked list.

;; Let us look further at lists. We might want to remove an element
;; from a list (i.e. build a new list without that element) if some
;; predicate holds. Can we generalize that, too? Of course!

(: Filter (All (A) (-> (-> A Boolean) (LinkedList A) (LinkedList A))))
(define (Filter p? as)
  (match as
    [(Nil) (Nil)]
    [(Cons a tail) (let ([t (Filter p? tail)])
                     (if (p? a)
                         t
                         (Cons a t)))]))

(Filter (lambda ([s : Student]) (< (Student-grade s) 40)) students)

;; We also might want to end up with a single value instead of a
;; list. For example, we might want to know the overall price for our
;; books. There is a function called reduce, that can help us with
;; that:

(: Reduce (All (A) (-> (-> A A A) A (LinkedList A) A)))
(define (Reduce f state as)
  (match as
    [(Nil) state]
    [(Cons a tail) (Reduce f (f state a) tail)]))
