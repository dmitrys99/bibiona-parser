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
  (format nil "begin
~A
end." 
  (generate-fabric lst)))
