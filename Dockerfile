# Kanzo v0.4.2 (https://github.com/emanuele-em/kanzo) behind Caddy with generated credentials.
# Upstream publishes no container image, so this fetches the pinned release binary and checks
# it against the sha256 published with that release.

FROM alpine:3.22@sha256:49340b346798875b5592e5d420241f2f9cfba5f47e62ebb1446a1b34734e898f AS kanzo
ARG KANZO_VERSION=0.4.2
ARG KANZO_SHA256=146c24e93c943158fae8fe35f070f49414a1f4754832312361dba895d3cbefea
RUN set -eux; \
    wget -q -O /tmp/kanzo.tar.xz "https://github.com/emanuele-em/kanzo/releases/download/v${KANZO_VERSION}/kanzo-x86_64-unknown-linux-musl.tar.xz"; \
    echo "${KANZO_SHA256}  /tmp/kanzo.tar.xz" | sha256sum -c -; \
    mkdir /tmp/kanzo; tar -xJf /tmp/kanzo.tar.xz -C /tmp/kanzo --strip-components=1; \
    install -m 0755 /tmp/kanzo/kanzo /usr/local/bin/kanzo; \
    /usr/local/bin/kanzo --version

FROM caddy:2.11.9-alpine@sha256:003a97808e781aa9f7e75cc2f43d34d461099031faf5e20faefb9f61126836f0
COPY --from=kanzo /usr/local/bin/kanzo /usr/local/bin/kanzo
COPY rootfs/ /
RUN chmod 0755 /usr/local/bin/start-kanzo
# The board's data lives on the Railway volume mounted at /data; Caddy keeps its own
# (unused, auto HTTPS is off) state out of it.
ENV KANZO_HOME=/data/kanzo \
    XDG_DATA_HOME=/var/lib/caddy \
    XDG_CONFIG_HOME=/var/lib/caddy-config \
    PORT=8080
EXPOSE 8080
CMD ["/usr/local/bin/start-kanzo"]
