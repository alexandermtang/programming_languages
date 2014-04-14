; *********************************************
; *  314 Principles of Programming Languages  *
; *  Spring 2014                              *
; *  Author: Liu Liu                          *
; *          Ulrich Kremer                    *
; *  April 5, 2014                            *
; *********************************************
;; -----------------------------------------------------
;; ENVIRONMENT
;; contains "ctv", "vtc",and "reduce" definitions
(load "include.ss")

;; contains a test document consisting of three paragraphs. 
(load "document.ss")

;; contains a test-dictionary, which has a much smaller dictionary for testing
;; the dictionary is needed for spell checking
(load "test-dictionary.ss")

;; (load "dictionary.ss") ;; the real thing with 45,000 words


;; -----------------------------------------------------
;; HELPER FUNCTIONS

;;INPUT: a paragraph "p" and a "encoder"
;;OUTPUT: an encoded paragraph using a provided encoder
(define encode-p;;this encoder is supposed to be the output of "encode-n"
  (lambda (p encoder)
    (map (lambda (w) (encoder w)) p)
  ))

;;INPUT: an initial value "a" and a final value "b"
;;OUTPUT: a list from a, a+1, ..., b inclusive
(define range
  (lambda (a b)
    (if (> a b)
      '()
      (cons a (range (+ 1 a) b))
    )))

;;INPUT: a paragraph "p"
;;OUTPUT: number of correctly spelled words in p
(define count-words-in-p
  (lambda (p)
    (reduce (lambda (b id) (if (eq? b #t) (+ 1 id) (+ 0 id)))
            (map (lambda (w) (spell-checker w)) p)
            0
    )))

;; -----------------------------------------------------
;; SPELL CHECKER FUNCTION

;;check a word's spell correctness
;;INPUT:a word(a global variable "dictionary" is included in the file "test-dictionary.ss", and can be used directly here)
;;OUTPUT:true(#t) or false(#f)
(define spell-checker
  (lambda (w)
    (letrec ((wordeq? (lambda (w1 w2)
                        (cond
                          ((and (null? w1) (not (null? w2))) #f)
                          ((and (null? w2) (not (null? w1))) #f)
                          ((and (null? w1) (null? w2)) #t)
                          ((not (eq? (car w1) (car w2))) #f)
                          ((eq? (car w1) (car w2)) (wordeq? (cdr w1) (cdr w2)))
                        )))
             (helper (lambda (w dict)
                       (cond
                         ((null? dict) #f)
                         ((wordeq? w (car dict)) #t)
                         (else (helper w (cdr dict)))
                       ))))
      (helper w dictionary)
    )))

;following implementation is SLOW
;(define spell-checker
  ;(lambda (w)
    ;(letrec ((or (lambda (x y) (or x y)))
             ;(and (lambda (x y) (and x y)))
             ;(wordeq? (lambda (w1 w2)
                        ;(reduce and (map (lambda (x y) (eq? x y)) w1 w2) #t))))
      ;(reduce or (map (lambda (dictw) (wordeq? dictw w)) dictionary) #f)
    ;)))

;; -----------------------------------------------------
;; ENCODING FUNCTIONS

;;generate an Caesar Cipher single word encoders
;;INPUT:a number "n"
;;OUTPUT:a function, whose input=a word, output=encoded word
(define encode-n
  (lambda (n);;"n" is the distance, eg. n=3: a->d,b->e,...z->c
    (lambda (w);;"w" is the word to be encoded
      (map
        (lambda (c) (vtc (modulo (+ (ctv c) n) 26))) w)
    )))

;;encode a document
;;INPUT: a document "d" and a "encoder"
;;OUTPUT: an encoded document using a provided encoder
(define encode-d;;this encoder is supposed to be the output of "encode-n"
  (lambda (d encoder)
    (map (lambda (p) (encode-p p encoder)) d)
  ))

;; -----------------------------------------------------
;; DECODE FUNCTION GENERATORS
;; 2 generators should be implemented, and each of them returns a decoder

;;generate a decoder using brute-force-version spell-checker
;;INPUT:an encoded paragraph "p"
;;OUTPUT:a decoder, whose input=a word, output=decoded word
(define Gen-Decoder-A
  (lambda (p)
    (letrec ((encoders (map (lambda (n) (encode-n n)) (range 0 25)))
             (add-encoded-p (lambda (encoder) (list (encode-p p encoder) encoder)))
             (add-count-words-in-p (lambda (p-encoder)
                                     (list (count-words-in-p (car p-encoder))
                                           (cadr p-encoder))))
            )
      (cadr ((lambda (struct)
        (reduce
          (lambda (x y) (if (> (car x) (car y)) x y))
          (cdr struct)
          (car struct)
         )) (map add-count-words-in-p (map add-encoded-p encoders))))
    )))

(define add1 (encode-n 1))
(define plaintext document)
(define ciphertext (encode-d plaintext add1))
(define decoder (Gen-Decoder-A (car ciphertext)))

;;generate a decoder using frequency analysis
;;INPUT:same as above
;;OUTPUT:same as above
(define Gen-Decoder-B
  (lambda (p)
    'SOME_CODE_GOES_HERE ;; *** FUNCTION BODY IS MISSING ***
    ))

;; -----------------------------------------------------
;; CODE-BREAKER FUNCTION

;;a codebreaker
;;INPUT: an encoded document(of course by a Caesar's Cipher), a decoder(generated by functions above)
;;OUTPUT: a decoded document
(define Code-Breaker
  (lambda (d decoder)
    (encode-d d decoder)
  ))

;; -----------------------------------------------------
;; EXAMPLE APPLICATIONS OF FUNCTIONS
;;(spell-checker '(h e l l o))
;;(define add5 (encode-n 5))
;;(encode-d document add5)
;;(define decoderSP1 (Gen-Decoder-A paragraph))
;;(define decoderFA1 (Gen-Decoder-B paragraph))
;;(Code-Breaker document decoderSP1)
