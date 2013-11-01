(in-package :bibiona-parser)

(defun parse-text (s)
  (let ((parsed))
    (setf parsed (esrap:parse 'старт s))
    ;; При успехе надо вернуть 3 параметра: nil ошибка параметры. 
    ;; Пока в тепличных условиях всегда возвращается t
    (generate parsed)))

(defun parse-file (filename)
  (if (not (probe-file filename))
      (error-bibiona :CMD-004 filename))
  (let ((content (alexandria:read-file-into-string filename :external-format :utf-8)))
    (parse-text content)))

(defun транслирую (исходный-файл)
  (uiop:with-temporary-file (:pathname чертеж :keep t :prefix "bp-fbx-")
    (with-output-to-fabricx чертеж
      (if (not (probe-file исходный-файл))
          (error-bibiona :CMD-004 исходный-файл))
      (let ((содержимое (alexandria:read-file-into-string исходный-файл :external-format :utf-8)))
        (multiple-value-bind (получилось ошибка параметры-ошибки) 
            (parse-text содержимое)
          (if получилось
              чертеж
              (values nil ошибка параметры-ошибки)))))))

(defun собираю (исходный-файл фото описание техрисунки &optional (удалить-чертеж t))
  (multiple-value-bind (чертеж ошибка параметры-ошибки) 
      (транслирую исходный-файл)
    (if чертеж
        (progn 
          (собираю-изделие :fabric исходный-файл 
                           :fabricx чертеж 
                           :desc описание 
                           :photos фото 
                           :tech-draw техрисунки)
          (if удалить-чертеж (delete-file чертеж)))
        (error-bibiona ошибка параметры-ошибки))))

(defparameter *parser-name* "bibiona-parser")
(defparameter *parser-exe* "bibiona-parser.exe")

(defparameter *cli-opts*
  (list

   (make-instance 
    'cli-parser:cli-option :abbr "f" :full "fabric" :requires-arguments T
                           :description "Входной файл с конструкцией изделия"
                           :example "-f Юбка.fabric, --fabric=Юбка.fabric")

   (make-instance 
    'cli-parser:cli-option :abbr "p" :full "photos" :requires-arguments T
                           :description "Список фотографий для изделия"
                           :example "-p Юбка.jpg, --photos=Юбка.jpg ЮбкаЦветы.jpg")

   (make-instance 
    'cli-parser:cli-option :abbr "d" :full "desc" :requires-arguments T
                           :description "Файл с описанием изделия"
                           :example "-d Юбка.txt, --desc=Юбка.txt")

   (make-instance 
    'cli-parser:cli-option :abbr "t" :full "tech-draw" :requires-arguments t
                           :description "Список файлов, содержащих технические рисунки для изделия"
                           :example "-t Юбка-рисунок.jpg, --tech-draw=Юбка-рисунок.jpg Юбка-рисунок-цветы.jpg")

   (make-instance 
    'cli-parser:cli-option :abbr "e" :full "explain" :requires-arguments t
                           :description "Описание ошибки по ее коду"
                           :example "-t CMD-001, --explain=CMD-001")
   (make-instance
    'cli-parser:cli-option :abbr "n" :full "no-compress" :requires-arguments nil
                           :description "Не производить финальную сборку *.fab-файла после трансляции"
                           :example "--no-compress")))

(defun main-routine (&optional (cmd nil cmd-supplied))
  (let* ((cmdline (if cmd-supplied cmd (cmd-line)))
         (parsed-cmdline (cli-parser:cli-parse-assoc cmdline *cli-opts*)))
    (if (equal parsed-cmdline '((nil nil)))
        (output (cli-parser:cli-usage *parser-name* *cli-opts*))
        (progn 
          (labels ((gv (s) 
                     (find (list s) 
                           parsed-cmdline 
                           :test #'(lambda (i j) 
                                     (equal (first i) 
                                            (first j)))))
                   (val    (s) (cadr (gv s)))
                   (vallst (s) (cdr (gv s))))
            (let* ((fabric    (val    "fabric"))
                   (photos    (vallst "photos"))
                   (desc      (val    "desc"))
                   (tech-draw (vallst "tech-draw"))
                   (explain   (val    "explain")))
              (if (not (or fabric explain))
                  ;; Не указан входной файл -f
                  (error-bibiona :CMD-003) 
                  (progn
                   
                    ;; (output             
                    ;;  (format nil 
                    ;;          "~%Входной файл: ~A~%~%Фотографии: ~A~%~%Технические рисунки: ~A~%~%Описание: ~A~%~%Объяснение: ~A~%~%" 
                    ;;          (не-указано? fabric)
                    ;;          (не-указано? photos)
                    ;;          (не-указано? tech-draw)
                    ;;          (не-указано? desc)
                    ;;          (не-указано? explain)))
                    
                    
                    (cond
                      ((not (null explain)) (объясняю-ошибку explain))
                      ((not (null fabric)) (собираю (first fabric) photos desc tech-draw)
;;                       (princ (format nil "~A" (parse-file (first
;;                       fabric))))
                       )
                      (t (output "ku")))

                    )))))))
  nil)

;; Настраиваем фиксапы и прочие инициализационные вещи.
(defun init ()
  (call-fixups))

(defun main () 
  (init)
  (main-routine))
