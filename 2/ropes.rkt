#lang typed/racket

(require racket/list)

;; Apparently, typed/racket does not provide a persistent list-set as
;; a library function.
(: list-set (All (A) (-> (Listof A) Integer A (Listof A))))
(define (list-set as i a)
  (match as
    ['() as]
    [(cons a' as) (if (= i 0)
                      (cons a as)
                      (cons a' (list-set as (- i 1) a)))]))

;; This is our rope type.
(define-type (Ropeof A) (U (Leaf A) (Cat A)))

(struct (A) Leaf ([as : (Listof A)]) #:transparent)
(struct (A) Cat ([l : (Ropeof A)] [r : (Ropeof A)]) #:transparent)

;; The maximum length of a leaf list.
(define N 5)

;; Return the number of elements in the rope.
(: rope-length (All (A) (-> (Ropeof A) Integer)))
(define (rope-length rope)
  (match rope
    [(Leaf as) (length as)]
    [(Cat l r) (+ (rope-length l) (rope-length r))]))

;; Initialize a rope for a given function.
(: rope-init (All (A) (-> Integer (-> Integer A) (Ropeof A))))
(define (rope-init n f)
  (: rope-init-internal (All (A) (-> Integer Integer (-> Integer A) (Ropeof A))))
  (define (rope-init-internal offset n f)
    (if (<= n N)
        (Leaf (build-list n (lambda ([n : Integer]) (f (+ n offset)))))
        (let* ([n0 (quotient n 2)]
               [l (rope-init-internal offset n0 f)]
               [r (rope-init-internal (+ offset (rope-length l)) (- n (rope-length l)) f)])
          (Cat l r))))
  (rope-init-internal 0 n f))

;; Return the value associated with some index i.
(: rope-ref (All (A) (-> (Ropeof A) Integer A)))
(define (rope-ref rope i)
  (match rope
    [(Leaf as) (list-ref as i)]
    [(Cat l r) (if (< i (rope-length l))
                    (rope-ref l i)
                    (rope-ref r (- i (rope-length l))))]))

;; Return a new rope where the value at index i has been replaced by
;; some new value a.
(: rope-set (All (A) (-> (Ropeof A) Integer A (Ropeof A))))
(define (rope-set rope i a)
  (match rope
    [(Leaf as) (Leaf (list-set as i a))]
    [(Cat l r) (if (< i (rope-length l)) ;; If the index is inside the left rope,
                   (Cat (rope-set l i a) r) ;; then set in left sub-rope.
                   (Cat l (rope-set r (- i (rope-length l)) a)))])) ;; Otherwise, set in right sub-rope.

;; Concatenate two ropes.
(: rope-cat (All (A) (-> (Ropeof A) (Ropeof A) (Ropeof A))))
(define (rope-cat l r)
  ;; TODO: Improve concatenation of short ropes.
  (Cat l r))

;; Balance a possibly unbalanced rope.
(: rope-balance (All (A) (-> (Ropeof A) (Ropeof A))))
(define (rope-balance rope)
  ;; TODO: Implement!
  rope)

;; Apply a function to each element of a rope and return a rope with
;; the resulting values at the corresponding positions.
(: rope-map (All (A B) (-> (-> A B) (Ropeof A) (Ropeof B))))
(define (rope-map f rope)
  (match rope
    [(Leaf as) (Leaf (map f as))]
    [(Cat l r) (Cat (rope-map f l) (rope-map f r))]))
