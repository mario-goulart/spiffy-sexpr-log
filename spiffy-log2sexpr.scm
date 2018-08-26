#!/bin/sh
#| -*- scheme -*-
exec csi -s $0 "$@"
|#
(use posix srfi-13)

(define-record log-line ip date method uri http-version code referer user-agent)

(define parse-log-line
  ;; IP [date] "<method> URI HTTP/<version>" resp-code "<referer>" "<user agent>"
  (let ((pattern
         (irregex
          (string-append "\\[([^\\]]+)\\] " ;; date
                         "\"([^\"]+)\" " ;; uri
                         "([0-9]+) " ;; resp-code
                         "\"([^\"]+)\" " ;; referer
                         "\"([^\"]+)\"")))) ;; user agent
    (lambda (line)
      (let* ((tokens (string-split line))
             (ip (car tokens))
             (line (string-intersperse (cdr tokens) " "))
             (matches (irregex-match pattern line))
             (date (irregex-match-substring matches 1))
             (uri (irregex-match-substring matches 2))
             (code (string->number (irregex-match-substring matches 3)))
             (referer (irregex-match-substring matches 4))
             (user-agent (irregex-match-substring matches 5))
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
                       (string->number
                        (irregex-replace "HTTP/" (log-line-http-version log) ""))
                       (log-line-code log)
                       (log-line-referer log)
                       (list (string-drop (string-drop-right (log-line-user-agent log) 1) 1)))))))
   (read-lines (car args))))
