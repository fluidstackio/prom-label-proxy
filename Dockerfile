# Build stage
FROM golang:1.22-alpine AS builder

ARG ARCH="amd64"
ARG OS="linux"

# Install build dependencies
RUN apk add --no-cache git make

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=${OS} GOARCH=${ARCH} go build -a -installsuffix cgo -o prom-label-proxy .

# Final stage
ARG ARCH="amd64"
ARG OS="linux"
FROM quay.io/prometheus/busybox-${OS}-${ARCH}:glibc
LABEL maintainer="The Prometheus Authors <prometheus-developers@googlegroups.com>"

# Copy the binary from builder
COPY --from=builder /app/prom-label-proxy /bin/prom-label-proxy

USER        nobody
ENTRYPOINT  [ "/bin/prom-label-proxy" ]