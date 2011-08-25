#!/bin/sh
#| -*- scheme -*-
exec csi -s $0 "$@"
|#
(use regex posix)

(define-record log-line ip date method uri http-version code referer user-agent)

(define parse-log-line
  ;; IP [date] "<method> URI HTTP/<version>" resp-code "<referer>" "<user agent>"
  (let ((pattern
         (regexp
          (string-append "\\[([^\\]]+)\\] " ;; date
                         "\"([^\"]+)\" " ;; uri
                         "([0-9]+) " ;; resp-code
                         "\"([^\"]+)\" " ;; referer
                         "\"([^\"]+)\"")))) ;; user agent
    (lambda (line)
      (let* ((tokens (string-split line))
             (ip (car tokens))
             (line (string-intersperse (cdr tokens) " "))
             (tokens (list->vector (cdr (string-match pattern line))))
             (date (vector-ref tokens 0))
             (uri (vector-ref tokens 1))
             (code (string->number (vector-ref tokens 2)))
             (referer (vector-ref tokens 3))
             (user-agent (vector-ref tokens 4))
             (uri-tokens (string-split uri))
             (method (car uri-tokens))
             (uri (cadr uri-tokens))
             (http-version (caddr uri-tokens)))
        (make-log-line ip date method uri http-version code referer user-agent)))))


(define (usage #!optional exit-code)
  (print (pathname-strip-directory (program-name)) " <log file>")
  (when exit-code (exit exit-code)))


(let ((args (command-line-arguments)))
  (when (null? args) (usage 1))
  (when (or (member "-h" args)
            (member "--help" args))
    (usage 0))
  (for-each
   (lambda (line)
     (let ((log (parse-log-line line)))
       (print
        (sprintf "~S"
                 (list (log-line-ip log)
                       (log-line-date log)
                       (string->symbol (log-line-method log))
                       (log-line-uri log)
                       (string->number (string-substitute "HTTP/" "" (log-line-http-version log)))
                       (log-line-code log)
                       (log-line-referer log)
                       (list (string-drop (string-drop-right (log-line-user-agent log) 1) 1)))))))
   (read-lines (car args))))
