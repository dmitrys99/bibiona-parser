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

(defun assemble-fabric (filelist)
  "Функция собирает *.fabric-файл из списка filelist
(:fabric \"file.fabric\" 
 :fabricx \"file.fabricx\" 
 :desc \"file.desc\" 
 :photos (\"photo1.jpg\"...) 
 :tech-draw (\"draw.jpg\"))

Функция проверяет существование и доступность всех файлов."
)
