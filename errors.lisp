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
  (output 
   (format nil 
           (concatenate 'string 
                        "~%"
                        (string номер-ошибки) 
                        ": "
                        (get-error-text номер-ошибки) 
                        "~%") 
           args))
  (sb-ext:exit :code 1 :abort nil))


(defun explain-error (explain)
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
