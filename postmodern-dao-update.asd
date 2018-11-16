#|
  This file is a part of postmodern-dao-update project.
|#

(defsystem "postmodern-dao-update"
  :version "0.1.0"
  :author "Knut Olav Bøhmer"
  :license "LGPL"
  :depends-on ("postmodern")
  :components ((:module "src"
                :components
                ((:file "postmodern-dao-update"))))
  :description "Update tables based on a dao class"
  :long-description
  #.(read-file-string
     (subpathname *load-pathname* "README.markdown"))
  :in-order-to ((test-op (test-op "postmodern-dao-update-test"))))
