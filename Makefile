.PHONY: all help clean song upload-prod upload-dev download-prod download-dev run-from-s3 prod dev
.DEFAULT: help

sandbox:=sandbox
srcdir:=songs
delivery:=delivery

all: ## build all songs
	band-songbook --srcdir songs --sandbox $(sandbox) --settings $(srcdir)/settings.yml --delivery $(delivery)

help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

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

upload-prod: ## upload songs to S3 prod
	aws s3 rm --recursive s3://$(BUCKET)/prod/songs
	aws s3 rm --recursive s3://$(BUCKET)/prod/delivery
	aws s3 rm --recursive s3://$(BUCKET)/prod/drums
	aws s3 cp --recursive songs s3://$(BUCKET)/prod/songs
	aws s3 cp --recursive drums s3://$(BUCKET)/prod/drums
	curl -sk -X POST -H 'X-Write-Password: $(WRITE_PROD_PASSWORD)' https://move-the-line.org/api/world                                                                           


sync-prod: ## upload songs to S3 prod
	aws s3 sync songs s3://$(BUCKET)/prod/songs


upload-dev: ## upload songs to S3 dev
	aws s3 rm --recursive s3://$(BUCKET)/dev/songs
	aws s3 rm --recursive s3://$(BUCKET)/dev/delivery
	aws s3 rm --recursive s3://$(BUCKET)/dev/drums
	aws s3 cp --recursive songs s3://$(BUCKET)/dev/songs
	aws s3 cp --recursive drums s3://$(BUCKET)/dev/drums
	aws s3 cp --recursive delivery s3://$(BUCKET)/dev/delivery2
	curl -s -X POST -H 'X-Write-Password: $(WRITE_PASSWORD)' http://localhost:8080/api/world                                                                           

download-prod: ## download prod data from S3
	aws s3 sync s3://$(BUCKET)/prod/songs songs
	aws s3 sync s3://$(BUCKET)/prod/drums drums

download-dev: ## download dev data from S3
	aws s3 sync s3://$(BUCKET)/dev/songs songs
	aws s3 sync s3://$(BUCKET)/dev/drums drums

run-from-s3: ## build from S3 source, deliver locally
	band-songbook --srcdir s3://$(BUCKET)/songs --sandbox $(sandbox) --settings s3://$(BUCKET)/songs/settings.yml --delivery $(delivery)

prod: ## build prod from S3 with S3 delivery
	band-songbook \
		--srcdir s3://$(BUCKET)/prod/songs \
		--sandbox $(sandbox) \
		--settings s3://$(BUCKET)/prod/songs/settings.yml \
		--delivery s3://$(BUCKET)/prod/delivery \
		--drum-patterns-dir s3://$(BUCKET)/prod/drums

dev: ## build dev from S3 with S3 delivery
	band-songbook \
		--srcdir s3://$(BUCKET)/dev/songs \
		--sandbox $(sandbox) \
		--settings s3://$(BUCKET)/dev/songs/settings.yml \
		--delivery s3://$(BUCKET)/dev/delivery \
		--drum-patterns-dir s3://$(BUCKET)/dev/drums

