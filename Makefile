.PHONY: all help clean song
.DEFAULT: all

sandbox:=sandbox
srcdir:=songs

all: ## build all songs
	band-songbook --srcdir songs --sandbox $(sandbox) --settings $(srcdir)/settings.yml

help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

	
song: ## build specific song, give song=...
	RUST_LOGS=info band-songbook --srcdir songs --sandbox $(sandbox) --settings $(srcdir)/settings.yml --pattern "$(song)"

clean: ## clean sandbox
	@sandbox_abs=$$(cd $(sandbox) 2>/dev/null && pwd); \
	makefile_dir=$$(cd $(dir $(abspath $(lastword $(MAKEFILE_LIST)))) && pwd); \
	if [ -z "$$sandbox_abs" ]; then \
		echo "Sandbox directory does not exist"; \
	elif [ "$${sandbox_abs##$$makefile_dir}" = "$$sandbox_abs" ]; then \
		echo "Error: sandbox '$$sandbox_abs' is not a subdirectory of '$$makefile_dir'"; \
		exit 1; \
	else \
		echo "Removing $$sandbox_abs"; \
		rm -rf "$$sandbox_abs"; \
	fi
