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

(test ключевые-слова.3 "От"
      (is (equalp (esrap:parse 'bibiona-parser::от "От") :ОТ)))

(test ключевые-слова.4 "До"
      (is (equalp (esrap:parse 'bibiona-parser::до "ДО") :ДО)))

(test ключевые-слова.5 "На"
      (is (equalp (esrap:parse 'bibiona-parser::на "На") :НА)))

(test ключевые-слова.6 "ММ"
      (is (equalp (esrap:parse 'bibiona-parser::мм "Мм") :ММ)))

(test ключевые-слова.7 "См"
      (is (equalp (esrap:parse 'bibiona-parser::см "См") :СМ)))

(test ключевые-слова.8 "М"
      (is (equalp (esrap:parse 'bibiona-parser::м "м") :м)))

(test ключевые-слова.9 "Расстояние"
      (is (equalp (esrap:parse 'bibiona-parser::расстояние "Расстояние") :расстояние)))

(test ключевые-слова.10 "Вправо"
      (is (equalp (esrap:parse 'bibiona-parser::вправо "вправо") :вправо)))

(test ключевые-слова.11 "Влево"
      (is (equalp (esrap:parse 'bibiona-parser::влево "влево") :влево)))

(test ключевые-слова.12 "вниз"
      (is (equalp (esrap:parse 'bibiona-parser::вниз "вниз") :вниз)))

(test ключевые-слова.13 "вверх"
      (is (equalp (esrap:parse 'bibiona-parser::вверх "вверх") :вверх)))

(test ключевые-слова.число.1-0 "Формат чисел"
      (is (equalp (esrap:parse 'bibiona-parser::число " 0 ") 0.0)))

(test ключевые-слова.число.2-0.1 "Формат чисел"
      (is (equalp (esrap:parse 'bibiona-parser::число " 0.1 ") 0.1)))

(test ключевые-слова.число.3-0. "Формат чисел"
      (is (equalp (esrap:parse 'bibiona-parser::число " 0. ") 0.0)))

(test ключевые-слова.число.4-1111.1111 "Формат чисел"
      (is (equalp
           (esrap:parse 'bibiona-parser::число " 1111.1111 ") 1111.1111)))

(test ключевые-слова.число.5-1111. "Формат чисел"
      (is (equalp
           (esrap:parse 'bibiona-parser::число " 1111. ") 1111.0)))

(test ключевые-слова.число.6-1111.e1 "Формат чисел"
      (is (equalp
           (esrap:parse 'bibiona-parser::число " 1111.e1 ") 11110.0)))

(test ключевые-слова.число.7-1111.e+1 "Формат чисел"
      (is (equalp
           (esrap:parse 'bibiona-parser::число " 1111.e+1 ") 11110.0)))

(test ключевые-слова.число.8-1234.e-10 "Формат чисел"
      (is (equalp
           (esrap:parse 'bibiona-parser::число " 1234.e-10 ") 1.234e-7)))

(test ключевые-слова.число.рус.9-1234.e-10 "Формат чисел"
      (is (equalp
           (esrap:parse 'bibiona-parser::число " 1234.е-10 ") 1.234e-7)))

(test ключевые-слова.точка.1 "Точка-кс"
      (is (equalp
           (esrap:parse 'bibiona-parser::точка-кс " точка ") :ТОЧКА)))

(test ключевые-слова.точки.2 "Точка-кс"
      (is (equalp
           (esrap:parse 'bibiona-parser::точка-кс " точки ") :ТОЧКА)))
