(in-package :bibiona-parser)

(defparameter *points* (make-hash-table :test 'equalp))

; Когда точка первый раз появляется, она складывается в хеш
; Значением 

(defun put-point (name pos)  
  (let ((p (gethash name *points*)))
    (if (not p) 
        (progn
          (setf (gethash name *points*) pos)
          (list name pos :НОВАЯ))
        (list name pos :ОПРЕДЕЛЕНА p))))
