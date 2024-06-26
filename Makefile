#!/usr/bin/make -f

PROJECT_NAME=rollapp-wasm
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
COMMIT := $(shell git log -1 --format='%H')
ifndef BECH32_PREFIX
    $(error BECH32_PREFIX is not set)
endif

# don't override user values
ifeq (,$(VERSION))
  VERSION := $(shell git describe --tags)
  # if VERSION is empty, then populate it with branch's name and raw commit hash
  ifeq (,$(VERSION))
    VERSION := $(BRANCH)-$(COMMIT)
  endif
endif

ifndef $(GOPATH)
    GOPATH=$(shell go env GOPATH)
    export GOPATH
endif

TM_VERSION := $(shell go list -m github.com/tendermint/tendermint | sed 's:.* ::')

export GO111MODULE = on

# process linker flags
ldflags = -X github.com/cosmos/cosmos-sdk/version.Name=dymension-rdk \
		  -X github.com/cosmos/cosmos-sdk/version.AppName=rollapp-wasm \
		  -X github.com/cosmos/cosmos-sdk/version.Version=$(VERSION) \
		  -X github.com/cosmos/cosmos-sdk/version.Commit=$(COMMIT) \
	      -X github.com/tendermint/tendermint/version.TMCoreSemVer=$(TM_VERSION) \
		  -X github.com/dymensionxyz/rollapp-wasm/app.AccountAddressPrefix=$(BECH32_PREFIX)

BUILD_FLAGS := -ldflags '$(ldflags)'


###########
# Install #
###########

all: install

.PHONY: install
install: build
	@echo "--> installing rollapp-wasm"
	mv build/rollapp-wasm $(GOPATH)/bin/rollapp-wasm


.PHONY: build
build: go.sum ## Compiles the rollapd binary
	@echo "--> Ensure dependencies have not been modified"
	@go mod verify
	@echo "--> building rollapp-wasm"
	go build  -o build/rollapp-wasm $(BUILD_FLAGS) ./rollappd


.PHONY: clean
clean: ## Clean temporary files
	go clean



###############################################################################
###                                Protobuf                                 ###
###############################################################################

protoVer=v0.7
protoImageName=tendermintdev/sdk-proto-gen:$(protoVer)
containerProtoGen=$(PROJECT_NAME)-proto-gen-$(protoVer)

proto-gen:
	@echo "Generating Protobuf files"
	@if docker ps -a --format '{{.Names}}' | grep -Eq "^${containerProtoGen}$$"; then docker start -a $(containerProtoGen); else docker run --name $(containerProtoGen) -v $(CURDIR):/workspace --workdir /workspace $(protoImageName) \
		sh ./scripts/protogen.sh; fi
	@go mod tidy

proto-clean:
	@echo "Cleaning proto generating docker container"
	@docker rm $(containerProtoGen) || true