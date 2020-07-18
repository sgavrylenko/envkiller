PROJECT?=github.com/sgavrylenko/envkiller
APP?=envkiller
CMD_DIR?=./cmd/${APP}

RELEASE?=0.0.1
COMMIT?=$(shell git rev-parse --short HEAD)
BUILD_TIME?=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
CONTAINER_IMAGE?=docker.io/bigboo/${APP}

GOOS?=darwin
GOARCH?=amd64

clean:
	cd ${CMD_DIR} && rm -f ${APP}

build: clean
	cd ${CMD_DIR} && \
	CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} go build \
		-ldflags "-s -w -X ${PROJECT}/pkg/version.Release=${RELEASE} \
		-X ${PROJECT}/pkg/version.Commit=${COMMIT} -X ${PROJECT}/pkg/version.BuildTime=${BUILD_TIME}" \
		-o ${APP}

run: build
	cd ${CMD_DIR} && ./${APP}

container:
	docker build -t ${CONTAINER_IMAGE}:${RELEASE} .

publish: container
#	docker stop ${APP} || true && docker rm $(APP) || true
#	docker run --name ${APP} --rm ${CONTAINER_IMAGE}:${RELEASE}
	docker push ${CONTAINER_IMAGE}:${RELEASE}

deploy: publish
	echo "deploy to local k8s"