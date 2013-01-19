(in-package :bibiona-parser)

#| ПРОБЕЛЬНЫЕ СИМВОЛЫ, В ТОМ ЧИСЛЕ ПЕРЕВОДЫ КАРЕТКИ |#
(defrule прб-сим (+ (or #\space #\tab #\newline))
  (:constant " "))


#| ПРАВИЛО ДЛЯ ПЕРЕВОДОВ КАРЕТКИ  |#
#| ДЛЯ ОДНОСТРОЧНЫХ КОММЕНТАРИЕВ |#
(defrule конец-строки (or #\Newline
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
(defrule буквы-точки (or "А" "Б" "В" "Г" "Д" "Е" "Ё" "Ж" "З" "И" "Й"
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
(defrule имя-точки (and #\.
                        (+ (or цифры-точки буквы-точки))
                        (* амп-точки))
  (:destructure (dot txt amp) (concatenate 'string dot (text txt) (text amp))))

(defrule от (~ "от") (:constant :ОТ))
(defrule до (~ "до") (:constant :ДО))
(defrule на (~ "на") (:constant :НА))

(defrule мм (~ "мм") (:constant :ММ))
(defrule см (~ "см") (:constant :СМ))
(defrule м  (~ "м")  (:constant :М ))
(defrule ед-изм (or мм см м))

(defrule расстояние (~ "расстояние") (:constant :РАССТОЯНИЕ))


#| НАПРАВЛЕНИЕ |#
(defrule вправо (~ "вправо") (:constant :ВПРАВО))
(defrule влево  (~ "влево")  (:constant :ВЛЕВО))
(defrule вверх  (~ "вверх")  (:constant :ВВЕРХ))
(defrule вниз   (~ "вниз")   (:constant :ВНИЗ))

(defrule направление (or вверх вниз вправо влево))

#| АРИФМЕТИКА |#
(defrule число (and (+ (digit-char-p character))
                    (? (and #\. (* (digit-char-p character))))
                    (? (and (or "e" "E" "е" "Е")
                            (? (or "-" "+"))
                            (+ (digit-char-p character)))))

  (:lambda (list)
    (if (string-equal (car (third list)) "е")
        (setf (car (third list)) "E"))
    (* 1.0 (parse-number:parse-number
            (string-trim '(#\space
                           #\tab
                           #\linefeed
                           #\newline) (text list))))))

(defrule выражение (and терм (* (and (? прб) (or "-" "+") (? прб) выражение)))
  (:lambda (list)
    (if (second list)
        (let ((arg1 (car list))
              (arg2 (caadr list)))
          (list (second arg2)
                arg1
                (fourth arg2)))
        (car list))))

(defrule терм (and фактор (* (and (? прб) (or "/" "*") (? прб) терм)))
  (:lambda (list)
;    (break "~A" list)
    (if (second list)
        (let ((arg1 (car list))
              (arg2 (caadr list)))
          (list (second arg2)
                arg1
                (fourth arg2)))
        (car list))))

(defrule лев-круг-скб "(" (:constant "("))
(defrule прв-круг-скб ")" (:constant ")"))

(defrule фактор (or (and число (? (and (+ прб) ед-изм))) 
                    (and лев-круг-скб (? прб) 
                         выражение 
                         (? прб) прв-круг-скб))
  (:lambda (list)
    ;(break "~A" list)
    (cond (;; <число>
           (and
            (= 2 (length list))
            (null (second list)))          (first list))
          ;; <число> <ед>
          ((and (= 2 (length list))
                (not (null (second list)))) (list (first list) 
                                                  (cadr (second list))))
          ;; ( <выражение> )
          ((= 5 (length list))             (third list))

          ;; другое
          (t list))))
#| КОНЕЦ АРИФМЕТИКИ |#

#| КС: ТОЧКА |#
(defrule точка-кс (or (~ "точка") (~ "точки")) (:constant :ТОЧКА))

#| ОП: БАЗОВАЯ ТОЧКА |#
 (defrule базовая-точка (and точка-кс (+ прб) имя-точки (+ прб) (~ "Базовая"))
  (:destructure (p w1 dn w2 b) 
                (declare (ignore b p w1 w2)) 
                (list :ТОЧКА dn :БАЗОВАЯ)))


#| ОП: НАПРАВЛЕННАЯ ТОЧКА |#
(defrule направленная-точка (and точка-кс       (+ прб)
                                 имя-точки      (+ прб)
                                 направление    (+ прб)
                                 от             (+ прб)
                                 (? (and точка-кс (+ прб)))
                                 имя-точки      (+ прб)
                                 на             (+ прб)
                                 (? (and расстояние (+ прб)))
                                 выражение)
  (:destructure (d1 w1 n1 w2 dir w3 from w4 d2 n2 w5 to w7 dist expr)
(declare (ignore d1 from d2 to dist w1 w2 w3 w4 w5 w7 ))
(list :ТОЧКА n1 n2 dir :РАССТОЯНИЕ expr)))

#| ОП: ТОЧКА |#
(defrule точка (or направленная-точка базовая-точка))

#| КС: ОТРЕЗОК |#
(defrule отрезок-кс  (or  (~ "отрезок")
                          (~ "отрезка")
                          (~ "отрезком"))
  (:constant :ОТРЕЗОК))

#| ОП: ОТРЕЗОК ОТ ... ДО ... |#
(defrule отрезок-от-до (and отрезок-кс   (+ прб)
                            от           (+ прб)
                            (? (and точка-кс (+ прб)))
                            имя-точки    (+ прб)
                            до           (+ прб)
                            (? (and точка-кс (+ прб)))
                            имя-точки)
  (:destructure (lop w1 fr w2 dt1 dn1 w3 to w4 dt2 dn2)
    (declare (ignore lop fr dt1 to dt2 w1 w2 w3 w4))
    (list :ОТРЕЗОК dn1 dn2)))

#| ОП: НАПРАВЛЕННЫЙ ОТРЕЗОК |#
(defrule направленный-отрезок (and отрезок-кс           (+ прб)
                                   направление          (+ прб)
                                   от                   (+ прб)
                                   (? (and точка-кс     (+ прб))) 
                                   имя-точки            (+ прб)
                                   на                   (+ прб)
                                   (? (and расстояние   (+ прб))) 
                                   выражение            
                                   (? (and              (+ прб) 
                                           точка-кс     (+ прб) 
                                           имя-точки)))
  (:destructure (line w1 
                      dir  w2 
                      from w3
                      dt1 
                      dn1 w4
                      to  w5 
                      di expr 
                      dot)
    (declare (ignore line from dt1 w1 w2 w3 w4 w5 to di))
    (list :ОТРЕЗОК dn1 dir expr (if dot (fourth dot) :НОВАЯ))))

#| ОП: ОТРЕЗОК |#
(defrule отрезок (or отрезок-от-до
                     направленный-отрезок))

#| ОП: ОПЕРАТОР |#
(defrule оператор (or точка отрезок))
(defrule остаток-операторы (and (? прб) ";" (? прб) оператор)
  (:destructure (w1 semi w2 op) (declare (ignore w1 w2 semi)) op))

(defrule последняя-тз (and (? прб) ";"))

#| ОП: ОПЕРАТОРЫ |#
(defrule операторы (and оператор (* остаток-операторы) (? последняя-тз))
  (:destructure (op lst ws) (declare (ignore ws)) (cons op lst)))

#| КС: ИЗДЕЛИЕ |#
(defrule изделие-кс (or  (~ "изделие")
                         (~ "изделия")
                         (~ "изделию")))

#| КС: КОНЕЦ |#
(defrule конец-кс (or (~ "конец")
                      (~ "конца")
                      (~ "концу")))

(defrule изделие (and (? прб) 
                      (~ "изделие") (+ прб) 
                      ; (? (and название (+ прб)))
                      операторы (+ прб) 
                      (~ "конец") (+ прб) (~ "изделия") 
                      (? последняя-тз) (? прб))
  (:destructure (w1 i1 w2 op w3 e w4 i2 sem w5)
                (declare (ignore w1 w2 w3 w4 w5 i1 i2 e sem))
                (list :ИЗДЕЛИЕ op)))
