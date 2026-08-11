(in-package #:cl-ssg)

(defparameter *processable* '("md"))

(defparameter *config-file* "config.yaml"
  "if found, this file will set a preset for the metadata of all files in that directory.
  currently cannot be inherited by subdirectories")

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
  

;; meta is a special variable that keeps track of the current metadata.
;; very convenient for this, since subdirectories are able to inherit
;; their parent directory's metadata.
(defparameter *meta* (make-hash-table :test #'equal))

;; in a directory, reads a config.yaml file and all headers
;; and adds these to the queue. 
(defun walk-and-add-dirs-to-queue (dir queue)
  (let* ((yaml-path (merge-pathnames *config-file* dir)) ;; extract yaml from dir/config.yaml
         (new-meta (if (uiop:file-exists-p yaml-path)
                     (cl-yy:yaml-simple-load (uiop:read-file-string yaml-path))
                     (make-hash-table :test #'equal)))
         (*meta* (merge-meta new-meta *meta*)))

    (dolist (file (uiop:directory-files dir))
      (when (and (member (pathname-type file) *processable* :test #'equal)
                 (not (equal (file-namestring file) *config-file*))) ;; already processed
        (multiple-value-bind (new-meta body) (utils:read-file-with-frontmatter file)
          (let* ((*meta* (merge-meta new-meta *meta*)) ;; merges with priority to the file's yaml
                 (filetype (pathname-type file))
                 ;; important: targets are _always_ of this form
                 (target `(:filetype ,filetype :filepath ,file :body ,body :meta ,*meta*)))
            (when (gethash "publish" *meta*)
              (push target queue))))))
    (dolist (subdir (uiop:subdirectories dir))
      (setf queue (walk-and-add-dirs-to-queue subdir queue))))
    
  queue)


;; does add-flat-dir-to-queue recursively through all subdirectories.
(defun collect-dir (dir queue)
  (walk-and-add-dirs-to-queue dir queue))
