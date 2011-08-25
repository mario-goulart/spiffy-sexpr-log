(use test posix)

(test-begin "spiffy-log2sexpr")

(let ((sexpr-log
       (call-with-input-pipe "../spiffy-log2sexpr.scm access.log" read-file)))
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

