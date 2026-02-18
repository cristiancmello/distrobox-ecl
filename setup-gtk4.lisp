;; setup-gtk4.lisp
;; Apenas registra e compila cl-cffi-gtk4 — sem inicializar GTK

(dolist (repo '("cl-cffi-glib"
                "cl-cffi-gdk-pixbuf"
                "cl-cffi-pango"
                "cl-cffi-cairo"
                "cl-cffi-graphene"
                "cl-cffi-gtk4"))
  (let ((base (merge-pathnames
                (make-pathname :directory (list :relative repo))
                #P"/opt/quicklisp/local-projects/")))
    (pushnew base asdf:*central-registry* :test #'equal)
    (dolist (sub (uiop:subdirectories base))
      (pushnew sub asdf:*central-registry* :test #'equal))))

(ql:quickload :alexandria)

;; Carrega apenas a definição dos sistemas, sem inicializar display
;; cl-cffi-gtk4-init é o subsistema que registra os bindings sem abrir GTK
(ql:quickload :cl-cffi-gtk4-init)

(ext:quit)
