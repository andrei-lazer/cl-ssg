(in-package #:cl-ssg)

;; recursively walk through directories and apply a function to each file
(defun walk (dir fn)
  (mapc fn (uiop:directory-files dir))
  (mapc (lambda (d) (walk d fn)) (uiop:subdirectories dir)))

(defun print-hash-table (table &optional (stream *standard-output*))
  (maphash (lambda (k v)
             (format stream "~s => ~s~%" k v))
           table))

(defun set-union (a b &optional (test 'equal))
  (append a (remove-if (lambda (x) (member x a :test test)) b)))

(defun merge-meta (big small)
  "merges two meta hash tables. any keys in small are added to big.
  if big and small have a clash, big wins, unless the clash is of list
  type, in which case they're concatenated together."
  (when small
    (loop for key being the hash-keys of small using (hash-value small-val) do
          (let ((big-val (gethash key big)))
            (if big-val
              (progn
              ;; if collision only modify big if both values are lists
                (when (and (listp big-val) (listp small-val))
                  (setf (gethash key big) (set-union small-val big-val))))
              ;; if no collision, add small's key-value pair to big
              (setf (gethash key big) small-val)))))
  big)

(defun compile-markdown (file meta)
  (format t "~&compiling markdown file ~a~%Meta:~%" file)
  (print-hash-table meta))
  
(defparameter *filetype-compiler-lookup* 
  (alexandria:plist-hash-table
    '("md" compile-markdown)
    :test #'equal))

(defparameter *config-file* "config.yaml")

;; in a directory, reads a config.yaml file and all headers
;; and adds these to the queue. queue is of the form (fn path body meta)
(defun add-dir-to-job-queue (dir queue)
  (let* ((yaml-path (merge-pathnames *config-file* dir)) ;; extract yaml from dir/config.yaml
         (*meta* (if (uiop:file-exists-p yaml-path)
                     (cl-yy:yaml-simple-load (uiop:read-file-string yaml-path)))))

    (dolist (file (uiop:directory-files dir))
      (when (not (equal (file-namestring file) *config-file*)) ;; already processed
        (multiple-value-bind (new-meta body) (utils:read-file-with-frontmatter file)
          (let* ((*meta* (merge-meta new-meta *meta*)) ;; merges with priority to the file's yaml
                 (filetype (pathname-type file))
                 (compile-fn (gethash filetype *filetype-compiler-lookup*))
                 (job `(,compile-fn ,file ,body ,*meta*)))

            (push job queue))))))
  (format t "QUEUE: ~a~%" queue)
  queue)
