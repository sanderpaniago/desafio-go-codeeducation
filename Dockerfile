FROM golang:1.15-alpine3.13 AS build
RUN mkdir /app && \
    apk add --no-cache upx
ADD index.go /app/
WORKDIR /app
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-s -w" -o app -a  && \
    upx --ultra-brute -qq app && \
    upx -t app

FROM alpine:3.8 as certs
RUN apk --update add ca-certificates

FROM scratch
COPY --from=build /app/ /
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
WORKDIR /


CMD [ "./app" ]