ARG CURL_VERSION="7.69.0"

FROM alpine:edge as builder

ARG CURL_VERSION
ENV CURL_VERSION="${CURL_VERSION}"

RUN set -x \
    && apk upgrade && apk add --no-cache \
    ca-certificates \
    && apk add --no-cache --virtual .build-deps \
		g++ \
		make \
		nghttp2-dev \
		openssl-dev \
		perl \
	&& wget https://curl.haxx.se/download/curl-$CURL_VERSION.tar.bz2 \
    && tar xjvf curl-$CURL_VERSION.tar.bz2 \
    && rm curl-$CURL_VERSION.tar.bz2 \
    && ( \
		cd curl-$CURL_VERSION \
    	&& ./configure \
    		--with-nghttp2=/usr \
        	--with-ssl \
        	--enable-ipv6 \
        	--enable-unix-sockets \
        	--without-libidn \
        	--disable-ldap \
        	--with-pic \
            --disable-shared \
    	&& make \
    	&& make install \
	) \
    && rm -r curl-$CURL_VERSION \
    && apk del .build-deps \
    && apk add --no-cache \
    nghttp2 \
    openssl \
    && addgroup curl \
    && adduser -G curl -s /bin/sh -D curl

FROM scratch 

ARG CURL_VERSION

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
COPY --from=builder /usr/lib/libnghttp2.so.14 /usr/lib/libnghttp2.so.14
COPY --from=builder /lib/libssl.so.1.1 /lib/libssl.so.1.1
COPY --from=builder /lib/libcrypto.so.1.1 /lib/libcrypto.so.1.1
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /usr/local/bin/curl /usr/local/bin/curl

USER curl
WORKDIR /home/curl

ENTRYPOINT ["/usr/local/bin/curl"]
CMD ["-h"]

LABEL org.opencontainers.image.title="curl" \
    org.opencontainers.image.description="curl in Docker" \ 
    org.opencontainers.image.url="https://github.com/westonsteimel/docker-curl" \ 
    org.opencontainers.image.source="https://github.com/westonsteimel/docker-curl" \
    org.opencontainers.image.version="${CURL_VERSION}" \
    version="${CURL_VERSION}"

