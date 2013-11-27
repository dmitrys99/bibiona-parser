(in-package :bibiona-parser)

;;(defparameter *неправильная-ошибка*)

(defparameter *error-list* 
  ;; Что случилось
  ;; Почему
  ;; Что делать

  '(:CMD 
    #(;; CMD-001
      ("Не указано имя входного файла с конструкцией. Используйте параметр '-f'."
       "Вы не указали входной файл. Необходимо указать имя входного файла."
       "Укажите название входного файла: bibiona-parser -f <имя файла.fabric>")
      ;; CMD-002
      ("Попытка получить справку по несуществующей ошибке ~A"
       "Номер сообщения об ошибке, информацию о котором вы пытаетесь получить, не существует в программе."
       "Пожалуйста, укажите другой номер ошибки.")
      ;; CMD-003
      ("Не указана обязательная опция ('-f', '-e')"
       "Вы не указали одну из обязательных опций программы: -f <файл>.fabric или -e <код ошибки>"
       "Вызовите программу с параметрами: bibiona-parser -f <файл>.fabric или bibiona-parser -e <код ошибки>")
      ;; CMD-004
      ("Файл ~A не найден."
       "Вы указали входной файл, но программа не может его найти."
       "Укажите существующий входной файл с помощью параметра -f.")
      )
    :PRS
    #(;; PRS-001
      ("Разбор файла закончился неудачей."
       "Случилась ошибка в программном коде транслятора. Обычно вы не должны видеть это сообщение; это фатальная ошибка."
       "Обратитесь к разработчику с приложением кода изделия, которое вы пытались произвести.")
      ;; PRS-002
      ("~A:~A:~A Ожидается '~A', обнаружено '~A'."
       ""
       "")
      ;; PRS-003
      ("Файл ~A не в кодировке UTF-8."
       "Невозможно прочитать данные из файла, так как он сохранен в кодировке, отличной от UTF-8."
       "Пожалуйста, сохраните файл в кодировке UTF-8 (для ознакомления с соответствующими настройками некоторых редакторов обратитесь на web-сайт программы).")
      )
    :SEM
    #(;; SEM-001
      ("~A:~A:~A Точка '~A' уже определена (~A:~A)"
       "Имя точки, которое вы хотите использовать, ранее уже было определено с помощью оператора ТОЧКА."
       "Вам следует использовать другое название для новой точки.")
      )
    ))

(defun get-error-text (номер-ошибки)
  (assert (keywordp номер-ошибки))
  (let* ((str (string номер-ошибки))
         (pos (position #\- str)))
    (assert (not (null pos)))
    (let ((раздел (intern (subseq str 0 pos) :keyword))
          (номер (handler-case 
                     (parse-integer (subseq str (1+ pos))) 
                   (error (c) 
                     (declare (ignore c))
                     -1)))
          (rzd #()))
      (setf rzd (getf *error-list* раздел))
      
      (if (and rzd (>= (length rzd) номер 0))
          (let ((item (aref rzd (1- номер))))
            (values (first item)
                    (second item)
                    (third item)))
          )
      )))

(defun error-bibiona (номер-ошибки &rest args)
  ;;  #+bibiona-debug                       
  (output
   (eval `(format nil 
                  (concatenate 'string 
                               "~%"
                               (string ,номер-ошибки) 
                               ": "
                               (get-error-text ,номер-ошибки) 
                               "~%") 
                  ,@args)))
  #-BIBIONA-DEBUG
  (sb-ext:exit :code 1 :abort nil))


(defun объясняю-ошибку (explain)
  (when (not (eql explain '()))
    (let* ((e (apply #'concatenate (cons 'string explain)))
           (ie (intern e :keyword)))
      (if (and (> (length e) 4) (char= (elt e 3) #\-))
          (multiple-value-bind (et w d)
              (get-error-text ie)
            (if et 
                (output 
                 (format nil 
                         "Сообщение: ~A~%~%Текст сообщения:~%~A~%~%Почему?~%~A~%~%Что делать?~%~A~%" 
                         e et w d))
                (error-bibiona :CMD-002 e)))
          (error-bibiona :CMD-002 ie)))
    nil))

(defun get-lc-from-pos (text position)
  (list 
   ; line
   (1+ (count #\Newline text :end position))
   ; col
   (- position (or (position #\Newline text
                             :end position
                             :from-end t)
                   0)
      0)))

(defun describe-parse-error (c)
  (alexandria:if-let ((text (esrap-error-text c))
                      (position (esrap-error-position c))
                      (expressions (esrap-error-expressions c)))
    (let* ((lc (get-lc-from-pos text position))
           (line (first lc))
           (column (second lc))
           ;; FIXME: magic numbers
           (start (or (position #\Newline text
                                :start (max 0 (- position 32))
                                :end (max 0 (- position 24))
                                :from-end t)
                      (max 0 (- position 24))))
           (end (min (length text) (+ position 24)))
           (expected (esrap:rule-expected 
                      (esrap:find-rule 
                       (first (find-if #'(lambda (x) (if (symbolp (first x)) t nil)) 
                                       expressions
                                       :from-end t))))))
      (values
       (if (alexandria:emptyp text) "" (subseq text start end))       
       (1+ line) 
       (1+ column)
       expected))
    (values
     ""
     nil 
     nil
     nil)))
