FROM golang:1.8.3-alpine3.6 as builder

RUN apk add --no-cache git build-base
RUN mkdir -p $GOPATH/src/github.com/ory \
	&& git clone --depth=1 https://github.com/ory/hydra $GOPATH/src/github.com/ory/hydra \
	&& go get github.com/Masterminds/glide \
	&& cd $GOPATH/src/github.com/ory/hydra \
	&& glide install --skip-test \
	&& go install github.com/ory/hydra


FROM alpine:3.6
RUN apk --no-cache add ca-certificates \
	&& mkdir -p /hydra
WORKDIR /hydra
COPY --from=builder /go/bin/hydra .

ENTRYPOINT ["/hydra/hydra", "migrate", "sql", "$DATABASE_URL", ";", "/hydra/hydra", "host", "--disable-telemetry"]

EXPOSE 4444
