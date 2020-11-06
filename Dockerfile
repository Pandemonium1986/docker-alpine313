FROM alpine:3.12
LABEL maintainer="Michael Maffait"

# Upgrade alpine linux and installtion basics tools.
RUN apk upgrade --update-cache --no-cache && \
    apk add --update-cache --no-cache \
        alpine-sdk \
        htop \
        tmux \
        tree \
        vim

CMD ["/bin/ash"]
