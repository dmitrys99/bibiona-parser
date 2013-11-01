(in-package :bibiona-parser)

(defun generate (lst)
  (eval lst))

(defparameter *output-stream* nil)

(defun :ТОЧКА (&rest rest)
  (declare (ignore rest))
  (format nil "ТОЧКА;"))

(defun :ОТРЕЗОК (&rest rest)
  (declare (ignore rest))
  (format nil "ОТРЕЗОК;"))

(defun :КРИВАЯ (&rest rest)
  (declare (ignore rest))
  (format nil "КРИВАЯ;"))

(defun :ИЗДЕЛИЕ (&rest rest)
  (let* ((op (getf rest :ОПЕРАТОРЫ))
         (res (mapcar 'eval op)))
    (format nil "begin ~{~A~} end." res)))

(defun :СТАРТ (value)
  (format *output-stream* value) t)

(defmacro with-output-to-fabricx (filename &body body)
  `(with-open-file (s ,filename 
                      :if-exists :supersede 
                      :if-does-not-exist :create 
                      :external-format :UTF-8
                      :direction :output) 
     (let ((*output-stream* s))
       ,@body)))
