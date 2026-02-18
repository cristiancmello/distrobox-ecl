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
    && pacman -Scc --noconfirm

ENV ASDF_OUTPUT_TRANSLATIONS="/:/opt/quicklisp/cache/:"
ENV ECLRC=/etc/eclrc
ENV XDG_RUNTIME_DIR=/run/user/1000
ENV WAYLAND_DISPLAY=wayland-0
ENV QT_QPA_PLATFORM=wayland
ENV _JAVA_AWT_WM_NONREPARENTING=1

RUN curl -O https://beta.quicklisp.org/quicklisp.lisp && \
    ecl --load quicklisp.lisp \
        --eval '(quicklisp-quickstart:install :path "/opt/quicklisp/")' \
        --eval '(ext:quit)' && \
    rm quicklisp.lisp

RUN mkdir -p /opt/quicklisp/cache && \
    chmod -R 777 /opt/quicklisp/

RUN echo '#!/bin/bash' > /usr/local/bin/ecl-ql && \
    echo 'export ASDF_OUTPUT_TRANSLATIONS="/:/opt/quicklisp/cache/:"' >> /usr/local/bin/ecl-ql && \
    echo 'exec rlwrap ecl --load /opt/quicklisp/setup.lisp "$@"' >> /usr/local/bin/ecl-ql && \
    chmod +x /usr/local/bin/ecl-ql

RUN echo "alias ecl='/usr/local/bin/ecl-ql'" >> /etc/bash.bashrc && \
    echo '(load "/opt/quicklisp/setup.lisp")' | tee /etc/eclrc > /etc/skel/.eclrc

ENV LD_LIBRARY_PATH=/usr/lib/nvidia:/usr/lib:$LD_LIBRARY_PATH


COPY test-full-env.lisp /usr/local/share/test-full-env.lisp

RUN /usr/local/bin/ecl-ql --eval '(ql:quickload "alexandria")' --eval '(ext:quit)'
RUN /usr/local/bin/ecl-ql --shell /usr/local/share/test-full-env.lisp

CMD ["/usr/bin/bash"]
