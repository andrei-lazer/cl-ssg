(in-package #:cl-ssg/tests)

(def-suite output-path-suite
  :description "tests for resolve-output-dir"
  :in cl-ssg-suite)

(in-suite output-path-suite)

(defun make-meta (&rest kvs)
  (let ((h (make-hash-table :test 'equal)))
    (loop for (k v) on kvs by #'cddr do (setf (gethash k h) v))
    h))

(defun make-target (filepath &optional meta)
  (list :filepath filepath :meta (or meta (make-meta))))

(defun make-temp-dir ()
  (let ((path (merge-pathnames
               (format nil "cl-ssg-test-~a-~a/" (get-universal-time) (random 1000000))
               (uiop:temporary-directory))))
    (ensure-directories-exist path)
    path))

(defmacro with-temp-dir ((var) &body body)
  `(let ((,var (make-temp-dir)))
     (unwind-protect (progn ,@body)
       (uiop:delete-directory-tree ,var :validate t :if-does-not-exist :ignore))))

(test resolve-output-dir-with-permalink
  (with-temp-dir (output-root)
    (let* ((*output-root* output-root)
           (target (make-target "/tmp/whatever/page.md"
                                 (make-meta "permalink" "custom/page/index.html"))))
      (is (string= (namestring (resolve-output-dir target))
                   (namestring (merge-pathnames "custom/page/index.html" output-root)))))))

(test resolve-output-dir-without-permalink
  (let* ((*input-root* #P"/tmp/ssg-in/")
         (*output-root* #P"/tmp/ssg-out/")
         (target (make-target (merge-pathnames "about.md" *input-root*))))
    (is (string= (namestring (resolve-output-dir target))
                 (namestring (merge-pathnames "about/index.html" *output-root*))))))

(test resolve-output-dir-index-at-root
  (let* ((*input-root* #P"/tmp/ssg-in/")
         (*output-root* #P"/tmp/ssg-out/")
         (target (make-target (merge-pathnames "index.md" *input-root*))))
    (is (string= (namestring (resolve-output-dir target))
                 (namestring (merge-pathnames "index.html" *output-root*))))))

(test resolve-output-dir-404-at-root
  (let* ((*input-root* #P"/tmp/ssg-in/")
         (*output-root* #P"/tmp/ssg-out/")
         (target (make-target (merge-pathnames "404.md" *input-root*))))
    (is (string= (namestring (resolve-output-dir target))
                 (namestring (merge-pathnames "404.html" *output-root*))))))

(test resolve-output-dir-subdir-index
  (let* ((*input-root* #P"/tmp/ssg-in/")
         (*output-root* #P"/tmp/ssg-out/")
         (target (make-target (merge-pathnames "posts/index.md" *input-root*))))
    (is (string= (namestring (resolve-output-dir target))
                 (namestring (merge-pathnames "posts/index.html" *output-root*))))))

(test resolve-output-dir-subdir-non-index
  (let* ((*input-root* #P"/tmp/ssg-in/")
         (*output-root* #P"/tmp/ssg-out/")
         (target (make-target (merge-pathnames "posts/first-post.md" *input-root*))))
    (is (string= (namestring (resolve-output-dir target))
                 (namestring (merge-pathnames "posts/first-post/index.html" *output-root*))))))
