#lang typed/racket

;; The general expression type. An expression is either a variable
;; name like "x", a constant like 5 or a let-binding like "(let (x 5)
;; x)".
(define-type Expr (U Var Const Let Arith))
(struct Const ([n : Number]) #:transparent)
(struct Var   ([v : String]) #:transparent)
(struct Let   ([v : Var] [e1 : Expr] [e2 : Expr]) #:transparent)

;; An arithmetic expression is the application of a mathematical
;; operator to its argument expressions.
(define-type Arith (U Plus Minus Times Div))
(struct Plus  ([e1 : Expr] [e2 : Expr]) #:transparent)
(struct Minus ([e1 : Expr] [e2 : Expr]) #:transparent)
(struct Times ([e1 : Expr] [e2 : Expr]) #:transparent)
(struct Div   ([e1 : Expr] [e2 : Expr]) #:transparent)

;; This is a simple parser that produces an expression tree from a
;; tiny math language. It is very much like Racket.
;;
;; Some valid syntax examples:
;; x
;; (+ 1 2)
;; (let (x 5) (+ x x))
;; (let (y 5) (let x y) (+ x x))
(: parse (-> Any Expr))
(define (parse expr)
  (match expr
    [(? number?)      (Const expr)]
    [(? symbol?)      (Var (symbol->string expr))]
    [`(let (,v ,e1) ,e2) (Let (Var (format "~a" v)) (parse e1) (parse e2))]
    [`(+ ,e1 ,e2)       (Plus  (parse e1) (parse e2))]
    [`(- ,e1 ,e2)       (Minus (parse e1) (parse e2))]
    [`(* ,e1 ,e2)       (Times (parse e1) (parse e2))]
    [`(/ ,e1 ,e2)       (Div   (parse e1) (parse e2))]
    [_ (error (format "Invalid syntax: \"~a\"" expr))]))

;; Now, we want to implement an interpreter for this
;; language. Interpreters do not compile the source code but execute
;; the expression tree.

;; First, we need a general environment to store values in:
(define-type (Envof A) (Listof (Pairof String A)))

;; Retrieve the value stored for the variable name.
(: env-load (All (A) (-> String (Envof A) A)))
(define (env-load s env)
    (match (assoc s env)
      [(cons _ v) v]
      [_ (error (format "Free variable: ~a" s))]))

;; Store a value under a variable name.
(: env-store (All (A) (-> String A (Envof A) (Envof A))))
(define (env-store sym val env)
  (cons (cons sym val) env))

;; This is the type of environment for number values.
(define-type ValEnv (Envof Number))

(: eval (-> Expr ValEnv Number))
(define (eval expr env)
  (match expr
    [(Const c)      c]
    [(Var v)       (env-load v env)]
    [(Let (Var v) e1 e2)
                   ;; Evaluate e1, store it under v and evaluate e2.
                   (eval e2 (env-store v (eval e1 env) env))]
    [(Plus  e1 e2) (+ (eval e1 env) (eval e2 env))]
    [(Minus e1 e2) (- (eval e1 env) (eval e2 env))]
    [_ (error "Not yet implemented!")]))

;; Project Tasks:
;;
;; 1) Implement the remaining arithmetic operators.
;;
;; 2) Add a new operator neg which takes only one argument and produces
;; the negative value of it.
;;
;; 3) Add boolean expressions, just like we have arithmetics, called
;; Bool. We need = < and > operators. Make sure to change the type of
;; Env to (U Number Boolean) to also be able to store booleans. Also,
;; you need to change the return type of eval to (U Number Boolean).
;;
;; 4) What fun are boolean expressions without if-statements?
;; Implement an if-expression called Cond, with the following syntax:
;;
;; (if b e1 e2)
;;
;; (You can parse it from `(if ,b ,e1 ,e2)).
;;
;; If b evaluates to true, execute e1, otherwise execute e2.
;;
;; 5) What would it take to add lambda expressions and application to
;; the language? Can you implement it? Give it a try! All lambdas
;; should only be of type (-> Number Number).
;;
;; Some test expressions:

;; 1)
;(eval (parse '(* 2 5)) '())
;(eval (parse '(let (x (* 2 5) (/ x x)))) '())

;; 2)
;(eval (parse '(neg 3)) '())
;(eval (parse '(let (x 4) (neg x))) '())

;; 3
;(eval (parse '(< 3 4)) '())
;(eval (parse '(let (x 123) (= x 123))) '())

;; 4
;(eval (parse '(if (< 1 2) 1 2)) '())
;(eval (parse '(let (x 3) (let (y 2) (if (= x 0) (y) (/ y x))))) '())

;; 6) This is the definition of a very simple and tiny type inference
;; algorithm. Because our language is not polymorphic, it only
;; contains types for numbers and booleans. Extend it such that all
;; the new functions you have added can be type checked.
;;
;; For extra points, you can also implement polymorphic functions and
;; then implement Hindley-Milner type inference for them.

;; The type that describes types in our language.
(define-type MathType (U 'Number 'Bool))

;; An environment that stores types for variable names.
(define-type TypeEnv (Envof MathType))

;; Infer the type of an expression, using the type environment tenv.
(: type (-> Expr TypeEnv MathType))
(define (type expr tenv)
  (match expr
    [(Const c) 'Number] ;; Always the number type!
    [(Var v)   (env-load v tenv)] ;; Look-up type for variable name.
    [(Let (Var v) e1 e2)
               ;; Infer the type of e1, store under v and infer type of e2.
               (type e2 (env-store v (type e1 tenv) tenv))]
    [(Plus e1 e2) (if (and (eq? 'Number (type e1 tenv))  ;; Check whether e1 has the right type.
                           (eq? 'Number (type e2 tenv))) ;; Check whether e2 has the right type.
                      'Number ;; If both have the right type, the result type is 'Number.
                      (error "Wrong type arguments for +-operator!"))] ;; Error otherwise.
    [_ (error "Not implemented yet!")]))
