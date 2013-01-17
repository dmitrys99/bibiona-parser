(defpackage :bibiona-parser-tests
  (:use :cl :FiveAM :bibiona-parser))

(in-package :bibiona-parser-tests)

(in-suite* :bibiona-parser)

#| Правило ПРБ-СИМ |#
(test пробелы.1 "Игнорируются пробельные символы"
  (is (equalp
       (esrap:parse 'bibiona-parser::прб " ")
       " ")))

(test пробелы.2 "Игнорируются переводы каретки"
  (is (equalp
       (esrap:parse 'bibiona-parser::прб "
")
       " ")))

(test пробелы.3 "Игнорируется много пробелов и переводов каретки"
      (is (equalp
           (esrap:parse 'bibiona-parser::прб "


")
           " ")))

(test пробелы.4 "Игнорируются все пробельные символы"
  (is (equalp
       (esrap:parse 'bibiona-parser::прб
                    (concatenate 'string (list #\space #\linefeed #\newline #\tab)))
       " ")))

(test пробелы.5 "Игнорируются однострочные комментарии"
  (is (equalp (esrap:parse 'bibiona-parser::прб
                           (concatenate 'string "//")) " ")))

(test пробелы.6 "Игнорируется однострочный комментарий"
  (is (equalp
       (esrap:parse 'bibiona-parser::прб
                           (concatenate 'string " // комментарий
"))
       " ")))

(test пробелы.7 "Игнорируется многострочный комментарий (одной строкой, конец файла)"
  (is (equalp
       (esrap:parse 'bibiona-parser::прб
                    (concatenate 'string "(* комментарий *)"))
       " ")))

(test пробелы.8 "Игнорируется многострочный комментарий (несколькими строками, конец файла)"
  (is (equalp
       (esrap:parse 'bibiona-parser::прб
                           (concatenate 'string "(* комментарий
комментарий *)"))
       " ")))

(test пробелы.9 "Игнорируется многострочный комментарий (несколькими строками, незакрытая скобка, конец файла)"
  (is (equalp
       (esrap:parse 'bibiona-parser::прб
                    (concatenate 'string "(* комментарий
комментарий *"))
       " ")))


