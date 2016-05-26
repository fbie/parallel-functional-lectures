#lang typed/racket

(define (add-one [n : Integer])
  (+ n 1))

(: double-and-add (-> Integer Integer Integer))
(define (double-and-add x y)
  (let ([x2 (* 2 x)]
        [y2 (* 2 y)])
    (+ x2 y2)))

(: is-even? (-> Integer Boolean))
(define (is-even? n)
  (if (< 1 n)
      (is-even? (- n 2))
      (= n 0)))

(: fib (-> Integer Integer))
(define (fib n)
  (if (< n 1)
      1
      (+ (fib (- n 2)) (fib (- n 1)))))

;; The Maybe type models whether a function succeeded or not. There
;; are no null-pointers, like in Java.
(struct None ())
(struct (A) Some ([value : A]) #:transparent)
(define-type (Maybe A) (U None (Some A)))

(: maybe-divide (-> Real Real (Maybe Real)))
(define (maybe-divide n d)
  (if (= d 0)
      (None)
      (Some (/ n d))))

(: has-value? (-> (Maybe Any) Boolean))
(define (has-value? m)
  (match m
    [(None) #f]
    [(Some _) #t]))

(: maybe-print (-> (Maybe Any) Void))
(define (maybe-print m)
  (match m
    [(None) (void)]
    [(Some v) (print v)]))

;; A linked list always contains another linked list.
(struct Nil ())
(struct (A) Cons ([head : A] [tail : (LinkedList A)]) #:transparent)
(define-type (LinkedList A) (U Nil (Cons A)))

(: push (All (A) (-> A (LinkedList A) (LinkedList A))))
(define (push a as)
  (Cons a as))

(: Concat (All (A) (-> (LinkedList A) (LinkedList A) (LinkedList A))))
(define (Concat lhs rhs)
  (match lhs
    [(Nil) rhs]
    [(Cons head tail) (Cons head (Concat tail rhs))]))

(: Remove (All (A) (-> A (LinkedList A) (LinkedList A))))
(define (Remove a as)
  (match as
    [(Nil) (Nil)]
    [(Cons head tail) (if (eq? head a)
                          tail
                          (Cons head (Remove a tail)))]))


(: get-head (All (A) (-> (LinkedList A) (Maybe A))))
(define (get-head as)
  (match as
    [(Nil) (None)]
    [(Cons head _) (Some head)]))

(: fun (-> Real Real))
(define fun (lambda (x) (* 2 x)))

(: maybe-map (All (A B) (-> (-> A B) (Maybe A) (Maybe B))))
(define (maybe-map f m)
  (match m
    [(None) (None)]
    [(Some a) (Some (f a))]))

(struct Student ([name : String] [grade : Integer]) #:transparent)

(define students (Cons (Student "A" 89) (Cons (Student "B" 44) (Cons (Student "C" 62) (Nil)))))

(: better-grade (-> Student Student))
(define (better-grade student)
  (Student (Student-name student) (+ 10 (Student-grade student))))

(: everyone-better-grade (-> (LinkedList Student) (LinkedList Student)))
(define (everyone-better-grade students)
  (match students
    [(Nil) (Nil)]
    [(Cons student tail) (Cons (better-grade student)
                               (everyone-better-grade tail))]))

(: Map (All (A B) (-> (-> A B) (LinkedList A) (LinkedList B))))
(define (Map f as)
  (match as
    [(Nil) (Nil)]
    [(Cons head tail) (Cons (f head) (Map f tail))]))

(: Filter (All (A) (-> (-> A Boolean) (LinkedList A) (LinkedList A))))
(define (Filter p as)
  (match as
    [(Nil) (Nil)]
    [(Cons head tail) (if (p head)
                          (Filter p tail)
                          (Cons head (Filter p tail)))]))

(: Length (-> (LinkedList Any) Integer))
(define (Length as)
  (match as
    [(Nil) 0]
    [(Cons _ tail) (+ 1 (Length tail))]))

(: Fold (All (A B) (-> (-> B A B) B (LinkedList A) B)))
(define (Fold f state as)
  (match as
    [(Nil) state]
    [(Cons head tail) (Fold f (f state head) tail)]))

(: Sum (-> Integer (LinkedList Integer) Integer))
(define (Sum sum as)
  (match as
    [(Nil) sum]
    [(Cons head tail) (Sum (+ sum head) tail)]))
