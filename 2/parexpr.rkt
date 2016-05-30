#lang typed/racket

;; Sequential map function on cons-list.
(: seq-map (All (A B) (-> (-> A B) (Listof A) (Listof B))))
(define (seq-map f xs)
  (match xs
    ['() '()]
    [(cons x xs) (cons (f x) (seq-map f xs))]))

;; Concatenation list: a binary tree with values only at its leaves.
(define-type (CatListof A) (U (leaf A) (cat A)))
(struct (A) leaf ([a : A]) #:transparent)
(struct (A) cat ([l : (CatListof A)] [r : (CatListof A)]) #:transparent)

;; Pseudo-parallel map function.
(: par-map (All (A B) (-> (-> A B) (CatListof A) (CatListof B))))
(define (par-map f xs)
  (match xs
    [(leaf x) (leaf (f x))]
    [(cat l r) (cat (par-map f l) (par-map f r))]))

;; A higher-order function that executes two argument functions in
;; parallel.
(: in-parallel (All (A B C) (-> (-> A B) (-> A C) A (Pairof B C))))
(define (in-parallel f g x)
  (let ([fx (future (lambda () (f x)))] ;; Not blocking.
        [gx (g x)]) ;; Computes in parallel on main thread.
    (cons (touch fx) gx))) ;; Join threads.

;; A truly parallel map implementation.
(: par-map2 (All (A B) (-> (-> A B) (CatListof A) (CatListof B))))
(define (par-map2 f xs)
  (match xs
    [(leaf x) (leaf (f x))]
    [(cat l r) (let ([l0 (future (lambda () (par-map f l)))]
                     [r0 (future (lambda () (par-map f r)))])
                   (cat (touch l0) (touch r0)))]))

;; Compose two functions f and g such that we first apply f and then g
;; to the argument.
(: compose (All (A B C) (-> (-> A B) (-> B C) (-> A C))))
(define (compose f g)
  (lambda (a) (g (f a))))
