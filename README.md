# Dockerfile to Golang w/ Kafka and Private Deps.
### A Dockerfile template to run Golang with "confluent-kafka-go" package which needs "librdkafka" to be installed and a setup to download to private Golang dependency
---

```sh
FROM golang:alpine AS build
ARG GIT_HOST
ARG GIT_USER
ARG GIT_PASS
RUN apk add --no-cache \
        git \
        gcc \
        libc-dev \
        librdkafka-dev \
        pkgconf

RUN printf "machine %s\
    login %s\
    password %s\n" \
    $GIT_HOST $GIT_USER $GIT_PASS >> $HOME/.netrc
RUN go env -w "GOPRIVATE=$GIT_HOST/*"

RUN mkdir /app/
WORKDIR /app/
ADD go.mod .
ADD go.sum .
RUN go mod download
ADD . /app/
RUN go build -tags musl -o binary ./cmd/consumer/main.go

FROM alpine
EXPOSE 3000
WORKDIR /app/
RUN apk add --no-cache librdkafka-dev
COPY --from=build /app/binary /app/
CMD ["/app/binary"]
```

### To build the image, the arguments are necessary:
```sh
docker build \
  -t my-image \
  --build-args GIT_HOST="github.com" \
  --build-args GIT_USER="italoservio" \
  --build-args GIT_PASS="access_token" \
  .
```

## 🔥 Gitlab TIP
### To run in a **Gitlab** pipeline the GIT_USER can be: `gitlab-ci-token`, the GIT_PASS `$CI_JOB_TOKEN` and the GIT_HOST `$CI_SERVER_HOST`.
