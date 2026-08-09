(require :asdf)
(load "~/quicklisp/setup.lisp")
(push #p"./" asdf:*central-registry*)
(ql:quickload :cl-ssg)


(in-package cl-ssg)

(defvar *meta-big*
  (let ((tbl (make-hash-table :test 'equal)))
    (setf (gethash "title" tbl) "big")
    (setf (gethash "tags" tbl) (list "maths" "computing"))
    tbl))

(defvar *meta-small*
  (let ((tbl (make-hash-table :test 'equal)))
    (setf (gethash "title" tbl) "small")
    (setf (gethash "tags" tbl) (list "maths" "finance"))
    (setf (gethash "mathjax" tbl) nil)
    tbl))

(add-dir-to-job-queue "test-dir/" nil)

(let ((queue nil))
  (walk "test-dir/" (lambda (dir) (add-dir-to-job-queue dir queue)))
  (format t "QUEUE:~%~a~%" queue))
