#lang typed/racket

;; This is our Term type, which models the abstract syntax tree.
(define-type Term (U Var Abs App Closure))
(struct Var ([s : String]) #:transparent) ;; A variable name.
(struct Abs ([v : Var] [body : Term]) #:transparent) ;; A function. Functions are abstractions.
(struct App ([f : Term] [e : Term]) #:transparent) ;; Function application, f(x) in Java or (f x) in Racket.

;; Parse an expression in lambda calculus into an Term.
(: parse (-> Any Term))
;; You do not have to understand how this works exactly. It is enough
;; if you see that we have some syntax on the left which we convert
;; into Term types on the right. If the syntax is not correct, we
;; throw an exception.
(define (parse expr)
  (match expr
    [(? symbol?)     (Var (format "~a" expr))]
    [`(λ ,v . ,body) (Abs (Var (format "~a" v)) (parse body))]
    [`(,f ,e)        (App (parse f) (parse e))]
    [_               (error (string-append (format "Illegal expression: \"~a\"" expr)))]))

;; The environment is a list of pairs of symbols to Term.
(define-type Env (Listof (Pairof Var Term)))

;; Retrieve the value stored for the variable name.
(: env-lookup (-> Var Env Term))
(define (env-lookup s env)
  (let ([v (assq s env)])
    (if (not (eq? v #f))
        (cdr v)
        (error (format "Variable not bound to a value: ~a" s)))))

;; Store a value under a variable name.
(: env-push (-> Var Term Env Env))
(define (env-push sym term env)
  (cons (cons sym term) env))

;; A closure is an anonymous function that encloses an environment.
(struct Closure ([v : Var] [body : Term] [env : Env]) #:transparent)

;; Evaluation interprets a Term without compilation.
(: eval (-> Term Env Term))
(define (eval term env)
  (match term
    [(Var s)      (env-lookup term env)] ;; Look up the value of the symbol in the environment.
    [(Abs v body) (Closure v body env)]  ;; Produce a closure: a function that encloses an environment.
    [(App f e)    (closure-apply (eval f env) e)])) ;; Call the closure on the parameter expression e.

;; Apply a closure to a term.
(: closure-apply (-> Term Term Term))
(define (closure-apply closure e)
  (match closure
    ;; We evaluate a closure with the enclosed environment in which
    ;; the variable name v has been bound to the value of e, which is
    ;; an already evaluated term:
    [(Closure v body env) (eval body (env-push v e env))]
    [_                    (error "Can only apply closures.")]))

;; Parse a lambda calculus term from command line.
(: parse-from-cmd (-> Term))
(define (parse-from-cmd)
  (parse (read)))
