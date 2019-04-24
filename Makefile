BUILD_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DATA_DIR:=$(BUILD_DIR)/data

all: build run

build-new:
	docker pull alephdata/memorious
	docker build -f Dockerfile-new -t alephdata/opensanctions .

build:
	docker build -t alephdata/opensanctions .

run: 
	docker container rm opensanctions
	docker run --name=opensanctions -ti -v $(DATA_DIR):/data alephdata/opensanctions /bin/sh

data/osanc.entities:
	osanc-dump >data/osanc.entities

load: data/osanc.entities
	ftm-integrate load-entities -e data/osanc.entities

integration/recon:
	ftm-integrate dump-recon -r integration/recon

data/osanc.apply.entities: data/osanc.entities integration/recon
	cat data/osanc.entities | ftm apply-recon -r integration/recon >data/osanc.apply.entities

data/osanc.agg.entities: data/osanc.apply.entities
	cat data/osanc.apply.entities | ftm aggregate >data/osanc.agg.entities

integrate: data/osanc.agg.entities
