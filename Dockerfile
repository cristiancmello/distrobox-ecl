FROM archlinux:latest

RUN pacman -Syyu --noconfirm && \
    pacman -S --needed --noconfirm \
    base-devel \
    ecl \
    rlwrap \
    ca-certificates \
    sudo \
    git \
    util-linux \
    nvidia-utils \
    mesa \
    gtk4 \
    glib2 \
    cairo \
    pango \
    gdk-pixbuf2 \
    graphene \
    && pacman -Scc --noconfirm

ENV ASDF_OUTPUT_TRANSLATIONS="/:/opt/quicklisp/cache/:"
ENV ECLRC=/etc/eclrc
ENV XDG_RUNTIME_DIR=/run/user/1000
ENV WAYLAND_DISPLAY=wayland-0
ENV QT_QPA_PLATFORM=wayland
ENV _JAVA_AWT_WM_NONREPARENTING=1
ENV GDK_BACKEND=wayland

RUN curl -O https://beta.quicklisp.org/quicklisp.lisp && \
    ecl --load quicklisp.lisp \
        --eval '(quicklisp-quickstart:install :path "/opt/quicklisp/")' \
        --eval '(ext:quit)' && \
    rm quicklisp.lisp

RUN echo '#!/bin/bash' > /usr/local/bin/ecl-ql && \
    echo 'export ASDF_OUTPUT_TRANSLATIONS="/:/opt/quicklisp/cache/:"' >> /usr/local/bin/ecl-ql && \
    echo 'exec rlwrap ecl --load /opt/quicklisp/setup.lisp "$@"' >> /usr/local/bin/ecl-ql && \
    chmod +x /usr/local/bin/ecl-ql

RUN echo "alias ecl='/usr/local/bin/ecl-ql'" >> /etc/bash.bashrc && \
    echo '(load "/opt/quicklisp/setup.lisp")' | tee /etc/eclrc > /etc/skel/.eclrc

ENV LD_LIBRARY_PATH=/usr/lib/nvidia:/usr/lib:$LD_LIBRARY_PATH

COPY test-full-env.lisp /usr/local/share/test-full-env.lisp
COPY gtk4-window.lisp /usr/local/share/gtk4-window.lisp
COPY setup-gtk4.lisp /usr/local/share/setup-gtk4.lisp

# Dependências completas do cl-cffi-gtk4 conforme README oficial:
# cl-cffi-glib, cl-cffi-gdk-pixbuf, cl-cffi-pango, cl-cffi-cairo, cl-cffi-graphene
RUN mkdir -p /opt/quicklisp/local-projects && \
    git clone --depth=1 https://github.com/crategus/cl-cffi-glib.git \
        /opt/quicklisp/local-projects/cl-cffi-glib && \
    git clone --depth=1 https://github.com/crategus/cl-cffi-gdk-pixbuf.git \
        /opt/quicklisp/local-projects/cl-cffi-gdk-pixbuf && \
    git clone --depth=1 https://github.com/crategus/cl-cffi-pango.git \
        /opt/quicklisp/local-projects/cl-cffi-pango && \
    git clone --depth=1 https://github.com/crategus/cl-cffi-cairo.git \
        /opt/quicklisp/local-projects/cl-cffi-cairo && \
    git clone --depth=1 https://github.com/crategus/cl-cffi-graphene.git \
        /opt/quicklisp/local-projects/cl-cffi-graphene && \
    git clone --depth=1 https://github.com/crategus/cl-cffi-gtk4.git \
        /opt/quicklisp/local-projects/cl-cffi-gtk4

RUN /usr/local/bin/ecl-ql --shell /usr/local/share/setup-gtk4.lisp

# Permissões abertas após compilação para uso no Distrobox
RUN chmod -R 777 /opt/quicklisp/

RUN /usr/local/bin/ecl-ql --shell /usr/local/share/test-full-env.lisp

CMD ["/usr/bin/bash"]
