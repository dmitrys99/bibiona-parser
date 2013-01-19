(in-package :bibiona-parser-tests)

(in-suite* :bibiona-parser)

(test операторы.базовая.точка "Базовая точка"
      (is
       (equalp
        (esrap:parse 'bibiona-parser::базовая-точка "точка .ф базовая")
        '(:ТОЧКА ".ф" :БАЗОВАЯ))))


(test операторы.направленная-точка "направленная точка"
      (is
       (equalp
        (esrap:parse 'bibiona-parser::направленная-точка 
                     "точка .А0' вправо от .А0 на 10 см")
        '(:ТОЧКА ".А0'" ".А0" :ВПРАВО :РАССТОЯНИЕ (10.0 :СМ)))))
