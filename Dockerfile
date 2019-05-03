#
# This Dockerfile builds a recent curl with HTTP/2 client support, using
# a recent nghttp2 build.
#
# See the Makefile for how to tag it. If Docker and that image is found, the
# Go tests use this curl binary for integration tests.
#

FROM alpine:edge as builder

RUN apk upgrade && apk add --no-cache \
	ca-certificates

ENV CURL_VERSION 7.64.1

RUN set -x \
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
    && rm -r /usr/share/man \
    && apk del .build-deps

FROM alpine:edge

COPY --from=builder /usr/local/bin/curl /usr/local/bin/curl

RUN apk upgrade && apk add --no-cache \
    ca-certificates \
    nghttp2 \
    openssl \
    && addgroup curl \
    && adduser -G curl -s /bin/sh -D curl

USER curl
WORKDIR /home/curl

ENTRYPOINT ["/usr/local/bin/curl"]
CMD ["-h"]
