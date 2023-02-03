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
