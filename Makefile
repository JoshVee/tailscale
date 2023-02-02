IMAGE_REPO ?= tailscale/tailscale
SYNO_ARCH ?= "amd64"
SYNO_DSM ?= "7"

usage:
	echo "See Makefile"

vet:
	./tool/go vet ./...

tidy:
	./tool/go mod tidy

updatedeps:
	# depaware (via x/tools/go/packages) shells back to "go", so make sure the "go"
	# it finds in its $$PATH is the right one.
	PATH="$$(./tool/go env GOROOT)/bin:$$PATH" ./tool/go run github.com/tailscale/depaware --update \
		tailscale.com/cmd/tailscaled \
		tailscale.com/cmd/tailscale \
		tailscale.com/cmd/derper

depaware:
	# depaware (via x/tools/go/packages) shells back to "go", so make sure the "go"
	# it finds in its $$PATH is the right one.
	PATH="$$(./tool/go env GOROOT)/bin:$$PATH" ./tool/go run github.com/tailscale/depaware --check \
		tailscale.com/cmd/tailscaled \
		tailscale.com/cmd/tailscale \
		tailscale.com/cmd/derper

buildwindows:
	GOOS=windows GOARCH=amd64 ./tool/go install tailscale.com/cmd/tailscale tailscale.com/cmd/tailscaled

build386:
	GOOS=linux GOARCH=386 ./tool/go install tailscale.com/cmd/tailscale tailscale.com/cmd/tailscaled

buildlinuxarm:
	GOOS=linux GOARCH=arm ./tool/go install tailscale.com/cmd/tailscale tailscale.com/cmd/tailscaled

buildwasm:
	GOOS=js GOARCH=wasm ./tool/go install ./cmd/tsconnect/wasm ./cmd/tailscale/cli

buildlinuxloong64:
	GOOS=linux GOARCH=loong64 ./tool/go install tailscale.com/cmd/tailscale tailscale.com/cmd/tailscaled

buildmultiarchimage:
	./build_docker.sh

check: staticcheck vet depaware buildwindows build386 buildlinuxarm buildwasm

staticcheck:
	./tool/go run honnef.co/go/tools/cmd/staticcheck -- $$(./tool/go list ./... | grep -v tempfork)

spk:
	PATH="${PWD}/tool:${PATH}" ./tool/go run github.com/tailscale/tailscale-synology@main -o tailscale.spk --source=. --goarch=${SYNO_ARCH} --dsm-version=${SYNO_DSM}

spkall:
	mkdir -p spks
	PATH="${PWD}/tool:${PATH}" ./tool/go run github.com/tailscale/tailscale-synology@main -o spks --source=. --goarch=all --dsm-version=all

pushspk: spk
	echo "Pushing SPK to root@${SYNO_HOST} (env var SYNO_HOST) ..."
	scp tailscale.spk root@${SYNO_HOST}:
	ssh root@${SYNO_HOST} /usr/syno/bin/synopkg install tailscale.spk

publishdevimage:
	@test -n "${REPO}" || (echo "REPO=... required; e.g. REPO=ghcr.io/${USER}/tailscale" && exit 1)
	@test "${REPO}" != "tailscale/tailscale" || (echo "REPO=... must not be tailscale/tailscale" && exit 1)
	@test "${REPO}" != "ghcr.io/tailscale/tailscale" || (echo "REPO=... must not be ghcr.io/tailscale/tailscale" && exit 1)
	@test "${REPO}" != "tailscale/k8s-operator" || (echo "REPO=... must not be tailscale/k8s-operator" && exit 1)
	@test "${REPO}" != "ghcr.io/tailscale/k8s-operator" || (echo "REPO=... must not be ghcr.io/tailscale/k8s-operator" && exit 1)
	TAGS=latest REPOS=${REPO} PUSH=true TARGET=client ./build_docker.sh

publishdevoperator:
	@test -n "${REPO}" || (echo "REPO=... required; e.g. REPO=ghcr.io/${USER}/tailscale" && exit 1)
	@test "${REPO}" != "tailscale/tailscale" || (echo "REPO=... must not be tailscale/tailscale" && exit 1)
	@test "${REPO}" != "ghcr.io/tailscale/tailscale" || (echo "REPO=... must not be ghcr.io/tailscale/tailscale" && exit 1)
	@test "${REPO}" != "tailscale/k8s-operator" || (echo "REPO=... must not be tailscale/k8s-operator" && exit 1)
	@test "${REPO}" != "ghcr.io/tailscale/k8s-operator" || (echo "REPO=... must not be ghcr.io/tailscale/k8s-operator" && exit 1)
	TAGS=latest REPOS=${REPO} PUSH=true TARGET=operator ./build_docker.sh
