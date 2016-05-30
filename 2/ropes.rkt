#lang typed/racket

(require/typed future-visualizer
  [visualize-futures-thunk (All (A) ((-> A) -> A))])

;; Apparently, typed/racket does not provide a persistent list-set as
;; a library function.
(: list-set (All (A) (-> (Listof A) Integer A (Listof A))))
(define (list-set as i b)
  (match as
    ['() as]
    [(cons a as) (if (= i 0)
                     (cons b as)
                     (cons a (list-set as (- i 1) b)))]))

(: list-fold (All (A B) (-> (-> B A B) B (Listof A) B)))
(define (list-fold f state as)
  (foldl (lambda ([a : A] [b : B]) (f b a)) state as))

;; Also, there is not default reduce function on lists. This is a
;; simple implementation of reduce on lists.
(: list-reduce (All (A) (-> (-> A A A) (Listof A) A)))
(define (list-reduce f as)
  (assert (not (null? as)))
  (foldl f (car as) (cdr as)))

;; To keep the syntax consistent.
(define list-filter filter)

;; This is our rope type.
(define-type (Ropeof A) (U (leaf A) (cat A)))

(struct (A) leaf ([as : (Listof A)]) #:transparent)
(struct (A) cat ([l : (Ropeof A)] [r : (Ropeof A)]) #:transparent)

;; The maximum length of a leaf list.
(define max-leaf-length 5)

;; Return the number of elements in the rope.
(: rope-length (All (A) (-> (Ropeof A) Integer)))
(define (rope-length rope)
  (match rope
    [(leaf as) (length as)]
    [(cat l r) (+ (rope-length l) (rope-length r))]))

;; Initialize a rope for a given function.
(: rope-init (All (A) (-> Integer (-> Integer A) (Ropeof A))))
(define (rope-init n f)
  (: rope-init-internal (All (A) (-> Integer Integer (-> Integer A) (Ropeof A))))
  (define (rope-init-internal offset n f)
    (if (<= n max-leaf-length)
        (leaf (build-list n (lambda ([n : Integer]) (f (+ n offset)))))
        (letrec ([n0 (quotient n 2)]
                 [l (rope-init-internal offset n0 f)]
                 [r (rope-init-internal (+ offset (rope-length l)) (- n (rope-length l)) f)])
          (cat l r))))
  (rope-init-internal 0 n f))

;; Convenience function to initialize ropes.
(: rope-init-interval (-> Integer Integer (Ropeof Integer)))
(define (rope-init-interval n m)
  (assert (< n m))
  (rope-init (- m n) (lambda ([x : Integer]) (+ x n))))

;; Return the value associated with some index i.
(: rope-ref (All (A) (-> (Ropeof A) Integer A)))
(define (rope-ref rope i)
  (match rope
    [(leaf as) (list-ref as i)]
    [(cat l r) (if (< i (rope-length l))
                    (rope-ref l i)
                    (rope-ref r (- i (rope-length l))))]))

;; Return a new rope where the value at index i has been replaced by
;; some new value a.
(: rope-set (All (A) (-> (Ropeof A) Integer A (Ropeof A))))
(define (rope-set rope i a)
  (match rope
    [(leaf as) (leaf (list-set as i a))]
    [(cat l r) (if (< i (rope-length l)) ;; If the index is inside the left rope,
                   (cat (rope-set l i a) r) ;; then set in left sub-rope.
                   (cat l (rope-set r (- i (rope-length l)) a)))])) ;; Otherwise, set in right sub-rope.

;; Concatenate two ropes.
(: rope-cat (All (A) (-> (Ropeof A) (Ropeof A) (Ropeof A))))
(define (rope-cat l r)
  (match (cons l r)
    [(cons (leaf ls) (leaf rs)) (if (< (+ (length ls) (length rs)) max-leaf-length)
                                    (leaf (append ls rs))
                                    (cat l r))]
    [(cons (leaf ls) (cat (leaf lrs) rs)) (if (< (+ (length ls) (length lrs)) max-leaf-length)
                                              (cat (leaf (append ls lrs)) rs)
                                              (cat l r))]
    [(cons (cat ls (leaf rls)) (leaf rs)) (if (< (+ (length rls) (length rs)) max-leaf-length)
                                              (cat ls (leaf (append rls rs)))
                                              (cat l r))]
    [_ (cat l r)]))

;; Balance a possibly unbalanced rope.
(: rope-balance (All (A) (-> (Ropeof A) (Ropeof A))))
(define (rope-balance rope)
  ;; TODO: Implement!
  rope)

;; Reverse the order of elements in the rope.
(: rope-reverse (All (A) (-> (Ropeof A) (Ropeof A))))
(define (rope-reverse rope)
  (match rope
    [(leaf as) (leaf (reverse as))]
    [(cat l r) (cat (rope-reverse r) (rope-reverse l))]))

;; Apply a function to each element of a rope and return a rope with
;; the resulting values at the corresponding positions.
(: rope-map (All (A B) (-> (-> A B) (Ropeof A) (Ropeof B))))
(define (rope-map f rope)
  (match rope
    [(leaf as) (leaf (map f as))]
    [(cat l r) (cat (rope-map f l)
                    (rope-map f r))]))

;; Fold the rope using the function f.
(: rope-fold (All (A B) (-> (-> B A B) B (Ropeof A) B)))
(define (rope-fold f state rope)
  (match rope
    [(leaf as) (list-fold f state as)]
    [(cat l r) (letrec ([state1 (rope-fold f state  l)]  ;; First fold left part.
                        [state2 (rope-fold f state1 r)]) ;; Right part depends on the left part.
                 state2)])) ;; Right part is the result, we move from left to right.

;; Reduce the rope using function f.
(: rope-reduce (All (A) (-> (-> A A A) (Ropeof A) A)))
(define (rope-reduce f rope)
  (match rope
    [(leaf as) (list-reduce f as)] ;; Base case, reduce the leaf list to a single value.
    [(cat l r) (f (rope-reduce f l)
                  (rope-reduce f r))])) ;; Reduce left and right part and merge results.

;; Filter the rope using predicate p.
(: rope-filter (All (A) (-> (-> A Boolean) (Ropeof A) (Ropeof A))))
(define (rope-filter p rope)
  (match rope
    [(leaf as) (leaf (list-filter p as))]
    [(cat l r) (cat (rope-filter p l)
                    (rope-filter p r))]))

;; The same as rope-map but runs in parallel!
(: rope-pmap (All (A B) (-> (-> A B) (Ropeof A) (Ropeof B))))
(define (rope-pmap f rope)
  (match rope
    [(leaf as) (leaf (map f as))] ;; Base case, map over the leaf list.
    [(cat l r) (let [(l0 (future (lambda () (rope-pmap f l))))  ;; Start a future for the left part.
                     (r0 (future (lambda () (rope-pmap f r))))] ;; Start a future for the right part.
                 (cat (touch l0) (touch r0)))])) ;; Touch waits for the futures and returns their results.

;; The same as rope-reduce but runs in parallel!
(: rope-preduce (All (A) (-> (-> A A A) (Ropeof A) A)))
(define (rope-preduce f rope)
  (match rope
    [(leaf as) (list-reduce f as)] ;; Base case, reduce the leaf list.
    [(cat l r) (let [(l0 (future (lambda () (rope-preduce f l))))  ;; Start a future for the left part.
                     (r0 (future (lambda () (rope-preduce f r))))] ;; Start a future for the right part.
                 (f (touch l0) (touch r0)))])) ;; Await futures and merge the results using f.
