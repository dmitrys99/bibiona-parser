(in-package :bibiona-parser)

(defun parse-text (s)
  (let ((parsed))
    (setf parsed (esrap:parse 'изделие s))
    (generate-all parsed)))

(defun parse-file (filename))

(defparameter *parser-name* "bibiona-parser")
(defparameter *parser-exe* "bibiona-parser.exe")


;;(defun tr (x) 
;;  (ccl:decode-string-from-octets 
;;   (ccl:encode-string-to-octets x :external-format :CYRILLIC)
;;   :external-format :cyrillic))

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
                           :example "-t CMD-001, --explain=CMD-001")))


(defun main () 
  (main-routine))

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
            (let* ((fabric    (val "fabric"))
                   (photos    (vallst "photos"))
                   (desc      (val "desc"))
                   (tech-draw (vallst "tech-draw"))
                   (explain   (val "explain")))
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
                      ((not (null explain)) (explain-error explain))
                      ((not (null fabric)) "Компиляция")
                      (t (output "ku")))

                    )))))))
  nil)
