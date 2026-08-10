(defpackage #:markdown
  (:use #:cl)
  (:export #:render-text
           #:*link-prefix*
           #:*link-dir*))

(in-package #:markdown)

(defparameter *link-prefix* nil
  "prefix put in front of relative links, for example \"/cards/\". when nil, links are
   left exactly as they are written")

(defparameter *link-dir* nil
  "directory of the file being rendered, relative to its source root. relative links are
   resolved against it before *link-prefix* is added")

(defun external-link-p (url)
  (or (zerop (length url))
      (find (char url 0) "/#")
      (search "://" url)
      (uiop:string-prefix-p "mailto:" url)))

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
             ;; notes link to each other by file name, but they are published as html.
             (path (if (equal (pathname-type path) "md")
                       (make-pathname :type nil :defaults path)
                       path))
             (dir (pathname-directory path))
             (path (make-pathname :directory dir
                                  :defaults path))
             (output (format nil "~a~a~a" *link-prefix* (namestring path) anchor)))
            ; (format t "input url: ~a~%" url)
            ; (format t "dir: ~a~%" dir)
            ; (format t "output: ~a~%" output)
            output)))

;; 3bmd configurations to allow for recolving links and stuff. AI generated
;; because 3bmd has no docs.

;; 3bmd renders a parse tree by dispatching on each element's tag, so relative links only
;; need fixing up in the two places that emit a url
(defmethod 3bmd-ext:print-tagged-element :around ((tag (eql :explicit-link)) stream rest)
  (let ((rest (copy-list rest)))
    (setf (getf rest :source) (resolve-link (getf rest :source)))
    (call-next-method tag stream rest)))

(defmethod 3bmd-ext:print-tagged-element :around ((tag (eql :image)) stream rest)
  ;; images arrive wrapped in an extra list, unlike every other tag
  (let ((inner (copy-list (cdr (first rest)))))
    (setf (getf inner :source) (resolve-link (getf inner :source)))
    (call-next-method tag stream (list (cons (car (first rest)) inner)))))

;; [[wiki links]] name another note in the same collection
(defmethod 3bmd-wiki:process-wiki-link ((wiki (eql :cards)) target formatted args stream)
  (declare (ignore args))
  (format stream "<a href=\"~a\">~a</a>"
          (resolve-link (format nil "~a.md" target))
          formatted))

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
