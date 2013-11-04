(in-package :bibiona-parser)

(defun parse-text (исходный-файл содержимое)
  (let ((parsed)
        (line)
        (column)
        (text)
        (expected))

    (handler-case 
        (setf parsed (esrap:parse 'старт содержимое))
      (esrap:esrap-error (c)
        (multiple-value-bind (tx ln col ex)
            (describe-parse-error c)
          (setf expected ex
                line ln
                column col
                parsed nil
                text tx
                expected (if (listp ex) (format nil "~{~A~^, ~}" ex) ex)))
        ))
    

    ;; При успехе надо вернуть 3 параметра: nil ошибка параметры. 
    ;; Пока в тепличных условиях всегда возвращается t
    (if parsed
        (generate parsed)
        (values nil :PRS-002 (merge-pathnames исходный-файл) line column expected text))))

(defun транслирую (исходный-файл)
  (uiop:with-temporary-file (:pathname чертеж :keep t :prefix "bp-fbx-")
    (with-output-to-fabricx чертеж

      ;; Вообще-то этот код не должен выполняться, т.к. функция
      ;; "транслирую" не должна вызываться самостоятельно и
      ;; существование файла должно проверяться вышележащим кодом. Тем
      ;; не менее, если все-же функция была вызвана самостоятельно, то
      ;; отсутствие входного файла - фатальная ошибка.
      (if (not (probe-file исходный-файл))
          (error-bibiona :CMD-004 исходный-файл))

      (let* ((res)
             (получилось)
             (содержимое 
               (handler-case 
                   (alexandria:read-file-into-string исходный-файл :external-format :utf-8)
                 (SB-INT:STREAM-DECODING-ERROR (c)
                   (declare (ignore c))
                   (setf res (list nil :PRS-003 исходный-файл))
                   :НЕ-УТФ))))

        (if (not (eql содержимое :НЕ-УТФ))
            (progn
              (setf res (multiple-value-list (parse-text исходный-файл содержимое))
                    получилось (first res))
              (if получилось
                  (setf res (list чертеж)))))

        (apply #'values res)))))

(defun собираю (исходный-файл фото описание техрисунки &optional (удалить-чертеж t))
  ;; (output исходный-файл)
  (when (check-file-sanity исходный-файл)
    (let ((res)
          (чертеж))
      
      (setf res (multiple-value-list 
                 (транслирую исходный-файл)))
      (setf чертеж (first res))
      (if чертеж
          (progn 
            (собираю-изделие :fabric исходный-файл 
                             :fabricx чертеж 
                             :desc описание 
                             :photos фото 
                             :tech-draw техрисунки)
            (if удалить-чертеж (delete-file чертеж)))
          (apply #'error-bibiona (cdr res))))))

