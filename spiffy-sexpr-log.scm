(module spiffy-sexpr-log (split-log?)

(import chicken scheme posix data-structures srfi-13 files)
(use spiffy intarweb uri-common)

(define split-log? (make-parameter #f))

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


(define (get-current-log-file)
  (let* ((now (seconds->local-time (current-seconds)))
         (year (+ 1900 (vector-ref now 5)))
         (month (+ 1 (vector-ref now 4)))
         (day (vector-ref now 3))
         (log-dir (make-pathname (list (access-log)
                                       (number->string year))
                                 (->string (pad-number month 2)))))
    (unless (directory-exists? log-dir)
      (create-directory log-dir 'with-parents))
    (make-pathname log-dir (->string (pad-number day 2)) "log")))


(handle-access-logging
 (lambda ()
   (let ((h (request-headers (current-request))))
     (log-to (if (split-log?)
                 (get-current-log-file)
                 (access-log))
             "~S"
             (list (remote-address)
                   (seconds->string (current-seconds))
                   (request-method (current-request))
                   (uri->string (request-uri (current-request)))
                   (string->number
                    (conc (request-major (current-request)) "."
                          (request-minor (current-request))))
                   (response-code (current-response))
                   (uri->string (header-value 'referer h (uri-reference "-")))
                   (let ((product (header-contents 'user-agent h)))
                     (if product
                         (product-unparser product)
                         "**Unknown product**")))))))
)
