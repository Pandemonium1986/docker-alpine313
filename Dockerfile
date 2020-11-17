FROM alpine:3.12 AS builder

ARG VERSION_MOLECULE="3.0.8"

RUN apk add --update-cache --no-cache \
        alpine-sdk \
        libffi-dev \
        openssl-dev \
        py3-pip \
        python3 \
        python3-dev

RUN pip install --no-cache \
        ansible \
        ansible-lint \
        molecule[docker]==${VERSION_MOLECULE}

FROM alpine:3.12
LABEL maintainer="Michael Maffait"

# Install basic tools
RUN apk add --update-cache --no-cache \
        alpine-sdk \
        bash \
        docker-cli \
        htop \
        openssl \
        python3 \
        tmux \
        tree \
        vim \
        zsh

# Copy from builder
COPY --from=builder /usr/lib/python3.8/site-packages/ /usr/lib/python3.8/site-packages/
COPY --from=builder /usr/bin/ansible*  /usr/bin/
COPY --from=builder /usr/bin/molecule  /usr/bin/molecule
COPY --from=builder /usr/bin/pytest    /usr/bin/pytest
COPY --from=builder /usr/bin/yamllint  /usr/bin/yamllint

# Prepare molecule workspace
RUN mkdir /opt/workspace

WORKDIR /opt/workspace

CMD ["/bin/bash"]
