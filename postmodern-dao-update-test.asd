#|
  This file is a part of postmodern-dao-update project.
|#

(defsystem "postmodern-dao-update-test"
  :defsystem-depends-on ("prove-asdf")
  :author ""
  :license ""
  :depends-on ("postmodern-dao-update"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "postmodern-dao-update"))))
  :description "Test system for postmodern-dao-update"

  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
