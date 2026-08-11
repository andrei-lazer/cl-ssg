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
