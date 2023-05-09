ARG VERSION="master"
ARG REVISION="8e21b1a05f3c0ee098dbcb6c3d84cb61f102a122"

FROM ghcr.io/westonsteimel/rustls-ffi:edge as rustls-ffi 

FROM alpine:latest as builder

ARG VERSION
ARG REVISION

COPY --from=rustls-ffi /usr/local/rustls-ffi/ /usr/local/

RUN set -x \
    && apk upgrade && apk add --no-cache \
    ca-certificates \
    && apk add --no-cache --virtual .build-deps \
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
        libtool \
	&& ldconfig /usr/local/ \
    && git clone --branch "${VERSION}" https://github.com/curl/curl \
    && ( \
		cd curl \
        && git reset --hard "${REVISION}" \
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
        && make -j4 V=1 LDFLAGS="-static -all-static" \
    	&& make install \
        && ldd /usr/local/bin/curl && exit 1 || true \
	) \
    && strip /usr/local/bin/curl \
    && if [$TARGETPLATFORM = "linux/amd64"]; then apk add --no-cache upx && upx --lzma --best /usr/local/bin/curl; fi \
    && rm -r curl \
    && apk del .build-deps \
    && apk add --no-cache \
    nghttp2 \
    openssl \
    && addgroup curl \
    && adduser -G curl -s /bin/sh -D curl

FROM scratch 

ARG VERSION
ARG REVISION

ENV CURL_VERSION="${VERSION}" \
    CURL_REVISION="${REVISION}"

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /usr/local/bin/curl /usr/local/bin/curl

USER curl
WORKDIR /home/curl

ENTRYPOINT ["/usr/local/bin/curl"]
CMD ["-h"]

LABEL org.opencontainers.image.title="curl" \
    org.opencontainers.image.description="curl in Docker" \ 
    org.opencontainers.image.revision="${REVISION}" \
    org.opencontainers.image.version="${VERSION}"
