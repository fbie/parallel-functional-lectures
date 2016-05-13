#lang typed/racket

(require racket/list)

(define-type (Ropeof A) (U (Leaf A) (Cat A)))

(struct (A) Leaf ([as : (Listof A)]) #:transparent)
(struct (A) Cat ([l : (Ropeof A)] [r : (Ropeof A)]) #:transparent)

;; Return the number of elements in the rope.
(: rope-length (All (A) (-> (Ropeof A) Integer)))
(define (rope-length rope)
  (match rope
    [(Leaf as) (length as)]
    [(Cat l r) (+ (rope-length l) (rope-length r))]))

;; Return the value associated with some index i.
(: rope-ref (All (A) (-> (Ropeof A) Integer A)))
(define (rope-ref rope i)
  (match rope
    [(Leaf as) (list-ref as i)]
    [(Cat l r) (if (< i (rope-length l))
                    (rope-ref l i)
                    (rope-ref r i))]))

;; Return a new rope where the value at index i has been replaced by
;; some new value a.
(: rope-set (All (A) (-> (Ropeof A) Integer A (Ropeof A))))
(define (rope-set rope i a)
  (match rope
    [(Leaf as) (Leaf (list-set as i a))]
    [(Cat l r) (if (< i (rope-length l)) ;; If the index is inside the left rope,
                   (Cat (rope-set l i a) r) ;; then set in left sub-rope.
                   (Cat l (rope-set l (i - (rope-length l) a))))])) ;; Otherwise, set in right sub-rope.

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
