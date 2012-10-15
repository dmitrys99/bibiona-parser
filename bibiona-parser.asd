(defsystem bibiona-parser
  :depends-on (#:esrap #:parse-number)
  :serial t
  :components ((:file "package")
               (:file "bibiona-parser")))
