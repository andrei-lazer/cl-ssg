(in-package cl-ssg)

(defun passthrough-copy (rel-path)
  "copies file or directory from *input-root* to *output-root*"
  (uiop:run-program (list "cp" "-r" 
                          (namestring (merge-pathnames rel-path *input-root*)) 
                          (namestring (merge-pathnames rel-path *output-root*)))))
