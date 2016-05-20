#lang typed/racket

(: seq-map (All (A B) (-> (-> A B) (Listof A) (Listof B))))
(define (seq-map f xs)
  (match xs
    ['() '()]
    [(cons x xs) (cons (f x) (seq-map f xs))]))

(define-type (CatListof A) (U (leaf A) (cat A)))
(struct (A) leaf ([a : A]) #:transparent)
(struct (A) cat ([l : (CatListof A)] [r : (CatListof A)]) #:transparent)

(: par-map (All (A B) (-> (-> A B) (CatListof A) (CatListof B))))
(define (par-map f xs)
  (match xs
    [(leaf x) (leaf (f x))]
    [(cat l r) (cat (par-map f l) (par-map f r))]))

(: in-parallel (All (A B C) (-> (-> A B) (-> A C) A (Pairof B C))))
(define (in-parallel f g x)
  (let ([fx (future (lambda () (f x)))] ;; Not blocking.
        [gx (g x)]) ;; Computes in parallel on main thread.
    (cons (touch fx) gx))) ;; Join threads.

(: par-map2 (All (A B) (-> (-> A B) (CatListof A) (CatListof B))))
(define (par-map2 f xs)
  (match xs
    [(leaf x) (leaf (f x))]
    [(cat l r) (let ([l0 (future (lambda () (par-map f l)))]
                     [r0 (future (lambda () (par-map f r)))])
                   (cat (touch l0) (touch r0)))]))
