(require :asdf)
(load "~/quicklisp/setup.lisp")
(push #p"./" asdf:*central-registry*)
(ql:quickload :cl-ssg)


(load "test-dir/layout.lisp")

(in-package cl-ssg)

(let* ((*input-root* (utils:ensure-and-absolute #p"test-dir/src/"))
       (*output-root* (utils:ensure-and-absolute #p"test-dir/build/")))
  (process-input-dir))
  
