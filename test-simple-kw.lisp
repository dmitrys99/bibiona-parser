(defpackage :bibiona-parser-tests
  (:use :cl :FiveAM :bibiona-parser))

(in-package :bibiona-parser-tests)

(in-suite* :bibiona-parser)

#| Правило ПРБ-СИМ |# 
(test ключевые-слова.1 "Проверка правильности разбора имени точки"
      (is (equalp (esrap:parse 'bibiona-parser::имя-точки ".А0'") ".А0'")))

(test ключевые-слова.2 "Проверка правильности разбора имени точки (неправильное написание)"
      (signals esrap:esrap-error
        (esrap:parse 'bibiona-parser::имя-точки ".'")))
