"functions to do with preprocessing and compiling once the walker is done"
(in-package #:cl-ssg)


(defparameter *input-root* "./src"
  "./src by default")

(defparameter *output-root* "./build"
  "./build by default")


(defun resolve-permalink (permalink)
  (utils:ensure-and-absolute (merge-pathnames permalink *output-root*)))

(defun resolve-output-dir (target)
  (let* ((meta (getf target :meta))
         (permalink (gethash "permalink" meta))
         (in-path (getf target :filepath)))
        (make-pathname :type "html" 
                       :defaults 
                       (if permalink
                         (resolve-permalink permalink)
                         (merge-pathnames (uiop:enough-pathname in-path *input-root*) *output-root*)))))

(defun body-to-html (body filetype)
  "converts various filetypes to html"
  (cond
    ((equal filetype "md") 
     (let ((html (markdown:render-text body)))
       html))))

(defun call-by-name (fn-name pkg-name &rest args)
  "given a `fn-name` and `pkg-name`, this calls `pkg-name:fn-name` with arguments `args`"
  (let ((fn-sym (find-symbol (string-upcase fn-name) (string-upcase pkg-name))))
    (apply fn-sym args)))

(defun apply-layout (html layout-str &rest args)
  "given some string specifying a layout (extracted from yaml), it
  applies that layout to the html"
  (if layout-str
    (call-by-name layout-str "layouts" html (car args))
    html))
  
(defun write-target (target)
  (let* ((html (getf target :html))
         (out-path (getf target :out-path)))
        (ensure-directories-exist out-path)
        (uiop:with-output-file (s out-path :if-exists :supersede)
                               (format s html))))
         
                                
         
     

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
         (body (getf target :body))
         (html-core (body-to-html body filetype))
         (layout-str (gethash "layout" meta))
         (html (apply-layout html-core layout-str meta))
         ;; create the new target
         (new-target (list :html html :out-path out-path)))
        new-target))

(defun process-input-dir ()
  (let* ((target-queue (collect-dir *input-root* '()))
         (processed-queue 
           (loop for target in target-queue
                 do
                 (write-target (process-target target)))))))
