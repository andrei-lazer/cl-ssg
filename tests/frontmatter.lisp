(in-package #:cl-ssg/tests)

(def-suite frontmatter-suite
  :description "tests for split-frontmatter and read-file-with-frontmatter"
  :in cl-ssg-suite)

(in-suite frontmatter-suite)

(defun frontmatter-of-string (content)
  "writes CONTENT to a temporary file and reads it back with
  read-file-with-frontmatter, returning (values meta body)."
  (uiop:with-temporary-file (:stream s :pathname path :type "md" :keep nil)
    (write-string content s)
    :close-stream
    (read-file-with-frontmatter path)))

(test split-frontmatter-valid-yaml
  (multiple-value-bind (yaml body)
      (split-frontmatter (format nil "---~%title: Test~%layout: default~%---~%~%Body text"))
    (is (string= yaml (format nil "title: Test~%layout: default")))
    (is (string= body (format nil "~%Body text")))))

(test split-frontmatter-no-frontmatter
  (let ((text (format nil "# Heading~%~%Just content")))
    (multiple-value-bind (yaml body) (split-frontmatter text)
      (is (null yaml))
      (is (string= body text)))))

(test split-frontmatter-empty-frontmatter
  (multiple-value-bind (yaml body)
      (split-frontmatter (format nil "---~%---~%~%Body text"))
    (is (string= yaml ""))
    (is (string= body (format nil "~%Body text")))))

(test split-frontmatter-malformed-unterminated
  (let ((text (format nil "---~%title: no closing delimiter~%~%Body text")))
    (multiple-value-bind (yaml body) (split-frontmatter text)
      (is (null yaml))
      (is (string= body text)))))

(test read-file-with-frontmatter-various-keys
  (multiple-value-bind (meta body)
      (frontmatter-of-string
       (format nil "---~%title: Test Page~%layout: default~%permalink: /custom/path/~%publish: t~%---~%~%# Heading~%"))
    (is (string= (gethash "title" meta) "Test Page"))
    (is (string= (gethash "layout" meta) "default"))
    (is (string= (gethash "permalink" meta) "/custom/path/"))
    (is (string= (gethash "publish" meta) "t"))
    (is (string= body (format nil "~%# Heading~%")))))

(test read-file-with-frontmatter-list-values
  (multiple-value-bind (meta body)
      (frontmatter-of-string
       (format nil "---~%tags:~%  - lisp~%  - ssg~%---~%~%Body"))
    (is (equal (gethash "tags" meta) '("lisp" "ssg")))
    (is (string= body (format nil "~%Body")))))

(test read-file-with-frontmatter-no-frontmatter
  (multiple-value-bind (meta body)
      (frontmatter-of-string (format nil "# No Frontmatter~%~%Just plain content."))
    (is (zerop (hash-table-count meta)))
    (is (string= body (format nil "# No Frontmatter~%~%Just plain content.")))))

(test read-file-with-frontmatter-malformed-empty
  (multiple-value-bind (meta body)
      (frontmatter-of-string (format nil "---~%---~%~%Body text"))
    (is (zerop (hash-table-count meta)))
    (is (string= body (format nil "~%Body text")))))

(test frontmatter-inheritance-from-config
  "a file's own frontmatter and a directory-level config.yaml are both
  parsed into equal-test hash tables keyed by string, so keys from either
  source are available for later merging (see merge-meta)."
  (let ((config-meta (cl-yy:yaml-simple-load
                       (format nil "publish: t~%layout: base-layout~%"))))
    (multiple-value-bind (file-meta body)
        (frontmatter-of-string (format nil "---~%title: Test Page~%---~%~%Body"))
      (is (string= (gethash "layout" config-meta) "base-layout"))
      (is (string= (gethash "publish" config-meta) "t"))
      (is (string= (gethash "title" file-meta) "Test Page"))
      (is (null (gethash "layout" file-meta)))
      (is (string= body (format nil "~%Body"))))))
