(in-package :bibiona-parser)

(defparameter *file-extensions*
  '(:fabric :fabricx :fab :jpg :png :txt :desc :code))

(defun change-ext (filename dst)
  "Функция меняет расширение файла на содержимое dst.
Проверяется факт вхождения dst в список *file-extensions*.

В качестве защиты проверяется факт заполнения filename."
  (let ((fl (if (or (null filename) 
                    (not (member dst *file-extensions*))) 
                nil
                (multiple-value-list 
                 (uiop:split-unix-namestring-directory-components filename)))))
    (when fl
      (let ((name (pathname-name (third fl)))
            (ext (string-downcase (string dst))))
        (make-pathname :directory (append 
                                   (list (first fl)) 
                                   (second fl))
                       :name name
                       :type ext)))))

(defun assemble-fabric (&key fabric fabricx desc photos tech-draw)
  "Функция собирает *.fabric-файл из нескольких параметров
 :fabric \"file.fabric\" 
 :fabricx \"file.fabricx\" 
 :desc \"file.desc\" 
 :photos (\"photo1.jpg\"...) 
 :tech-draw (\"draw.jpg\")

Функция проверяет существование и доступность всех файлов."

  ;; Отсутствие параметра fabric - программная ошибка.
  (assert (not (null fabric)))
  
  (check-file-sanity fabric)
  (check-file-sanity fabricx)
  (check-file-sanity desc)
  (mapcar 'check-file-sanity photos)
  (mapcar 'check-file-sanity tech-draw)

  (let ((fabname (change-ext fabric :fab))
        (write-date (get-universal-time)))
    (uiop:with-temporary-file (:pathname tmp :keep t)
      (zip:with-output-to-zipfile (fab tmp :if-exists :supersede :external-format :ibm866)
        (labels ((write-file (zip fname ftype i)
                   (when fname
                     (with-open-file (s fname :element-type '(unsigned-byte 8))
                       (zip:write-zipentry zip 
                                           
                                           (concatenate 'string 
                                                        ftype
                                                        (if i (princ-to-string i) ""))
                                           s
                                           :file-write-date write-date))))
                 (write-file-list (zip lst ftype)
                   (loop 
                     for p in lst
                     for i from 0
                     do (write-file zip p ftype (when (> i 0) i)))))

          (write-file-list fab (list fabric)  "Изделие")
          (write-file-list fab (list fabricx) "Чертеж")
          (write-file-list fab (list desc)    "Описание")
          (write-file-list fab photos         "Фото")
          (write-file-list fab tech-draw      "Техрисунок")))
      (if (probe-file fabname) 
          (delete-file fabname))
      (rename-file tmp fabname)
      )))


(defun check-file-sanity (fname)
  (if fname 
      (if (probe-file fname) 
          t
          (error-bibiona :CMD-004 fname))
      t))



#|

(bibiona-parser::assemble-fabric
          :fabric "c:\\Work\\Emacs\\home\\tfabric\\юбка.fabric"
          :fabricx "c:\\Work\\Emacs\\home\\tfabric\\юбка.fabricx"
          :desc "c:\\Work\\Emacs\\home\\tfabric\\юбка.desc"
          :photos '("c:\\Work\\Emacs\\home\\tfabric\\юбка1.jpg" "c:\\Work\\Emacs\\home\\tfabric\\юбка2.jpg")
          :tech-draw '("c:\\Work\\Emacs\\home\\tfabric\\юбка1.td.jpg"
          "c:\\Work\\Emacs\\home\\tfabric\\юбка2.td.jpg"))

|#
