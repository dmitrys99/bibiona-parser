(in-package :bibiona-parser)

(defun generate-dot (op) "ТОЧКА;
")
(defun generate-line (op) "ОТРЕЗОК;
")
(defun generate-fabric (ops)
  (format nil 
          "~{~A~}" 
          (mapcar #'(lambda (x) 
                      (let ((type (first x)))
                        ;; (break "type: ~A" (eql type :ТОЧКА))
                        (cond ((eql type :ТОЧКА) (generate-dot x))
                              ((eql type :ОТРЕЗОК) (generate-line x))
                              (t "none")))) (second ops))
          ))

(defun generate-all (lst)
  (eval lst)

  (format nil "begin
~A
end." 
  (generate-fabric lst)))

(defparameter *output-stream* nil)

(defun :ТОЧКА (&rest rest)
  (declare (ignore rest))
  (format *output-stream* "ТОЧКА;"))

(defun :ОТРЕЗОК (&rest rest)
  (declare (ignore rest))
  (format *output-stream* "ОТРЕЗОК;"))

(defun :КРИВАЯ (&rest rest)
  (declare (ignore rest))
  (format *output-stream* "КРИВАЯ;"))

(defun :ИЗДЕЛИЕ (&rest rest)
  (let* ((op (getf rest :ОПЕРАТОРЫ))
         (res (mapcar 'eval op)))
    (format *output-stream* "begin ~{~A~} end." res)))
