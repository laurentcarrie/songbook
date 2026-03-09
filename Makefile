.PHONY: all help clean song upload-prod upload-dev download-prod download-dev run-from-s3 prod dev sync-prod sync-dev fmt a b
.DEFAULT_GOAL := help

sandbox:=sandbox
srcdir:=songs
delivery:=delivery

all: ## build all songs
	band-songbook --srcdir songs --sandbox $(sandbox) --settings $(srcdir)/settings.yml --delivery $(delivery)

help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

song: ## build specific song, give song=...
	RUST_LOG=info band-songbook --srcdir songs --sandbox $(sandbox) --settings $(srcdir)/settings.yml \
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

upload-prod-or-dev: ## upload songs to S3 prod
	aws s3 rm --recursive s3://$(BUCKET)/$(BPATH)/songs
	aws s3 rm --recursive s3://$(BUCKET)/$(BPATH)/delivery
	aws s3 rm --recursive s3://$(BUCKET)/$(BPATH)/drums
	aws s3 cp --recursive songs s3://$(BUCKET)/$(BPATH)/songs
	aws s3 cp --recursive drums s3://$(BUCKET)/$(BPATH)/drums
	curl -sk -X POST -H 'X-Write-Password: $(WRITE_PASSWORD)' https://$(URL)/api/world


upload-prod: ## upload songs to S3 prod
	make upload-prod-or-dev BPATH=prod WRITE_PASSWORD=$(WRITE_PROD_PASSWORD) URL='move-the-line.org'


upload-dev: ## upload songs to S3 dev
	make upload-prod-or-dev BPATH=dev WRITE_PASSWORD=$(WRITE_PASSWORD) URL=localhost:3000


sync: ## upload songs to S3
	aws s3 sync songs s3://$(BUCKET)/$(BPATH)/songs

sync-prod: ## upload songs to S3 prod
	make sync BPATH=prod

sync-dev: ## upload songs to S3 dev
	make sync BPATH=dev

download: ## download prod data from S3
	aws s3 sync s3://$(BUCKET)/$(BPATH)/songs songs
	aws s3 sync s3://$(BUCKET)/$(BPATH)/drums drums


download-prod: ## download prod data from S
	make BPATH=prod download

fmt: ## format lyrics files
	find songs -path '*/lyrics/*.tex' -exec sed -i '' 's/\\songwordfb{ }/\\songwordfb{}/g' {} +
	find songs -path '*/lyrics/*.tex' -exec sed -i '' 's/  / /g' {} +

download-dev: ## download dev data from S3
	make BPATH=dev download

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


