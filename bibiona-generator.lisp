(in-package :bibiona-parser)

(defun generate (lst)
  (eval lst))

(defparameter *output-stream* nil)

(defun :ИМЯ-ТОЧКИ (имя позиция)
  (put-point имя позиция))

(defun :ТОЧКА (&rest rest)
  (let* ((point (put-point (first rest) (second rest)))
         (where (second rest))
         (is-defined (equal (third point) :ОПРЕДЕЛЕНА))
         (declared (fourth point)))
    (if is-defined
        (let ((lc1 (get-lc-from-pos *parsed-text* where))
              (lc2 (get-lc-from-pos *parsed-text* declared)))
          (error-bibiona :SEM-001 
                         *parsed-file* 
                         (first lc1)
                         (second lc1)
                         (first point)
                         (first lc2)
                         (second lc2))) 
        (format nil "ТОЧКА ~A;" (first point)))))

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
