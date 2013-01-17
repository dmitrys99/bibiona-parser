(defpackage :bibiona-parser-tests
  (:use :cl :FiveAM :bibiona-parser))

(in-package :bibiona-parser-tests)

(in-suite* :bibiona-parser)

#|
(test операторы.базовая.точка "Базовая точка"
      (is
       (equalp
        (esrap:parse 'bibiona-parser::базовая-точка "базовая точка .ф")
        '(:БАЗОВАЯ-ТОЧКА ".ф"))))

(test операторы.направленная-точка "направленная точка"
      (is
       (equalp
        (esrap:parse 'bibiona-parser::направленная-точка "точка .А0' вправо от .А0 на 10 см")
        '(:ТОЧКА ".А0'" :ВПРАВО ".А0" (10 :СМ)))))

|#
