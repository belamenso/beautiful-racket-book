## Creating languages
Every language has to have
* *reader* - reads language, converts it to S-expressions, specifies
             expander, is specified by the #lang line
* *expander* - transforms S-expression into Racket code to be
               executed

Manually specifying the reader:
```racket
#lang reader "stacker.rkt"
```

### Writing a reader
Every reader must export function `read-syntax` accepting two
arguments: a path to the source file and a port for reading data from
the file. This funtion needs to return a module, packaged as
a *syntax object*. Racket will replace the source code with this
module, which will be further evaluated with the expander.

```racket
(define (read-syntax path port)
  (define src-lines (port->lines port))
    (datum->syntax #f '(module mod-name racket/base ; could be path to a reader
                           42
                           #| lines of genrated code |#)))

```

We create *datum* by quoting and turn it into a syntax object. The
first argument of `datum->syntax` is a context we want to associate
with the code.

You can always replace
```racket
#lang racket

(define a 100)
(displayln a)
```
with
```racket
(module hello racket
    (define a 100)
    (displayln a))
```

Example reader generating text source of a file:
```racket
#lang racket

(provide read-syntax)

(define (read-syntax path port)
    (let* ([lines (port->lines port)]
           [module `(module hello racket
                     ,(apply string-append lines))])
       (datum->syntax #f module)))
```

## Macros
Code transformations applied at compile-time.

## Other
* `` `(1 2 ,@(list 3 4)) ; => '(1 2 3 4)``
* generate modules with quotes of what you want to output from the
  reader for debugging purposes

