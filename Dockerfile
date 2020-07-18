FROM golang:latest as builder

# Set the Current Working Directory inside the container
WORKDIR /data

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependancies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

WORKDIR /data/cmd/envkiller

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .


######## Start a new stage from scratch #######
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /data/

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /data/cmd/envkiller/app .

# Command to run the executable
CMD ["./app"]