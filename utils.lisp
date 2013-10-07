(in-package :bibiona-parser)

(defun cmd-line ()
  #+BIBIONA-DEBUG '()
  ;; #+BIBIONA-DEBUG '("-f" "C:/Work/Emacs/home/юбка.fabric")
  ;; #+BIBIONA-DEBUG '( "-e" "CMD-003")
  ;; #+CCL (rest ccl:*command-line-argument-list*)
  #-BIBIONA-DEBUG (rest sb-ext:*posix-argv*)
  )

(defun output (x)
  (write-sequence (tr x) *standard-output*))

(defun tr (x)
  #-BIBIONA-DEBUG (sb-ext:string-to-octets x :external-format :cp866)
  #+BIBIONA-DEBUG x)

(defun не-указано? (x) 
  (if x x "не указано"))



(defun str-to-fs (string)
  "Функция преобразовывает имя файла в вид, пригодный для использования в файловой системе."
  (let ((v (make-array (+ 5 (length string)) 
                       :element-type 'base-char
                       :adjustable t
                       :fill-pointer 0)))
    (with-open-stream (s (make-string-output-stream :element-type 'base-char))
      (loop
        for c across  string
        do (write-char c s)
           (let ((d (array-dimension v 0)))
             (when (< (- d (fill-pointer v)) 5)
               (adjust-array v (* 2 d)))))
      s)
    ))
