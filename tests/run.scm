(cond-expand
  (chicken-4
   (use test posix utils))
  (chicken-5
   (import (chicken file)
           (chicken format)
           (chicken io)
           (chicken pathname)
           (chicken process))
   (import test)
   (define read-file read-list))
  (else
   (error "Unsupported CHICKEN version.")))

(test-begin "spiffy-sexpr-log")

(test-begin "spiffy-log2sexpr")
(let ((sexpr-log
       (call-with-input-pipe
        (make-pathname ".." "spiffy-log2sexpr access.log")
        read-file)))
  (test #t (equal? sexpr-log
                   '(("127.0.0.1"
                      "Thu Aug 25 19:14:15 2011"
                      GET
                      "http://localhost:8080/"
                      1.0
                      403
                      "-"
                      ("Wget/1.12 (linux-gnu)"))))))
(test-end "spiffy-log2sexpr")

(test-begin "spiffy-split-sexpr-log")
(handle-exceptions exn
  #f ;; FIXME: check exception type
  (delete-directory "split" 'recursively))
(system* (sprintf "~a split"
                  (make-pathname ".." "spiffy-split-sexpr-log sexpr.log")))
(test "split/2018/01/01.log"
      (file-exists? (make-pathname (list "split" "2018" "01") "01.log")))
(test "split/2018/02/01.log"
      (file-exists? (make-pathname (list "split" "2018" "02") "01.log")))
(test "split/2018/03/01.log"
      (file-exists? (make-pathname (list "split" "2018" "03") "01.log")))
(test "split/2018/04/01.log"
      (file-exists? (make-pathname (list "split" "2018" "04") "01.log")))
(test-end "spiffy-split-sexpr-log")

(test-end "spiffy-sexpr-log")

(test-exit)
