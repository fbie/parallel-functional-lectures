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

(define (add-one [n : Real])
  (+ n 1)) ;; No return-statement needed. The last expression is the
           ;; return value of the body.

;; And then we can just call it:

(add-one 42) ;; Evaluates to 43.
(add-one 23) ;; Evaluates to 24.

;; Q: How would you write a function times-two?

;; Assignment is done by let-bindings. A bound value is only
;; accessible in the body of the let binding. This is comparable to
;; the scope of a variable in Java, where you would say int x2 = 2 * x;:

(: double-and-add (-> Real Real Real)) ;; The type of the function can
                                       ;; be written like this, above
                                       ;; the "define" line. -> means
                                       ;; function, the last type in
                                       ;; the list is the return type,
                                       ;; the others are parameter
                                       ;; types.
(define (double-and-add x y)
  (let ([x2 (* 2 x)]  ;; Compute 2 * x and bind it to x2.
        [y2 (* 2 y)]) ;; Compute 2 * y and bind it to y2.
    (+ x2 y2)))       ;; Add the two results.

(double-and-add 42 34)

;; In functional programming languages, state is immutable. If you
;; bind a value to a name via let, you are not allowed to change it
;; again. Therefore, we cannot use for-loops with counters as you know
;; them from Java or C. Instead, we use recursion to implement
;; functions like is-even? or fib:

(: is-even? (-> Real Boolean))
(define (is-even? n)
  (if (= n 0)
      #t
      (if (< n 0)
          #f
          (is-even? (- n 2)))))

;; Q: What does this function do? How does it do it?

(even? 42)
(even? 23)

(: fib (-> Real Real))
(define (fib n)
  (if (< n 1)
      1 ;; Nothing to do, return 1.
      (+ (fib (- n 2)) (fib (- n 1))))) ;; Recurse left and right and multiply results.

(fib 1)
(fib 2)
(fib 4)
(fib 8)

;; We can also define our own data structures with the struct keyword:

(struct None ())           ;; This struct contains noting.
(struct (A) Some ([a : A]) ;; This struct contains one value of type
                           ;; A. Types must be inlined for structs.
  #:transparent)

;; (#:transparent means that we can see what's inside the instance
;; when we print it to the console.)

;; We can define a type for which None and Some are constructors:

(define-type (Maybe A) (U None (Some A)))

;; Q: What is this type good for?

;; A Java equivalent of our Maybe type:
;;
;; public class Maybe<A> {
;;   public final A a; // Can never change.
;
;;   private Maybe(A a) {
;;     this.a = a;
;;   }
;;
;;   public static Maybe None() {
;;     return new Maybe(null);
;;   }
;;
;;   public static Maybe Some(A a) {
;;     return new Maybe(a);
;;   }
;; }
;;
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
;; public class LinkedList<A> {
;;   public final A a;
;;   public final LinkedList<A> tail;
;;
;;   private LinkedList(A a, LinkedList<A> tail) {
;;     this.a = a;
;;     this.tail = tail;
;;   }
;;
;;   public static LinkedList Nil() {
;;     return new LinkedList(null, null);
;;   }
;;
;;   public static LinkedList Cons(A a, LinkedList<A> as) {
;;     return new LinkedList (a, as);
;;   }
;; }
;;
;; Now, we can put values in our new list.

(ann (Cons 3 (Nil)) (LinkedList Integer))
(ann (Cons 5 (Cons 3 (Nil))) (LinkedList Integer))
;(ann (Cons "what" (Cons 5 (Cons 3 (Nil)))) (LinkedList Integer))

;; In functional programming languages, state is immutable. Therefore,
;; we cannot use for-loops with counters as you know them from Java or
;; C. Instead, we need to use recursion to build functions that
;; operate on the recursive decomposition of a data
;; structure. Consider the function get-first. It returns Some first
;; element of the list, or None:

(require racket/match)

;; get-first is a polymorphic function. You can compare it to a
;; generic method in Java.
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

(: maybe-do (All (A B) (-> (-> A B) (Maybe A) (Maybe B))))
(define (maybe-do f m)
  (match m
    [(None) (None)]           ;; No value, nothing to do.
    [(Some a) (Some (f a))])) ;; Call f on a and wrap result in Some.

(maybe-do fun (maybe-divide 42 23))
(maybe-do fun (maybe-divide 42 0))

;; maybe-do is a higher-order function. It accepts as parameter
;; another function, which it might execute. This is a very important
;; concept in functional programming. You can change the actual
;; behavior of a function by changing the function you pass to it.

;; Using this technique, you can apply a function to all elements of a
;; list. Say you have a list of grades for students, but you graded
;; them too low. Everyone should get 10% more. So you write:

(struct Student ([name : String] [grade : Number]) #:transparent)
(define-type StudentList (LinkedList Student))

(: everyone-better-grade (-> StudentList StudentList)) ;; Remember, you cannot change the old list.
(define (everyone-better-grade ss)
  (match ss
    [(Nil) (Nil)] ;; End of list, nothing to do.
    [(Cons s tail) (Cons
                    (Student (Student-name s) (+ (Student-grade s) 10)) ;; Change the current student's grade.
                    (everyone-better-grade tail))])) ;; Continue to the next.

(: students StudentList)
(define students (Cons (Student "Li" 34)
                       (Cons (Student "Wu" 80)
                             (Cons (Student "Xiaoning" 73)
                                   (Nil)))))

;; Uh, oh. You need at least 40% in order to pass in this course...
;; Let's make a new list with the same students but better grades!
(everyone-better-grade students)

;; Okay, that was easy. But you also have a bunch of books that you
;; want to sell on the internet. But you want to lower your price by
;; 15RMB per book. Is that not a similar problem?
