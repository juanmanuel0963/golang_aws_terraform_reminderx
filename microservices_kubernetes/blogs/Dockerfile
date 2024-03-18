# syntax=docker/dockerfile:1

FROM golang:1.19
##FROM golang:1.19 AS build-stage
# Set destination for COPY
WORKDIR /app
RUN mkdir -p ~/blogs
RUN mkdir -p ~/_database

# Download Go modules
#COPY go.mod go.sum ./
#RUN go mod download

# Copy the source code. Note the slash at the end, as explained in
# https://docs.docker.com/engine/reference/builder/#copy

#COPY ./blogs /app/blogs/
#COPY ./_database /app/_database

COPY . /app/blogs/

# Build
#RUN CGO_ENABLED=0 GOOS=linux go build -o /docker-gs-ping
#RUN go version
#RUN $GOPATH
#RUN go run $GOPATH/src/crypto/tls/generate_cert.go -rsa-bits 2048 -host localhost

#https://vsupalov.com/docker-arg-env-variable-guide/
ENV PORT=80
ENV db_conn=""
RUN echo "Oh dang look at that $PORT"
RUN echo "Oh dang look at that $db_conn"

# To bind to a TCP port, runtime parameters must be supplied to the docker command.
# But we can (optionally) document in the Dockerfile what ports
# the application is going to listen on by default.
# https://docs.docker.com/engine/reference/builder/#expose
EXPOSE 80


# Run
CMD [ "/app/blogs/source_code/main" ]