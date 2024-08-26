FROM docker.io/alpine:3.15

ARG SEEDDMS_VERSION=6.0.28

RUN \
    # Update packages
    apk --no-cache upgrade && \
    # Install common packages
    apk --no-cache add libbz2 libgcc libressl libstdc++ libxml2 libxslt ncurses-libs pcre readline s6 xz-libs && \
    # Install PHP
    apk --no-cache add nginx php7 php7-ctype php7-curl php7-fileinfo php7-fpm php7-gd php7-iconv php7-intl php7-json php7-mbstring php7-mcrypt php7-opcache php7-openssl php7-pear php7-pdo_pgsql php7-session php7-simplexml php7-xml php7-xsl php7-zip && \
    # Install glibc-compiled iconv (see https://github.com/docker-library/php/issues/240)
    # Provides /usr/lib/preloadable_libiconv.so for LD_PRELOAD
    apk --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/v3.13/community/ add gnu-libiconv=1.15-r3 && \
    # Install other dependencies
    apk --no-cache add ghostscript imagemagick libreoffice-calc libreoffice-impress libreoffice-writer poppler-utils postgresql-client python3 ttf-opensans && \
    # Set time zone data
    apk --no-cache add tzdata && \
    cp /usr/share/zoneinfo/UTC /etc/localtime && \
    apk --no-cache del tzdata && \
    # Set python interpret
    ln -s /usr/bin/python3 /usr/bin/python && \
    # Install unoconv
    wget https://raw.githubusercontent.com/unoconv/unoconv/master/unoconv -O /usr/bin/unoconv && \
    chmod +x /usr/bin/unoconv && \
    # Cleanup
    rm -rf /etc/crontabs/root /etc/periodic

RUN \
    # Install SeedDMS
    wget https://sourceforge.net/projects/seeddms/files/seeddms-${SEEDDMS_VERSION}/seeddms-quickstart-${SEEDDMS_VERSION}.tar.gz/download -O - | tar xzf - -C /srv && \
    mv /srv/seeddms* /srv/seeddms && \
    rm -rf /srv/seeddms/www/install /srv/seeddms/www/ext/example && \
    # Create OS user
    addgroup -S -g 8080 seeddms && \
    adduser -S -u 8080 -h /srv/seeddms -s /bin/false -g seeddms -G seeddms seeddms && \
    chown -R seeddms:seeddms /srv/seeddms

COPY --chown=seeddms:seeddms image.d/srv/seeddms/ /srv/seeddms/
COPY image.d/etc/ /etc/
COPY image.d/entrypoint.sh /

VOLUME ["/srv/seeddms/conf", "/srv/seeddms/data"]
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
