(in-package :bibiona-parser)

#| ПРОБЕЛЬНЫЕ СИМВОЛЫ, В ТОМ ЧИСЛЕ ПЕРЕВОДЫ КАРЕТКИ |#
(defrule прб-сим (+ (or #\space #\tab #\newline #\Linefeed))
  (:constant " "))


#| ПРАВИЛО ДЛЯ ПЕРЕВОДОВ КАРЕТКИ  |#
#| ДЛЯ ОДНОСТРОЧНЫХ КОММЕНТАРИЕВ |#
(defrule конец-строки (or #\Newline
                          #\Linefeed
                          (and #\Newline #\Linefeed)))

#| ОДНОСТРОЧНЫЕ КОММЕНТАРИИ |#
(defrule строчный-комментарий (and "//"
                                   (* (and (! конец-строки) character))
                                   (or (! character) конец-строки)))

#| МНОГОСТРОЧНЫЕ КОММЕНТАРИИ |#
(defrule много-комментарий (and "(*" (* (and (! "*)") character)) (or "*)" (! character))))

#| ПРОБЕЛЬНЫЕ СИМВОЛЫ И КОММЕНТАРИИ |#
(defrule прб (+ (or прб-сим
                    строчный-комментарий
                    много-комментарий)) (:constant " "))

#| ОПРЕДЕЛЕНИЕ БУКВ, ЦИФР И АМПЕРСАНДА |#
(defrule буквы-точки (or  "А" "Б" "В" "Г" "Д" "Е" "Ё" "Ж" "З" "И" "Й"
                          "К" "Л" "М" "Н" "О" "П" "Р" "С" "Т" "У" "Ф"
                          "Х" "Ц" "Ч" "Ш" "Щ" "Ъ" "Ы" "Ь" "Э" "Ю" "Я"

                          "а" "б" "в" "г" "д" "е" "ё" "ж" "з" "и" "й"
                          "к" "л" "м" "н" "о" "п" "р" "с" "т" "у" "ф"
                          "х" "ц" "ч" "ш" "щ" "ъ" "ы" "ь" "э" "ю" "я"
                          
                          "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m"
                          "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z"
                          
                          "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M"
                          "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"))
(defrule цифры-точки (or "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"))
(defrule амп-точки "'")

#| ПРАВИЛО ДЛЯ ИМЕНОВАНИЯ  ТОЧЕК, .А0' |#
(defrule имя-точки (and #\. (+ (or цифры-точки буквы-точки)) (? (+ амп-точки)))
  (:destructure (dot txt amp) (concatenate 'string dot (text txt) (text amp))))

(defrule от (and (? прб) (~ "от") (? прб)) (:constant :ОТ))
(defrule до (and (? прб) (~ "до") (? прб)) (:constant :ДО))
(defrule на (and (? прб) (~ "на") (? прб)) (:constant :НА))

(defrule мм (and (? прб) (~ "мм") (? прб)) (:constant :ММ))
(defrule см (and (? прб) (~ "см") (? прб)) (:constant :СМ))
(defrule м  (and (? прб) (~ "м") (? прб)) (:constant :М))
(defrule ед-изм (or мм см м))

(defrule расстояние (and (? прб) (~ "расстояние") (? прб)) (:constant :РАССТОЯНИЕ))


#| НАПРАВЛЕНИЕ |#
(defrule вправо (and (? прб) (~ "вправо") (? прб)) (:constant :ВПРАВО))
(defrule влево  (and (? прб) (~ "влево")  (? прб)) (:constant :ВЛЕВО))
(defrule вверх  (and (? прб) (~ "вверх")  (? прб)) (:constant :ВВЕРХ))
(defrule вниз   (and (? прб) (~ "вниз")   (? прб)) (:constant :ВНИЗ))

(defrule направление (or вверх вниз вправо влево))

#| АРИФМЕТИКА |#
(defrule число (and (? прб)
                    (+ (digit-char-p character))
                    (? (and #\. (* (digit-char-p character))))
                    (? (and (or "e" "E" "е" "Е")
                            (? (or "-" "+"))
                            (* (digit-char-p character))))
                    (? прб))
  
  (:lambda (list)
    (if (string-equal (car (fourth list)) "е")
        (setf (car (fourth list)) "E"))
    (* 1.0 (parse-number:parse-number (text list)))))

(defrule выражение (and терм (* (and (or "-" "+") выражение)))
  (:lambda (list)
    (if (second list)
        (list (caaadr list) (car list) (car (cdaadr list)))
        (car list))))

(defrule терм (and фактор (* (and (or "/" "*") терм)))
  (:lambda (list)
    (if (second list)
        (list (caaadr list) (car list) (car (cdaadr list)))
        (car list))))
  
(defrule лев-круг-скб (and (? прб) "(" (? прб)) (:constant "("))
(defrule прв-круг-скб (and (? прб) ")" (? прб)) (:constant ")"))

(defrule фактор (or (and число (? ед-изм)) (and лев-круг-скб выражение прв-круг-скб))
  (:lambda (list)
    (cond ((and (= 2 (length list)) (null (second list))) (first list))
          ((= 3 (length list)) (second list))
          (t list))))
#| КОНЕЦ АРИФМЕТИКИ |#

#| КС: ТОЧКА |#
(defrule точка-кс (and (? прб)
                       (or (~ "точка") (~ "точки"))
                       (? прб)) (:constant :ТОЧКА))

#| ОП: БАЗОВАЯ ТОЧКА |#
(defrule базовая-точка (and (~ "Базовая") (+ прб) точка-кс (+ прб) имя-точки)
  (:destructure (b w1 p w2 dn) (declare (ignore b p w1 w2)) (list :БАЗОВАЯ-ТОЧКА dn)))


#| ОП: НАПРАВЛЕННАЯ ТОЧКА |#
(defrule направленная-точка (and точка-кс имя-точки направление от (? точка-кс) имя-точки на (? расстояние) выражение))

#| ОП: ТОЧКА |#
(defrule точка (or направленная-точка базовая-точка))

#| КС: ОТРЕЗОК |#
(defrule отрезок-кс (and (? прб) (or  (~ "отрезок")
                                      (~ "отрезка")
                                      (~ "отрезком")) (? прб))
  (:constant :ОТРЕЗОК))

#| ОП: ОТРЕЗОК ОТ ... ДО ... |#
(defrule отрезок-от-до (and отрезок-кс
                            от
                            (? точка-кс) имя-точки
                            до
                            (? точка-кс) имя-точки)
  (:destructure (lop fr dt1 dn1 to dt2 dn2)
    (declare (ignore lop fr dt1 to dt2)) 
    (list :ОТРЕЗОК dn1 dn2)))

#| ОП: НАПРАВЛЕННЫЙ ОТРЕЗОК |#
(defrule направленный-отрезок (and отрезок-кс
                                   направление
                                   от (? точка-оп) имя-точки
                                   на (? расстояние) выражение
                                   (? (and точка-оп имя-точки)))
  (:destructure (line dir from dt1 dn1 dot)
    (declare (ignore line dir from dt1))
    (list :ОТРЕЗОК dn1 (if dot dot :НОВАЯ))))

#| ОП: ОТРЕЗОК |#
(defrule отрезок (or отрезок-от-до
                     направленный-отрезок))

#| ОП: ОПЕРАТОР |#
(defrule оператор (or точка отрезок))
(defrule остаток-операторы (and (? прб) ";" (? прб) оператор)
  (:destructure (w1 semi w2 op) (declare (ignore w1 w2 semi)) op))

(defrule последняя-тз (and (? прб) ";" (? прб)))

(defrule операторы (and оператор (* остаток-операторы) (? последняя-тз))
  (:destructure (op lst ws) (declare (ignore ws)) (cons op lst)))
