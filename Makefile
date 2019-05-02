BUILD_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DATA_DIR:=$(BUILD_DIR)/data
REDIS_URL:=$(shell grep 'redis' /etc/hosts | awk '{ print $$1 }')

start: build stop run

build-new:
	docker pull alephdata/memorious
	docker build -f Dockerfile-new -t alephdata/opensanctions .

build:
	docker build -t alephdata/opensanctions .

run: 
	docker run -d --rm --name=opensanctions --add-host="redis:$(REDIS_URL)" -ti -v $(DATA_DIR):/data alephdata/opensanctions

login: 
	docker run --rm --name=opensanctions --add-host="redis:$(REDIS_URL)" -ti -v $(DATA_DIR):/data alephdata/opensanctions /bin/sh

stop:
	docker stop opensanctions

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
