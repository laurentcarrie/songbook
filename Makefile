.PHONY: all help clean song
.DEFAULT: all

sandbox:=sandbox
srcdir:=songs
delivery:=delivery

all: ## build all songs
	band-songbook --srcdir songs --sandbox $(sandbox) --settings $(srcdir)/settings.yml --delivery $(delivery)

help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

xxx: 
	band-songbook --srcdir s3://zik-laurent/songs/patty_smith/because_the_night --sandbox sandbox --settings $(srcdir)/settings.ylm
	
song: ## build specific song, give song=...
	RUST_LOGS=info band-songbook --srcdir songs --sandbox $(sandbox) --settings $(srcdir)/settings.yml \
	--pattern "$(song)" \
	--delivery "$(delivery)"

clean: ## clean sandbox and delivery
	@makefile_dir=$$(cd $(dir $(abspath $(lastword $(MAKEFILE_LIST)))) && pwd); \
	for dir in $(sandbox) $(delivery); do \
		dir_abs=$$(cd "$$dir" 2>/dev/null && pwd); \
		if [ -z "$$dir_abs" ]; then \
			echo "$$dir directory does not exist"; \
		elif [ "$${dir_abs##$$makefile_dir}" = "$$dir_abs" ]; then \
			echo "Error: '$$dir_abs' is not a subdirectory of '$$makefile_dir'"; \
			exit 1; \
		else \
			echo "Removing $$dir_abs"; \
			rm -rf "$$dir_abs"; \
		fi; \
	done


