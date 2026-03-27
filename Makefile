# Colors
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
BLUE=\033[0;34m
CYAN=\033[0;36m
NC=\033[0m

.DEFAULT_GOAL := help
SERVER=root@192.168.1.224:/home/jtmonkeyboy/git/vendor/jakerunyan/ozzyCraft/OzzyVol/data/
LOCAL=./OzzyVol/data/


.PHONY: help
help: ## [General] Show this help
	@printf "$(CYAN)Usage:$(NC)\n  make <target> [VAR=value]\n\n"
	@gawk 'BEGIN { \
		FS=":.*## "; \
		want[1]="General"; \
		want[2]="Docker"; \
		want[3]="Sync"; \
		want[4]="Dev"; \
		want[5]="Other"; \
		printf "$(CYAN)Targets:$(NC)\n"; \
	} \
	/^[a-zA-Z0-9_.-]+:.*## / { \
		target=$$1; desc=$$2; \
		category="Other"; \
		if (match(desc, /^\[[^]]+\]/)) { \
			category=substr(desc, RSTART+1, RLENGTH-2); \
			desc=substr(desc, RLENGTH+2); \
		} \
		items[category]=items[category] sprintf("  $(GREEN)%-18s$(NC) %s\n", target, desc); \
		seen[category]=1; \
	} \
	END { \
		# 1) print categories in want[] order \
		for (i=1; i in want; i++) { \
			c=want[i]; \
			if (c in seen) { \
				printf "\n%s:\n%s", c, items[c]; \
				printed[c]=1; \
			} \
		} \
		# 2) print any categories not listed in want[] \
		for (c in items) { \
			if (!(c in printed)) { \
				printf "\n%s:\n%s", c, items[c]; \
			} \
		} \
	}' $(MAKEFILE_LIST)

start: ## [Docker] Start the container
	docker compose up -d

stop: ## [Docker] Stops the container and server
	docker compose down

run: ## [Docker] Start the container and get into the console
	@printf "$(CYAN)To get out of the console: ctrl p + q$(NC)\n"
	docker compose up -d && docker compose attach minecraft

console: ## [Docker] Get into the console
	@printf "$(CYAN)To get out of the console: ctrl p + q$(NC)\n"
	docker compose attach minecraft

push: ## [Sync] Local -> Server
	rsync -av --delete \
	$(LOCAL) \
	$(SERVER)

pull: ## [Sync] Server -> Local
	rsync -av --delete \
	$(SERVER) \
	$(LOCAL)

shell: ## [Dev] Get into the server files
	docker compose exec minecraft bash

command: ## [Dev] Send a single command to the shell
	docker compose exec minecraft $(cmd)