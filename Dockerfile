# Build Stage
FROM lacion/alpine-golang-buildimage:1.13 AS build-stage

LABEL app="build-gobridget"
LABEL REPO="https://github.com/da-i/gobridget"

ENV PROJPATH=/go/src/github.com/da-i/gobridget

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/da-i/gobridget
WORKDIR /go/src/github.com/da-i/gobridget

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/da-i/gobridget"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/gobridget/bin

WORKDIR /opt/gobridget/bin

COPY --from=build-stage /go/src/github.com/da-i/gobridget/bin/gobridget /opt/gobridget/bin/
RUN chmod +x /opt/gobridget/bin/gobridget

# Create appuser
RUN adduser -D -g '' gobridget
USER gobridget

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/gobridget/bin/gobridget"]
