(module spiffy-split-sexpr-log ()

(import scheme)
(cond-expand
  (chicken-4
   (import chicken)
   (use data-structures extras files posix srfi-1 utils))
  (chicken-5
   (import (chicken base)
           (chicken io)
           (chicken file)
           (chicken format)
           (chicken pathname)
           (chicken process-context)
           (chicken string))
   (import (only srfi-1 last))
   (define read-file read-list))
  (else
   (error "Unsupported CHICKEN version.")))

(include "common.scm")

(define-record date year month day)

(define months
  '((Jan . "01")
    (Feb . "02")
    (Mar . "03")
    (Apr . "04")
    (May . "05")
    (Jun . "06")
    (Jul . "07")
    (Aug . "08")
    (Sep . "09")
    (Oct . "10")
    (Nov . "11")
    (Dec . "12")))

(define (parse-date date)
  (let ((tokens (string-split date)))
    (make-date (last tokens)
               (alist-ref (string->symbol (cadr tokens)) months)
               (caddr tokens))))


(define (log-line line log-file)
  (with-output-to-file log-file
    (lambda ()
      (printf "~S\n" line))
    append:))


(define (split-log log-file output-dir)
  (when (file-exists? output-dir)
    (print output-dir " already exists.  Aborting.")
    (exit 1))
  (create-directory output-dir 'with-parents)
  (let ((data (with-input-from-file log-file read-file))
        (overwritten-log-files '()))
    (for-each (lambda (line)
                (unless (pair? line)
                  (print "This log file doesn't seem to be in the sexpr format. Aborting.")
                  (exit 1))
                (let* ((d (parse-date (cadr line)))
                       (dir (make-pathname (list output-dir (date-year d))
                                           (date-month d)))
                       (split-log-file
                        (make-pathname dir (pad-number (date-day d) 2) "log")))
                  (unless (directory-exists? dir)
                    (create-directory dir 'with-parents))
                  (log-line line split-log-file)))
              data)))

(define (usage #!optional exit-code)
  (print "Usage: " (pathname-strip-directory (program-name)) " <log file> <output dir>")
  (when exit-code (exit exit-code)))


(let* ((args (command-line-arguments)))
  (when (or (null? args)
            (null? (cdr args)))
    (usage 1))
  (split-log (car args) (cadr args)))

) ;; end module
