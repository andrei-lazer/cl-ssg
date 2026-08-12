"functions to do with preprocessing and compiling once the walker is done"
(in-package #:cl-ssg)


(defparameter *input-root* "./src/"
  "./src by default")

(defparameter *output-root* "./build/"
  "./build by default")


(defun resolve-permalink (permalink)
  (utils:ensure-and-absolute (merge-pathnames permalink *output-root*)))

(defun resolve-output-dir (target)
  (let* ((meta (getf target :meta))
         (permalink (gethash "permalink" meta))
         (in-path (getf target :filepath)))
        (if permalink
          (resolve-permalink permalink)
          (let* ((rel-path (uiop:enough-pathname in-path *input-root*))
                 (rel-out-path
                   (if (member (pathname-name rel-path) '("404" "index") :test #'equal)
                     (make-pathname :type "html" :defaults rel-path)
                     (format nil "~a/index.html" (make-pathname :type nil :defaults rel-path)))))
            (merge-pathnames rel-out-path *output-root*)))))

(defun resolve-link-prefix (out-path is-index)
  (merge-pathnames
    (uiop:enough-pathname
      (if is-index
        (uiop:pathname-directory-pathname out-path)
        (uiop:pathname-parent-directory-pathname out-path))
      *output-root*)
    (or markdown:*link-prefix* "/")))


;; any lisp files should return a string at the end
;; any other behaviour is not supported.
(defun render-lisp-text (body)
  (let ((out
         (with-input-from-string (stream body)
            (first (last (loop
                           for form = (read stream nil :eof)
                           until (eq form :eof)
                           collect (eval form)))))))
       out))
    

(defun body-to-html (body filetype)
  "converts various filetypes to html"
  (cond
    ((equal filetype "md") 
     (markdown:render-text body))
    ((equal filetype "lisp") 
     (render-lisp-text body))
    (t (format t "Filetype ~a is unsupported~%" filetype))))

(defun call-by-name (fn-name pkg-name &rest args)
  "given a `fn-name` and `pkg-name`, this calls `pkg-name:fn-name` with arguments `args`"
  (let ((fn-sym (find-symbol (string-upcase fn-name) (string-upcase pkg-name))))
    (apply fn-sym args)))

(defun apply-layout (layout-str &rest args)
  "given some string specifying a layout (extracted from yaml), it
  applies that layout to the html"
  (if layout-str
    (apply #'call-by-name layout-str "layouts" args)
    (getf args :html)))
  
(defun write-target (target)
  (let* ((html (getf target :html))
         (out-path (getf target :out-path)))
        (ensure-directories-exist out-path)
        (uiop:with-output-file (s out-path :if-exists :supersede)
                               (write-string html s))))
         
(defun process-target (target)
  "processes the target into an object that can be easily written to a file.
      - conversion to html
      - generates output path
      - sorts out layouts"
  (let* ((meta (getf target :meta))
         (filetype (getf target :filetype))
         (filepath (getf target :filepath))
         (permalink (gethash "permalink" meta))
         (out-path (resolve-output-dir target)) 
         (markdown:*link-prefix* (resolve-link-prefix 
                                    out-path (equal "index" (pathname-name filepath))))
         (body (getf target :body)))
         ;; link-prefix is set so that relative links are resolved properly
        (let* ((html-core (body-to-html body filetype))
               (layout-str (gethash "layout" meta))
               (html (apply-layout layout-str :html html-core :meta meta))
               ;; create the new target
               (new-target (list :html html :out-path out-path)))
          ; (format t "filepath: ~a, html: ~a~%" filepath html)
          ; (format t "html-core:~a~%" html-core)
          new-target)))

(defun process-input-dir ()
  (let* ((target-queue (collect-dir *input-root* '()))
         (processed-queue 
           (loop for target in target-queue
                 do
                 (write-target (process-target target)))))))
