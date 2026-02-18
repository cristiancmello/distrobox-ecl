;; test-full-env.lisp
(unless (find-package :ql)
  (load "~/quicklisp/setup.lisp"))

(format t "Iniciando teste do ambiente...~%")

(ql:quickload "alexandria")

(format t "Testando Alexandria: ~A~%" 
  (alexandria:flatten '((1 2) (3 4))))

(format t "Ambiente verificado com sucesso!~%")
(ext:quit)
