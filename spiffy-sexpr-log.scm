(module spiffy-sexpr-log ()

(import chicken scheme posix data-structures)
(use spiffy intarweb uri-common)

(handle-access-logging
 (lambda ()
   (let ((h (request-headers (current-request))))
     (log-to (access-log)
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