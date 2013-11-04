(in-package :bibiona-parser)

(defun cmd-line ()
  ;; #+BIBIONA-DEBUG '()
  #+BIBIONA-DEBUG '("-f" "C:/Work/Emacs/home/юбка.fabric")
  ;; #+BIBIONA-DEBUG '( "-e" "CMD-003")
  #-BIBIONA-DEBUG (rest sb-ext:*posix-argv*)
  )

(defun output (x)
  (write-sequence (tr x) *standard-output*))

(defun tr (x)
  #-BIBIONA-DEBUG (if x (sb-ext:string-to-octets x :external-format :cp866))
  #+BIBIONA-DEBUG x)

(defun не-указано? (x) 
  (if x x "не указано"))

