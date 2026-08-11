(defpackage #:utils
  (:use #:cl)
  (:export #:split-lines
           #:split-frontmatter
           #:read-file-with-frontmatter
           #:ensure-and-absolute))

(in-package #:utils)

(defparameter +line-padding+ '(#\Space #\Tab #\Return)
  "trailing characters ignored when looking for a --- frontmatter delimiter. #\\Return is
   in here so that files with crlf line endings are handled the same as lf ones")

;; takes a relative file path, creates all directories leading to it, and
;; returns the absolute filepath
(defun ensure-and-absolute (rel-path)
  (ensure-directories-exist rel-path)
  (uiop:ensure-pathname rel-path :defaults (uiop:getcwd) :ensure-absolute t :ensure-physical t))

(defun split-lines (text)
  ;; splitting on #\Newline alone leaves a trailing #\Return on every line of a
  ;; crlf file, so it is stripped here rather than left to leak into the yaml
  ;; and the body
  (mapcar (lambda (line) (string-right-trim '(#\Return) line))
          (uiop:split-string text :separator '(#\Newline))))

;;splits yaml frontmatter from file
(defun split-frontmatter (text)
  ;; splits into lines
  (let ((lines (split-lines text)))
    ;; checks if first line starts with a --- 
    (if (string= (string-right-trim +line-padding+ (first lines)) "---")
      ;; end is the line number of the next --- (the end of the front matter)
      ;; the test function ignores whitespace on the right
        (let* ((test-f (lambda (a b) (string= a (string-right-trim +line-padding+ b))))
               (end (position "---" (rest lines) :test test-f)))
          (if end
              (values (format nil "~{~a~^~%~}" (subseq (rest lines) 0 end))
                      (format nil "~{~a~^~%~}" (nthcdr (+ end 2) lines)))
              (values nil text)))
        (values nil text))))

(defun read-file-with-frontmatter (file)
  "reads a file and splits it into YAML frontmatter and body. doesn't matter
  what the filetype of the file is."
  (multiple-value-bind (yaml body) (split-frontmatter (uiop:read-file-string file))
    (values (if (and yaml (not (zerop (length yaml)))) (cl-yy:yaml-simple-load yaml) (make-hash-table :test 'equal))
            body)))
