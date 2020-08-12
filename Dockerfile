FROM alpine:3.11

RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    apk update && \
    apk add \
            augeas \
            bash \
            build-base \
            ca-certificates \
            git \
            linux-headers \
            musl \
            openssh \
            postgresql-dev \
            python3 \
            python3-dev \
            rssh \
            rsync \
            shadow \
            && \
    deluser $(getent passwd 33 | cut -d: -f1) && \
    delgroup $(getent group 33 | cut -d: -f1) 2>/dev/null || true && \
    mkdir -p ~root/.ssh /etc/authorized_keys && chmod 700 ~root/.ssh/ && \
    augtool 'set /files/etc/ssh/sshd_config/AuthorizedKeysFile ".ssh/authorized_keys /etc/authorized_keys/%u"' && \
    echo -e "Port 22\n" >> /etc/ssh/sshd_config && \
    cp -a /etc/ssh /etc/ssh.cache && \
    pip3 install --no-cache-dir --upgrade --force-reinstall pip \
    rm -rf /var/cache/apk/*

RUN pip3 install --no-cache-dir virtualenv

EXPOSE 22

COPY entry.sh /entry.sh

ENTRYPOINT ["/entry.sh"]

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]
