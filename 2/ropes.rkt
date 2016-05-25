#lang typed/racket

;; Apparently, typed/racket does not provide a persistent list-set as
;; a library function.
(: list-set (All (A) (-> (Listof A) Integer A (Listof A))))
(define (list-set as i b)
  (match as
    ['() as]
    [(cons a as) (if (= i 0)
                     (cons b as)
                     (cons a (list-set as (- i 1) b)))]))

;; Also, there is not default reduce function on lists. This is a
;; simple implementation of reduce on lists.
(: reduce (All (A) (-> (-> A A A) (Listof A) A)))
(define (reduce f as)
  (: reduce-internal (All (A) (-> (-> A A A) A (Listof A) A)))
  (define (reduce-internal f state as)
    (match as
      ['() state]
      [(cons a0 as) (reduce-internal f (f state a0) as)]))
  (assert (not (null? as)))
  (reduce-internal f (car as) (cdr as)))

;; This is our rope type.
(define-type (Ropeof A) (U (Leaf A) (Cat A)))

(struct (A) Leaf ([as : (Listof A)]) #:transparent)
(struct (A) Cat ([l : (Ropeof A)] [r : (Ropeof A)]) #:transparent)

;; The maximum length of a leaf list.
(define max-leaf-length 5)

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
    (if (<= n max-leaf-length)
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

;; Reverse the order of elements in the rope.
(: rope-reverse (All (A) (-> (Ropeof A) (Ropeof A))))
(define (rope-reverse rope)
  (match rope
    [(Leaf as) (Leaf (reverse as))]
    [(Cat l r) (Cat (rope-reverse r) (rope-reverse l))]))

;; Apply a function to each element of a rope and return a rope with
;; the resulting values at the corresponding positions.
(: rope-map (All (A B) (-> (-> A B) (Ropeof A) (Ropeof B))))
(define (rope-map f rope)
  (match rope
    [(Leaf as) (Leaf (map f as))]
    [(Cat l r) (Cat (rope-map f l) (rope-map f r))]))

;; Fold the rope using the function f.
(: rope-fold (All (A B) (-> (-> A B B) B (Ropeof A) B)))
(define (rope-fold f state rope)
  (match rope
    [(Leaf as) (foldl f state as)]
    [(Cat l r) (let* ([state1 (rope-fold f state  l)]  ;; First fold left part.
                      [state2 (rope-fold f state1 r)]) ;; Right part depends on the left part.
                 state2)])) ;; Right part is the result, we move from left to right.

;; Reduce the rope using function f.
(: rope-reduce (All (A) (-> (-> A A A) (Ropeof A) A)))
(define (rope-reduce f rope)
  (match rope
    [(Leaf as) (reduce f as)] ;; Base case, reduce the leaf list to a single value.
    [(Cat l r) (f (rope-reduce f l) (rope-reduce f r))])) ;; Reduce left and right part and merge results.

;; The same as rope-map but runs in parallel!
(: rope-pmap (All (A B) (-> (-> A B) (Ropeof A) (Ropeof B))))
(define (rope-pmap f rope)
  (match rope
    [(Leaf as) (Leaf (map f as))] ;; Base case, map over the leaf list.
    [(Cat l r) (let [(l0 (future (lambda () (rope-pmap f l))))  ;; Start a future for the left part.
                     (r0 (future (lambda () (rope-pmap f r))))] ;; Start a future for the right part.
                 (Cat (touch l0) (touch r0)))])) ;; Touch waits for the futures and returns their results.

;; The same as rope-reduce but runs in parallel!
(: rope-preduce (All (A) (-> (-> A A A) (Ropeof A) A)))
(define (rope-preduce f rope)
  (match rope
    [(Leaf as) (reduce f as)] ;; Base case, reduce the leaf list.
    [(Cat l r) (let [(l0 (future (lambda () (rope-preduce f l))))  ;; Start a future for the left part.
                     (r0 (future (lambda () (rope-preduce f r))))] ;; Start a future for the right part.
                 (f (touch l0) (touch r0)))])) ;; Await futures and merge the results using f.
