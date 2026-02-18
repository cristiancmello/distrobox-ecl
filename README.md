# distrobox-ecl

Ambiente Distrobox com Arch Linux para desenvolvimento em Common Lisp / ECL com suporte a GTK4, Wayland, Mesa e NVIDIA.

## Dependências

- [Distrobox](https://distrobox.it/)
- [Podman](https://podman.io/)

## Build e execução

```sh
podman build -t distrobox-ecl .
distrobox stop distrobox-ecl --yes ; distrobox rm distrobox-ecl --yes
distrobox create -n distrobox-ecl \
    --image distrobox-ecl \
    --home ~/Distroboxes/archlinux/home \
    --nvidia \
    --additional-flags "--env WAYLAND_DISPLAY=$WAYLAND_DISPLAY --env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/run/user/1000/wayland-0"
```

## Rodando a janela GTK4

```sh
ecl --shell gtk4-window.lisp
```

## Estrutura dos arquivos

| Arquivo | Descrição |
|---|---|
| `Dockerfile` | Imagem base com ECL, Quicklisp e cl-cffi-gtk4 |
| `gtk4-window.lisp` | Janela vazia GTK4 de exemplo |
| `setup-gtk4.lisp` | Script de build: registra e pré-compila cl-cffi-gtk4 |
| `test-full-env.lisp` | Teste de sanidade do ambiente ECL + Quicklisp |

## Notas técnicas

### Por que cl-cffi-gtk4 e não cl-gtk4?

`cl-gtk4` usa GObject Introspection, que gera e compila código C em tempo de build — tornando o `podman build` extremamente lento. O `cl-cffi-gtk4` usa bindings estáticos escritos em Lisp puro via CFFI, sem compilação C.

### Dependências do cl-cffi-gtk4

O `cl-cffi-gtk4` é dividido em 5 repositórios separados que precisam ser clonados manualmente como `local-projects` do Quicklisp:

- [`cl-cffi-glib`](https://github.com/crategus/cl-cffi-glib)
- [`cl-cffi-gdk-pixbuf`](https://github.com/crategus/cl-cffi-gdk-pixbuf)
- [`cl-cffi-pango`](https://github.com/crategus/cl-cffi-pango)
- [`cl-cffi-cairo`](https://github.com/crategus/cl-cffi-cairo)
- [`cl-cffi-graphene`](https://github.com/crategus/cl-cffi-graphene)

### Ordem de carregamento

Os sistemas precisam ser carregados em ordem explícita — o `ql:quickload :cl-cffi-gtk4` direto falha porque o Quicklisp não resolve a ordem correta entre repositórios locais:

```lisp
(ql:quickload :cffi)
(ql:quickload :cl-cffi-glib)
(ql:quickload :cl-cffi-cairo)
(ql:quickload :cl-cffi-gdk-pixbuf)
(ql:quickload :cl-cffi-pango)
(ql:quickload :cl-cffi-graphene)
(cffi:load-foreign-library "libgtk-4.so.1") ; deve ser carregada antes do cl-cffi-gtk4
(ql:quickload :cl-cffi-gtk4)
```

### Registro dos subdiretórios no ASDF

O Quicklisp só escaneia um nível de `local-projects`. Os subsistemas dos repositórios cl-cffi-* ficam em subdiretórios com `.asd` próprios, então é necessário registrá-los manualmente:

```lisp
(dolist (repo '("cl-cffi-glib" "cl-cffi-gdk-pixbuf" "cl-cffi-pango"
                "cl-cffi-cairo" "cl-cffi-graphene" "cl-cffi-gtk4"))
  (let ((base (merge-pathnames
                (make-pathname :directory (list :relative repo))
                #P"/opt/quicklisp/local-projects/")))
    (pushnew base asdf:*central-registry* :test #'equal)
    (dolist (sub (uiop:subdirectories base))
      (pushnew sub asdf:*central-registry* :test #'equal))))
```

### libgtk-4.so.1 precisa ser carregada manualmente

Sem o `cffi:load-foreign-library` explícito antes do `ql:quickload :cl-cffi-gtk4`, o processo bloqueia tentando inicializar o display GTK durante o carregamento.

### Símbolos corretos no GTK 4.10+

| Errado | Correto |
|---|---|
| `(gtk:widget-show window)` | `(setf (gtk:widget-visible window) t)` |
| `gio:+application-flags-none+` | `:default-flags` |
| `:none` (flags) | `:default-flags` |
