(in-package :bibiona-parser-tests)

(in-suite* :bibiona-parser)

(test арифметика.1 "фактор"
      (is
       (equalp
        (esrap:parse 'bibiona-parser::фактор "1   мм")
        '(1 :ММ))))

(test арифметика.2 "фактор"
      (is
       (equalp
        (esrap:parse 'bibiona-parser::фактор "(1   мм)")
        '(1 :ММ))))

;; issue #1
(test арифметика.2.пробелы "фактор"
      (signals esrap:esrap-error
        (esrap:parse 'bibiona-parser::фактор " (1   мм) ")))
