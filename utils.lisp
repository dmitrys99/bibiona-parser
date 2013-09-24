(in-package :bibiona-parser)

(defun cmd-line ()
  ;;#+BIBIONA-DEBUG '()
  ;;#+BIBIONA-DEBUG '("-f" "input.file" "-e" "CMD" "-" "001")
  #+BIBIONA-DEBUG '( "-e" "CMD-003")
  ;; #+CCL (rest ccl:*command-line-argument-list*)
  #-BIBIONA-DEBUG (rest sb-ext:*posix-argv*)
  )

(defun output (x)
  (write-sequence (tr x) *standard-output*))

(defun tr (x)
  #-BIBIONA-DEBUG (sb-ext:string-to-octets x :external-format :cp866)
  #+BIBIONA-DEBUG x)


(defun не-указано? (x) (if x x "не указано"))
