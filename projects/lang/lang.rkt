#lang racket

(define (eval term env)
  (match term ;; Case decomposition on the term structure:
    [(? symbol?) (cadr (assq term env))] ;; Look-up symbol in the environment.
    [`(λ ,x . ,f) `(closure ,term ,env)] ;; Produce a new closure that encloses an environment.
    [`(,f ,x) (apply (eval f env) (eval x env))])) ;; Evaluate f and apply its result to the result of x.

(define (apply f x)
  (match f ;; Case decomposition on the function structure.
    [`(closure (λ ,v . ,body) ,env) ;; We only accept closures here!
         (eval body (cons `(,v ,x) env))])) ;; Evaluate the body with an environment where v is bound to x.

(display (eval (read) '())) ;; Print the result of evaluating a parsed expression.
