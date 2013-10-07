(defsystem bibiona-parser
    :description
  "Система определяет транслятор для проекта \"Бибиона\".
Транслятор производит текстовое описание конструкции швейного изделия в форму,
пригодную для выполнения виртуальной машиной, отображающей конструкцию
на экране, принтере и web-странице."
  :maintainer "Дмитрий Соломенников <dmitrys99@mail.ru>"
  :depends-on (#:esrap 
               #:parse-number 
               #:cli-parser
               #:alexandria
               #:uiop
               #:zip)
  :version #.(with-open-file
                 (f (merge-pathnames
                     "version.lisp-expr"
                     (or *compile-file-pathname* *load-truename*)))
               (read f))

  :in-order-to ((asdf:test-op (asdf:load-op :bibiona-parser-tests)))
  :perform (asdf:test-op :after (op c)
                         (funcall (intern
                                   (symbol-name '#:run!) '#:5am)
                                  :bibiona-parser))
  :serial t
  :components ((:file "package")
               (:file "bibiona-parser")
               (:file "bibiona-generator")
               (:file "utils")
               (:file "file-utils")
               (:file "errors")
               (:file "infrastructure")))

(defsystem bibiona-parser-tests
    :depends-on (#:bibiona-parser
                 #:fiveam)
    :components ((:module "tests"
                          :serial t
                          :components ((:file "package"       )
                                       (:file "test-spaces"   )
                                       (:file "test-arith"    )
                                       (:file "test-simple-kw")
                                       (:file "test-op-dot"   )
                                       (:file "test-op-line"  )))))
