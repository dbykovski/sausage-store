# Start from the latest golang base image
FROM golang:latest as builder
RUN apk add --no-cache ca-certificates curl
# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Get Yandex Cloud Certificate Authority
RUN curl -fsSL https://storage.yandexcloud.net/cloud-certs/CA.pem \
    -o /usr/local/share/ca-certificates/yandex_cloud_ca.crt


######## Start a new stage from scratch #######
FROM alpine:latest  

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy Yandex Cloud Certificate Authority
COPY --from=builder /usr/local/share/ca-certificates/yandex_cloud_ca.crt /usr/local/share/ca-certificates/yandex_cloud_ca.crt
RUN update-ca-certificates

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /app/main .

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["./main"] 