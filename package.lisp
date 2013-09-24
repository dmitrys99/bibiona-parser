(defpackage #:bibiona-parser
  (:use :cl
        :esrap)
  (:export #:отрезок
           #:точка
           #:число
           #:операторы
           #:изделие

           #:parse-text
           #:parse-file
           
           #:main))
