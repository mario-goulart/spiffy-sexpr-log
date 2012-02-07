(use awful spiffy spiffy-sexpr-log)

(split-log? #t)

(define log-dir "log")

(unless (file-exists? log-dir)
  (create-directory log-dir 'with-parents))

(access-log log-dir)

(define-page (main-page-path)
  (lambda ()
    "foo"))
