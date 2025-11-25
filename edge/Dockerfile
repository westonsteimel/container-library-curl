# The global build args need to all be prefixed with ARG for the update substitutions to work
ARG CURL_REPOSITORY="https://github.com/curl/curl"
ARG CURL_VERSION="edge"
ARG CURL_BRANCH="master"
ARG CURL_COMMIT="1e7d0bafc6d25d98ec72ff419df65fda3cf147a7"

FROM ghcr.io/westonsteimel/rustls-ffi:edge AS rustls-ffi 
FROM alpine:latest AS builder

ARG CURL_REPOSITORY \
    CURL_BRANCH \
    CURL_COMMIT

WORKDIR /build

COPY --from=rustls-ffi /usr/local/rustls-ffi/ /usr/local/
COPY package-metadata.spec /build/

RUN apk upgrade && apk add --no-cache \
        brotli-dev \
        brotli-static \
        ca-certificates-bundle \
	    c-ares-dev \
        g++ \
	    libidn2-dev \
        libidn2-static \
        libpsl-dev \
        libpsl-static \
        libunistring-dev \
        libunistring-static \
        make \
	    nghttp2-static \
	    openssl-libs-static \
	    openssl-dev \
        nghttp2-dev \
        perl \
        git \
        automake \
        autoconf \
        build-base \
        libtool \
        zlib-dev \
        zlib-static \
        zstd-dev \
        zstd-static 

RUN set -x \
    ldconfig /usr/local/ \
    && git clone --branch "${CURL_BRANCH}" "${CURL_REPOSITORY}" \
    && ( \
		cd curl \
        && git reset --hard "${CURL_COMMIT}" \
        && export ARCHITECTURE=$(arch) \
        && export CURL_DEV_VERSION=$(sed -n "s/^.*#define LIBCURL_VERSION\s\"\s*\(\S*\)\".*$/\1/p" include/curl/curlver.h) \
        && autoreconf -i \
    	&& LDFLAGS="-static" PKG_CONFIG="pkg-config --static" ./configure \
            --enable-ipv6 \
            --enable-unix-sockets \
            --enable-websockets \
            --enable-static \
            --with-brotli=/usr \
            --with-zstd=/usr \
            --with-zlib=/usr \
            --with-nghttp2=/usr \
            --with-libidn2=/usr \
            --with-libpsl=/usr \
            --with-ca-bundle=/etc/ssl/cert.pem \
            --with-pic \
            --with-rustls=/usr/local \
            --without-brotli \
            --without-openssl \
            --without-libssh2 \
            --disable-ldap \
            --disable-shared \
        && make -j4 V=1 LDFLAGS="-static -all-static -specs=/build/package-metadata.spec" \
    	&& make install \
        && ldd /usr/local/bin/curl && exit 1 || true \
	) \
    && strip /usr/local/bin/curl \
    && if [$TARGETPLATFORM = "linux/amd64"]; then apk add --no-cache upx && upx --lzma --best /usr/local/bin/curl; fi \
    && rm -r curl \
    && addgroup curl \
    && adduser -G curl -s /bin/sh -D curl

FROM scratch 

ARG CURL_REPOSITORY \
    CURL_VERSION \
    CURL_BRANCH \
    CURL_COMMIT

ENV CURL_REPOSITORY="${CURL_REPOSITORY}" \
    CURL_VERSION="${CURL_VERSION}" \
    CURL_BRANCH="${CURL_BRANCH}" \
    CURL_COMMIT="${CURL_COMMIT}"

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/cert.pem /etc/ssl/cert.pem
COPY --from=builder /usr/local/bin/curl /usr/local/bin/curl

USER curl
WORKDIR /home/curl

ENTRYPOINT ["/usr/local/bin/curl"]
CMD ["-h"]

LABEL org.opencontainers.image.title="curl" \
    org.opencontainers.image.description="curl with rustls in a container" \ 
    org.opencontainers.image.revision="${CURL_COMMIT}" \
    org.opencontainers.image.version="${CURL_VERSION}"
