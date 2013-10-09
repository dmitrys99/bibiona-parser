(in-package :bibiona-parser)

;; Модуль содержит небольшние изменения в отдельных библиотечных
;; модулях, чтобы не вносить изменения в сами модули.

;;; ZIP
(defparameter zip::*default-external-format* :utf-8)

(defun zip::default-external-format ()
  zip::*default-external-format*)

(defun call-fixups ()
  (setf zip::*default-external-format* :ibm866))
