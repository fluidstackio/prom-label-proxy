# Build stage
FROM golang:1.22-alpine AS builder

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

# Build the binary for linux/amd64
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o prom-label-proxy .

# Final stage
FROM quay.io/prometheus/busybox-linux-amd64:glibc
LABEL maintainer="The Prometheus Authors <prometheus-developers@googlegroups.com>"

# Copy the binary from builder
COPY --from=builder /app/prom-label-proxy /bin/prom-label-proxy

USER        nobody
ENTRYPOINT  [ "/bin/prom-label-proxy" ]