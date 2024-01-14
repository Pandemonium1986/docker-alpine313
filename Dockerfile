FROM alpine:3.15 AS builder

ARG VERSION_ANSIBLE="8.7.0"
ARG VERSION_ANSIBLE_LINT="6.20.3"
ARG VERSION_MOLECULE="5.1.0"

ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

RUN apk add --update-cache --no-cache \
        alpine-sdk \
        libffi-dev \
        openssl-dev \
        py3-pip \
        python3 \
        python3-dev

RUN pip install --upgrade --no-cache-dir pip

# Fix AttributeError: cython_sources https://stackoverflow.com/questions/77490435/attributeerror-cython-sources/77491847#77491847
# RUN pip install --user --no-cache-dir "cython<3.0.0" wheel
# RUN pip install --user --no-cache-dir "pyyaml==5.4.1" --no-build-isolation

RUN pip install --user --no-cache-dir \
        ansible==${VERSION_ANSIBLE} \
        ansible-lint==${VERSION_ANSIBLE_LINT} \
        molecule==${VERSION_MOLECULE} \
        molecule-plugins[docker]

# Prepare molecule workspace
RUN mkdir /opt/workspace

WORKDIR /opt/workspace

CMD ["/bin/bash"]


FROM alpine:3.15

LABEL maintainer="Michael Maffait"
LABEL org.opencontainers.image.source="https://github.com/Pandemonium1986/docker-alpine318"

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
COPY --from=builder /usr/lib/python3.9/site-packages/ /usr/lib/python3.9/site-packages/
COPY --from=builder /root/.local/lib/python3.9/site-packages/ /usr/lib/python3.9/site-packages/
COPY --from=builder /root/.local/bin/ansible*  /usr/bin/
COPY --from=builder /root/.local/bin/molecule  /usr/bin/molecule
COPY --from=builder /root/.local/bin/yamllint  /usr/bin/yamllint

# Prepare molecule workspace
RUN mkdir /opt/workspace

WORKDIR /opt/workspace

CMD ["/bin/bash"]
