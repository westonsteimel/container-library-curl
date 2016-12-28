#
# This Dockerfile builds a recent curl with HTTP/2 client support, using
# a recent nghttp2 build.
#
# See the Makefile for how to tag it. If Docker and that image is found, the
# Go tests use this curl binary for integration tests.
#

FROM alpine:edge

RUN apk add --no-cache \
	ca-certificates \
	nghttp2 \
	openssl

ENV CURL_VERSION 7.52.1

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
        	--disable-static \
        	--disable-ldap \
        	--with-pic \
    	&& make \
    	&& make install \
	) \
    && rm -r curl-$CURL_VERSION \
    && rm -r /usr/share/man \
    && apk del .build-deps

ENTRYPOINT ["/usr/local/bin/curl"]
CMD ["-h"]
