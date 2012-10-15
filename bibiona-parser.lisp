(in-package :bibiona-parser)

; Пробельные символы, в том чисте переводы каретки
(defrule прб-сим (+ (or #\space #\tab #\newline #\Linefeed))
  (:constant " "))


; Отдельное правило для переводов каретки для однострочных комментариев
(defrule конец-строки (or #\Newline
                          #\Linefeed
                          (and #\Newline #\Linefeed)))

; Однострочные комментарии
(defrule строчный-комментарий (and "//"
                                   (* (and (! конец-строки) character))
                                   (or (! character) конец-строки)))

(defrule много-комментарий (and "(*" (* (and (! "*)") character)) (or "*)" (! character))))

; Пробельные символы + комментарии
(defrule прб (+ (or прб-сим
                    строчный-комментарий
                    много-комментарий))
  (:constant " "))

; Тут, конечно, были бы удобнее классы
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

; Правило для именования точек, .А0'
(defrule имя-точки (and #\. (+ (or цифры-точки буквы-точки)) (? (+ амп-точки)))
  (:destructure (dot txt amp) (concatenate 'string dot (text txt) (text amp))))

; Оператор "Базовая точка"
(defrule base-point (and (~ "Базовая") (+ прб) (~ "точка") (+ прб) имя-точки)
  (:destructure (b w1 p w2 dn) (declare (ignore b p w1 w2)) (list :БАЗОВАЯ-ТОЧКА dn)))


; Следующие правила задают цепочку операторов и последнюю, висячую,
; точку с запятой.
(defrule оператор (or базовая-точка))
(defrule остаток-операторы (and (? прб) ";" (? прб) оператор)
  (:destructure (w1 semi w2 op) (declare (ignore w1 w2 semi)) op))

(defrule последняя-тз (and (? прб) ";" (? прб)))

(defrule операторы (and оператор (* остаток-операторы) (? последняя-тз))
  (:destructure (op lst ws) (declare (ignore ws)) (cons op lst)))

; Отдельные слова и операторы
(defrule точка-оп (and (? прб)
                       (or (~ "точка") (~ "точки"))
                       (? прб))
  (:constant :ТОЧКА))

(defrule отрезок-оп (and (? прб) (or  (~ "отрезок")
                                      (~ "отрезка")
                                      (~ "отрезком")) (? прб))
  (:constant :ОТРЕЗОК))

(defrule от (and (? прб) (~ "от") (? прб)) (:constant :ОТ))
(defrule до (and (? прб) (~ "до") (? прб)) (:constant :ДО))
(defrule на (and (? прб) (~ "на") (? прб)) (:constant :НА))
(defrule расстояние (and (? прб) (~ "расстояние") (? прб)) (:constant :РАССТОЯНИЕ)))

; Направление
(defrule вправо (and (? прб) (~ "вправо") (? прб)) (:constant :ВПРАВО))
(defrule влево  (and (? прб) (~ "влево")  (? прб)) (:constant :ВЛЕВО))
(defrule вверх  (and (? прб) (~ "вверх")  (? прб)) (:constant :ВВЕРХ))
(defrule вниз   (and (? прб) (~ "вниз")   (? прб)) (:constant :ВНИЗ))

(defrule направление (or вверх
                         вниз
                         вправо
                         влево))


(defrule отрезок-от-до (and отрезок-оп
                            от
                            (? точка-оп) имя-точки
                            до
                            (? точка-оп) имя-точки)
  (:destructure (lop fr dt1 dn1 to dt2 dn2)
    (declare (ignore lop fr dt1 to dt2)) 
    (list :ОТРЕЗОК dn1 dn2)))

(defrule направленный-отрезок (and отрезок-оп направление от (? точка-оп) имя-точки (? (and точка-оп имя-точки)))
  (:destructure (line dir from dt1 dn1 dot)
    (declare (ignore dir from dt1))
    (list line dn1 (if dot dot (list :НОВАЯ)))))

(defrule отрезок (or отрезок-от-до
                     направленный-отрезок))

(defrule направленная-точка (and точка-оп имя-точки направление от (? точка-оп) имя-точки на (? расстояние)))

(defrule точка (or направленная-точка))
