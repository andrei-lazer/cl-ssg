# Instructions


```lisp
(in-package cl-ssg)

(ensure-directories-exist "build/")
(let* ((*output-root* (truename #p"build/"))
       (*input-root* (truename #p"test-dir/"))
```
