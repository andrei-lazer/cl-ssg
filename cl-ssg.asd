(asdf:defsystem
  "cl-ssg"
  :depends-on ("3bmd"
               "3bmd-ext-wiki-links"
               "3bmd-ext-code-blocks"
               "3bmd-ext-math"
               "3bmd-ext-tables"
               "cl-yaclyaml"
               "spinneret"
               "alexandria")
               ; "bordeaux-threads"
               ; "ironclad"
               ; "cl-store")
  :serial t
  :components ((:module "src"
                :serial t
                :components ((:file "package")
                             (:file "utils")
                             (:file "markdown")
                             (:file "walk")
                             (:file "compile")
                             (:file "extra"))))

  :in-order-to ((asdf:test-op (asdf:test-op "cl-ssg/tests"))))

(asdf:defsystem
  "cl-ssg/tests"
  :depends-on ("cl-ssg"
               "fiveam")
  :serial t
  :components ((:module "tests"
                :serial t
                :components ((:file "package")
                             (:file "suite")
                             (:file "frontmatter")
                             (:file "output-path"))))

  :perform (asdf:test-op (op c) (uiop:symbol-call "CL-SSG/TESTS" "RUN-TESTS")))
