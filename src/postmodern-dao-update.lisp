(uiop:define-package :postmodern-dao-update
    (:use :cl :postmodern)
  (:nicknames :pdu)
  (:import-from :alexandria
                #:assoc-value)
  (:export
   #:get-constraints
   #:dao-alter-table))
(in-package :postmodern-dao-update)

;; blah blah blah.
(defun table-columns (schema table)
  (query (:select :column-name :from :information_schema.columns
                  :where (:and (:= :table-schema schema)
                               (:= :table_name   table))) :column))

(defun find-dao-class (class-name)
  (let ((class (find-class class-name)))
    (unless (postmodern::class-finalized-p class)
                 #+postmodern-thread-safe
                 (unless (postmodern::class-finalized-p class)
                   (bt:with-lock-held (postmodern::*class-finalize-lock*)
                     (unless (postmodern::class-finalized-p class)
                       (postmodern::finalize-inheritance class))))
                 #-postmodern-thread-safe
                 (finalize-inheritance class))
    class))

(defmethod dao-alter-table (table-class-name &optional dry-run)
  (let* ((table-class (find-dao-class table-class-name))
	 (table (dao-table-name table-class))
	 (class-columns (mapcar (lambda (slot)
                                  (cons (postmodern::sql-escape (postmodern::slot-definition-name slot)) slot))
                                (postmodern::dao-column-slots table-class)))
         (table-columns   (table-columns (get-search-path) (sql-escape table))))

    (let ((add-slots    (set-difference (mapcar 'first class-columns) table-columns :test 'equal))
	  (remove-slots (set-difference table-columns (mapcar 'first class-columns) :test 'equal)))

      (loop for column in add-slots
            for col = (assoc-value class-columns column :test 'equal)
            for name = (postmodern::slot-definition-name col)
            for type = (postmodern::column-type col)
            for sql = (sql-compile `(:alter-table ,table :add-column ,name :type ,type))
            do (print sql)
            unless dry-run
              do (query sql))

      (loop for column in remove-slots
            for sql = (sql-compile `(:alter-table ,table :drop-column ,column))
            do  (print sql)
            unless dry-run
              do (query sql)))))

;; TODO update constraints

;; Constraints
;; Values in CONTYPE
;; c = check constraint,
;; f = foreign key constraint,
;; p = primary key constraint,
;; u = unique constraint,
;; t = constraint trigger,
;; x = exclusion constraint
;; See more in:
;; https://www.postgresql.org/docs/9.0/catalog-pg-constraint.html

(defun get-constraints (schema table-name)
  (with-schema ("pg_catalog")
   (query (:select :con.*
            :FROM (:as :pg_constraint :con)
            :inner-join (:as :pg_class :rel)
            :ON (:= :rel.oid :con.conrelid)
            :inner-join (:as :pg_namespace :nsp)
            :ON (:= :nsp.oid :connamespace)
            :WHERE (:and
                    (:= :nsp.nspname schema)
                    (:= :rel.relname table-name))) :alists)))
