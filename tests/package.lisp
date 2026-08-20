(defpackage #:cl-ssg/tests
  (:use #:cl #:fiveam)
  (:import-from #:cl-ssg
                #:collect-dir
                #:merge-meta
                #:print-hash-table
                #:process-input-dir
                #:passthrough-copy
                #:resolve-output-dir
                #:*input-root*
                #:*output-root*)
  (:import-from #:utils
                #:split-frontmatter
                #:read-file-with-frontmatter)
  (:export #:run-tests
           #:cl-ssg-suite))
(in-package #:cl-ssg/tests)
