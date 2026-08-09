(defpackage #:markdown
  (:use #:cl)
  (:export #:render-text))

(in-package #:markdown)

(defparameter *md-link-prefix* nil
  "prefix put in front of relative links, for example \"/cards/\". when nil, links are
   left exactly as they are written")

(defparameter *md-link-dir* nil
  "directory of the file being rendered, relative to its source root. relative links are
   resolved against it before *link-prefix* is added")

;; turns a link as written in the source (say "../assets/diagram.png" inside git/rebasing.md)
;; into one that works from the site root (say "/cards/assets/diagram.png")
(defun resolve-link (url)
  (if (or (null *link-prefix*) (external-link-p url))
      url
      ;; a link can end in an anchor, which is not part of the file name
      (let* ((hash (position #\# url))
             (anchor (if hash (subseq url hash) ""))
             (path (merge-pathnames (if hash (subseq url 0 hash) url)
                                    (or *link-dir* #p"")))
             ;; notes link to each other by file name, but they are published as html
             (path (if (equal (pathname-type path) "md")
                       (make-pathname :type "html" :defaults path)
                       path))
             (path (make-pathname :directory (pathname-directory path)
                                  :defaults path)))
            (format nil "~a~a~a" *link-prefix* (namestring path) anchor))))

(defparameter *meta* (make-hash-table :test #'equal)
  "hash table that stores information that all rendering functions should see.
  saves passing around a bunch of data. should only ever be set locally.")

(defun render-text (text)
  "renders a markdown string into a html fragment"
  (let ((3bmd:*smart-quotes* t)
        ;; notes link to each other's sections, for example http.md#url
        (3bmd:*generate-header-ids* t)
        (3bmd-code-blocks:*code-blocks* t)
        (3bmd-tables:*tables* t)
        (3bmd-math:*math* t)
        (3bmd-wiki:*wiki-links* t)
        (3bmd-wiki:*wiki-processor* :cards))
    (with-output-to-string (out)
      (3bmd:parse-string-and-print-to-stream text out))))
