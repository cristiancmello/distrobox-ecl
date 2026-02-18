;; gtk4-window.lisp

(dolist (repo '("cl-cffi-glib" "cl-cffi-gdk-pixbuf" "cl-cffi-pango"
                "cl-cffi-cairo" "cl-cffi-graphene" "cl-cffi-gtk4"))
  (let ((base (merge-pathnames
                (make-pathname :directory (list :relative repo))
                #P"/opt/quicklisp/local-projects/")))
    (pushnew base asdf:*central-registry* :test #'equal)
    (dolist (sub (uiop:subdirectories base))
      (pushnew sub asdf:*central-registry* :test #'equal))))

(ql:quickload :cffi :silent t)
(ql:quickload :cl-cffi-glib :silent t)
(ql:quickload :cl-cffi-cairo :silent t)
(ql:quickload :cl-cffi-gdk-pixbuf :silent t)
(ql:quickload :cl-cffi-pango :silent t)
(ql:quickload :cl-cffi-graphene :silent t)
(cffi:load-foreign-library "libgtk-4.so.1")
(ql:quickload :cl-cffi-gtk4 :silent t)

(in-package :gtk)

(defun activate (app)
  (let ((window (make-instance 'gtk:application-window
                               :application app
                               :title "Janela ECL + GTK4"
                               :default-width 800
                               :default-height 600)))
    (setf (gtk:widget-visible window) t)))

(let ((app (make-instance 'gtk:application
                          :application-id "com.example.gtk4window"
                          :flags :default-flags)))
  (g:signal-connect app "activate" #'activate)
  (g:application-run app nil))
