(in-package :bibiona-parser)

(defparameter *file-extensions*
  '(:backup :fabric :fabricx :fab :jpg :png :txt :desc :code))

(defun change-ext (filename dst)
  "Функция меняет расширение файла на содержимое dst.
Проверяется факт вхождения dst в список *file-extensions*.

В качестве защиты проверяется факт заполнения filename.

Параметр backup формирует резервное имя файла (.~ext)
Если в качестве 
"
  (let ((fl (if (or 
                 (null filename) 
                 (not (member dst *file-extensions*))) 
                nil
                (merge-pathnames (parse-namestring filename)))))
    (when fl
      (let* ((ext (if (equal dst :backup) 
                      (concatenate 'string "~" (pathname-type fl))
                      (string-downcase (string dst)))))
        (make-pathname :host      (pathname-host fl) 
                       :device    (pathname-device fl)
                       :directory (pathname-directory fl)
                       :name      (pathname-name fl)
                       :type      ext)))))

(defun собираю-изделие (&key fabric fabricx desc photos tech-draw)
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
    (uiop:with-temporary-file (:pathname tmp :keep t :prefix "bp-fab-")
      (zip:with-output-to-zipfile (fab tmp :if-exists :supersede)
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
          
          (if (not *hide-source*)
              (write-file-list fab (list fabric) "Изделие"))
          (write-file-list fab (list fabricx) "Чертеж")
          (write-file-list fab (list desc)    "Описание")
          (write-file-list fab photos         "Фото")
          (write-file-list fab tech-draw      "Техрисунок")))
      (rename-with-backup tmp fabname))
    fabname))

(defun check-file-sanity (fname)
  (if fname 
      (if (probe-file fname) 
          t
          (error-bibiona :CMD-004 fname))
      t))

(defun rename-with-backup (from to &key (backup t))
  ;; Все работы начинаем только в том случае, если файл, 
  ;; который собираемся переименовывать существует.
  (when (probe-file from)
    (when backup
      (let ((to-backup (change-ext to :backup)))
        ;; Если переменная backup установлена в Т, то 
        ;; 1) удаляем предыдущую резервную копию.
        ;; 2) Переименовываем to-файл в резервную копию
        ;; 3) Переименовываем from-файл в to-файл.
        (if (probe-file to-backup)
            (delete-file to-backup))
        (if (probe-file to)
            (rename-file to to-backup))))
    (if (probe-file to)
        (delete-file to))
    (rename-file from to)))

