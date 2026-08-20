(in-package #:cl-ssg/tests)

(def-suite cl-ssg-suite :description "cl-ssg testing suite")

(in-suite cl-ssg-suite)

(defun run-tests ()
  (run! 'cl-ssg-suite))
