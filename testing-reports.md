# Solution

```sh
sudo pacman -Syyu
sudo pacman -S --needed base-devel
sudo pacman -S ecl
curl -O https://beta.quicklisp.org/quicklisp.lisp
ecl -load quicklisp.lisp
(quicklisp-quickstart:install)
(ql:add-to-init-file)
(ext:quit)
```

## Steps

ecl
$? = 127

sudo pacman -Syyu ecl
$? = 0

ecl
...
$? = 0

ecl --shell test-ql.lisp
$? = 1

curl -O https://beta.quicklisp.org/quicklisp.lisp
ecl -load quicklisp.lisp
(quicklisp-quickstart:install)
;;; (EXT:RUN-PROGRAM "gcc" ("-I." "-I/usr/include/" "-D_GNU_SOURCE" "-D_FILE_OFFSET_BITS=64" "-march=x86-64" "-mtune=generic" "-O2" "-pipe" "-fno-plt" "-fexceptions" "-Wp,-D_FORTIFY_SOURCE=3" "-Wformat" "-Werror=format-security" "-fstack-clash-protection" "-fcf-protection" "-fno-omit-frame-pointer" "-mno-omit-leaf-frame-pointer" "-g" "-ffile-prefix-map=/build/ecl/src=/usr/src/debug/ecl" "-flto=auto" "-fcommon" "-ffat-lto-objects" "-fPIC" "-D_THREAD_SAFE" "-Dlinux" "-O2" "-c" "/var/home/cristian/Distroboxes/archlinux/home/.cache/common-lisp/ecl-24.5.10-unknown-linux-x64/var/home/cristian/Distroboxes/archlinux/home/quicklisp/quicklisp/package.c" "-o" "/var/home/cristian/Distroboxes/archlinux/home/.cache/common-lisp/ecl-24.5.10-unknown-linux-x64/var/home/cristian/Distroboxes/archlinux/home/quicklisp/quicklisp/package.o")):
;;; exec: No such file or directory
Condition of type: COMPILE-FILE-ERROR
COMPILE-FILE-ERROR while compiling #<cl-source-file "quicklisp" "package">

sudo pacman -S --needed base-devel

### Tive que recriar o container. Após isso foi feito

sudo pacman -Syyu
sudo pacman -S --needed base-devel
sudo pacman -S ecl rlwrap
curl -O https://beta.quicklisp.org/quicklisp.lisp
rlwrap ecl -load quicklisp.lisp
(quicklisp-quickstart:install) ;; se ocorrer falha e persistir "install ja feito", faça ecl -load ~/quicklisp/setup.lisp e continue
(ql:add-to-init-file)
(ext:quit)

ecl --shell test-ql.lisp 
;;; Loading #P"/var/home/cristian/Distroboxes/archlinux/home/quicklisp/setup.lisp"
;;; Loading #P"/usr/lib/ecl-24.5.10/asdf.fas"

=== Relatorio de Diagnostico ECL ===

[OK] Arquivo de configuracao: /var/home/cristian/Distroboxes/archlinux/home/.eclrc
[OK] Diretorio do Quicklisp: /var/home/cristian/Distroboxes/archlinux/home/quicklisp/
[OK] Pacote :QL carregado com sucesso.

---------------------------------------
RESULTADO: Tudo pronto para desenvolver!
