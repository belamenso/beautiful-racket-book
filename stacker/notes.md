## Creating languages
Language in Racket can be thought of as a source-to-source
compiler (transcompiler). This means that all these languages
can use Racket libraries (you can e.g. `provide` `expt`).

Every language has to have
* *reader* - reads language, converts it to S-expressions, specifies
             expander, is specified by the #lang line
* *expander* - transforms S-expression into Racket code to be
               executed

Manually specifying the reader:
```racket
#lang reader "stacker.rkt"
```

### Reader
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
Code transformations applied at compile-time. Macro takes an
input syntax object and produces an output syntax object. All
macros operate before any run-time functions. Macro cannot
e.g. evaluate expressions in given code, because those values
are only available at run time.

In Racket community macros are commonly known as *forms* or
*syntactic forms*. Racket's macro system is one of the most
elegant and advanced out there.

## Expander
Expander is invoked by a macro called `#%module-begin`.
```racket
(module stacker-mod "stacker.rkt"
    (handle 2)
    (handle 3)
    (handle +))
```
gets turned into
```racket
(#%module-begin 
    (handle 2)
    (handle 3)
    (handle +))
```
Since all Racket languages export `#%module-begin`, we usually
handle only the things specific to our language and pass the rest
to the underlying `#%module-begin`.

To introduce bindings in our expander we can
* define macros
* define functions available at run-time
* import bindings from existing Racket modules

You have to `provide` all functions used in your language
and also all the functions that will be called after macro
expantion finished (in case of stacket - `handle`, `+`, `-`,
`#%module-begin`, `read-syntax`.

## Other
* `` `(1 2 ,@(list 3 4)) ; => '(1 2 3 4)``
* generate modules with quotes of what you want to output from the
  reader for debugging purposes
* `'#` converts to syntax object

