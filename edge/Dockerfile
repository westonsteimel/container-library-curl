ARG GIT_TAG="master"
ARG CURL_VERSION="edge"

FROM alpine:edge as builder

ARG GIT_TAG
ARG CURL_VERSION
ENV CURL_VERSION="${CURL_VERSION}"

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
        upx \
	&& git clone --depth 1 --branch "${GIT_TAG}" https://github.com/curl/curl \
    && ( \
		cd curl \
        && autoreconf -i \
    	&& ./configure \
    		--with-nghttp2=/usr \
        	--with-ssl \
        	--enable-ipv6 \
        	--enable-unix-sockets \
        	--without-libidn \
        	--disable-ldap \
        	--with-pic \
            --disable-shared \
    	&& make curl_LDFLAGS=-all-static \
    	&& make install \
	) \
    && strip /usr/local/bin/curl \
    && upx --lzma --best /usr/local/bin/curl \
    && rm -r curl \
    && apk del .build-deps \
    && apk add --no-cache \
    nghttp2 \
    openssl \
    && addgroup curl \
    && adduser -G curl -s /bin/sh -D curl

FROM scratch 

ARG CURL_VERSION

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /usr/local/bin/curl /usr/local/bin/curl

USER curl
WORKDIR /home/curl

ENTRYPOINT ["/usr/local/bin/curl"]
CMD ["-h"]

LABEL org.opencontainers.image.title="curl" \
    org.opencontainers.image.description="curl in Docker" \ 
    org.opencontainers.image.version="${CURL_VERSION}" \
    version="${CURL_VERSION}"

