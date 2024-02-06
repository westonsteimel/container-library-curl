# The global build args need to all be prefixed with ARG for the update substitutions to work
ARG CURL_REPOSITORY="https://github.com/curl/curl"
ARG CURL_VERSION="edge"
ARG CURL_BRANCH="master"
ARG CURL_COMMIT="ad79612f97fadff3bfc4e36040fad0a825e07cd3"

FROM ghcr.io/westonsteimel/rustls-ffi:edge as rustls-ffi 
FROM alpine:latest as builder

ARG CURL_REPOSITORY \
    CURL_BRANCH \
    CURL_COMMIT

WORKDIR /build

COPY --from=rustls-ffi /usr/local/rustls-ffi/ /usr/local/
COPY package-metadata.spec /build/

RUN apk upgrade && apk add --no-cache \
        ca-certificates \
	    g++ \
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
        libtool

RUN set -x \
    ldconfig /usr/local/ \
    && git clone --branch "${CURL_BRANCH}" "${CURL_REPOSITORY}" \
    && ( \
		cd curl \
        && git reset --hard "${CURL_COMMIT}" \
        && export ARCHITECTURE=$(arch) \
        && export CURL_DEV_VERSION=$(sed -n "s/^.*#define LIBCURL_VERSION\s\"\s*\(\S*\)\".*$/\1/p" include/curl/curlver.h) \
        && autoreconf -i \
    	&& ./configure \
    		--with-nghttp2=/usr \
        	--with-rustls=/usr/local \
        	--enable-ipv6 \
        	--enable-unix-sockets \
        	--without-libidn \
        	--disable-ldap \
        	--with-pic \
            --disable-shared \
            --enable-static \
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
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /usr/local/bin/curl /usr/local/bin/curl

USER curl
WORKDIR /home/curl

ENTRYPOINT ["/usr/local/bin/curl"]
CMD ["-h"]

LABEL org.opencontainers.image.title="curl" \
    org.opencontainers.image.description="curl with rustls in a container" \ 
    org.opencontainers.image.revision="${CURL_COMMIT}" \
    org.opencontainers.image.version="${CURL_VERSION}"
