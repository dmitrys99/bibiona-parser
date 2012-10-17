(defpackage :bibiona-parser-tests
  (:use :cl :FiveAM :bibiona-parser))

(in-package :bibiona-parser-tests)

(in-suite* :bibiona-parser)

#| Правило ПРБ-СИМ |# 
(test (прб-сим.1)
  (is (equalp (esrap:parse 'bibiona-parser::прб-сим " ") " ")))
(test (прб-сим.2)
  (is (equalp (esrap:parse 'bibiona-parser::прб-сим "
") " ")))
(test (прб-сим.3)
  (is (equalp (esrap:parse 'bibiona-parser::прб-сим "


") " ")))
