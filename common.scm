(cond-expand
  (chicken-4
   (use srfi-13))
  (chicken-5
   (import srfi-13))
  (else
   (error "Unsupported CHICKEN version.")))

(define (pad-number n zeroes)
  (define (pad num len)
    (let ((str (if (string? num) num (number->string num))))
      (if (equal? str "")
          ""
          (if (>= (string-length str) len)
              str
              (string-pad str len #\0)))))

  (let ((len (string-length (->string n))))
    (if (= len zeroes)
        n
        (pad n zeroes))))
