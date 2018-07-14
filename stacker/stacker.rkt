#lang br/quicklang

(provide read-syntax
         (rename-out [stacker-module-begin #%module-begin])
         handle
         + expt
         *)

(define (read-syntax path port)
  (let* ([lines (port->lines port)]
         [datums (format-datums '(handle ~a) lines)]
         [module `(module stacker-mod "stacker.rkt"
                    ,@datums)])
    (datum->syntax #f module)))

(define-macro (stacker-module-begin HANDLE-EXPR ...)
  #'(#%module-begin
     'HANDLE-EXPR ...
     (displayln (car stack))))

(define stack '())

(define (pop!)
  (let ([x (car stack)])
    (set! stack (cdr stack))
    x))

(define (push! x)
  (set! stack (cons x stack)))

(define (handle [arg #f])
  (cond [(number? arg) (push! arg)]
        [(or (equal? + arg) (equal? * arg))
         (let ([a (pop!)] [b (pop!)])
           (push! (arg a b)))]
        [arg (printf "Cannot parse ~a\n" arg)]))
