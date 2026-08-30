.PHONY: all help clean watch song upload-prod upload-dev download-prod download-dev run-from-s3 prod dev sync-prod sync-dev fmt a b check-mp3 upload-prod-or-dev sync download reindex refresh-prod refresh-dev upload-mp3 upload-mp3-prod upload-mp3-dev dates upload-zip upload-books
.DEFAULT_GOAL := help

-include .env
export

sandbox:=sandbox
srcdir:=songs
booksdir:=books
delivery:=delivery

all: ## build all songs and books
	band-songbook --songs-srcdir $(srcdir) --books-srcdir $(booksdir) --sandbox $(sandbox) --settings $(srcdir)/settings.yml --delivery $(delivery)

help: ## show this help
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

# song= is a fuzzy subsequence match on "<author> <title>" from song.yml,
# NOT on the directory name. Case-insensitive but accent-sensitive, so
# song="finist" builds L'Autre Finistere but song="finistere" matches nothing,
# and song="black keys" works where song="black_keys" does not.
song: ## build specific song, song=<fuzzy match on "author title">, e.g. song="black keys"
	RUST_LOG=info band-songbook --songs-srcdir $(srcdir) --sandbox $(sandbox) --settings $(srcdir)/settings.yml \
	--pattern "$(song)" \
	--delivery "$(delivery)"

# Rebuilds on every change under songs/. Polls mtimes once a second rather than
# using inotify: entr and inotify-tools are not installed and pulling them in
# needs root, while this works out of the box. INTERVAL overrides the period.
watch: ## rebuild on every source change, song=... to narrow it down
	@interval=$${INTERVAL:-1}; prev=""; \
	echo "watching $(srcdir)/ - Ctrl+C to stop$${song:+ (song=$(song))}"; \
	while true; do \
		cur=$$(find $(srcdir) \( -name '*.ly' -o -name '*.ily' -o -name '*.tex' -o -name '*.yml' -o -name '*.tikz' \) \
			-printf '%T@ %p\n' 2>/dev/null | sort | md5sum); \
		if [ "$$cur" != "$$prev" ]; then \
			[ -n "$$prev" ] && echo "--- change detected, rebuilding at $$(date +%H:%M:%S)"; \
			prev=$$cur; \
			if [ -n "$(song)" ]; then $(MAKE) --no-print-directory song song="$(song)"; \
			else $(MAKE) --no-print-directory all; fi; \
		fi; \
		sleep $$interval; \
	done

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

check-mp3: ## verify songs/ holds at least as many mp3 as S3, before a destructive upload
	@if [ -z "$(BUCKET)" ] || [ -z "$(BPATH)" ]; then \
		echo "check-mp3: BUCKET and BPATH must be set"; exit 1; \
	fi; \
	local_n=$$(find songs -name '*.mp3' 2>/dev/null | wc -l); \
	remote_n=$$(aws s3 ls s3://$(BUCKET)/$(BPATH)/songs/ --recursive | grep -c '\.mp3' || true); \
	echo "mp3: songs/=$$local_n  s3://$(BUCKET)/$(BPATH)/songs=$$remote_n"; \
	if [ "$$local_n" -lt "$$remote_n" ]; then \
		echo ""; \
		echo "REFUSING TO UPLOAD: songs/ has fewer mp3 than S3 ($$local_n < $$remote_n)."; \
		echo "upload deletes s3://$(BUCKET)/$(BPATH)/songs first, then re-uploads from songs/,"; \
		echo "so $$(($$remote_n - $$local_n)) audio file(s) would be lost."; \
		echo ""; \
		echo "  fix:      make download-$(BPATH)   # pull the audio down first"; \
		echo "  override: make upload-$(BPATH) FORCE_MP3=1"; \
		echo ""; \
		[ -n "$(FORCE_MP3)" ] || exit 1; \
		echo "FORCE_MP3 set - continuing anyway."; \
	fi

upload-prod-or-dev: check-mp3 ## upload songs to S3 prod
	aws s3 rm --recursive s3://$(BUCKET)/$(BPATH)/songs
	aws s3 rm --recursive s3://$(BUCKET)/$(BPATH)/books
	aws s3 rm --recursive s3://$(BUCKET)/$(BPATH)/delivery
	aws s3 rm --recursive s3://$(BUCKET)/$(BPATH)/drums
	aws s3 cp --recursive songs s3://$(BUCKET)/$(BPATH)/songs
	aws s3 cp --recursive $(booksdir) s3://$(BUCKET)/$(BPATH)/books
	aws s3 cp --recursive drums s3://$(BUCKET)/$(BPATH)/drums
	curl -sk -X POST -H 'X-Write-Password: $(WRITE_PASSWORD)' https://$(URL)/api/world


upload-prod: ## upload songs to S3 prod
	make upload-prod-or-dev BPATH=prod WRITE_PASSWORD=$(WRITE_PROD_PASSWORD) URL='move-the-line.org'


upload-dev: ## upload songs to S3 dev
	make upload-prod-or-dev BPATH=dev WRITE_PASSWORD=$(WRITE_PASSWORD) URL=localhost:3000


upload-mp3: ## upload only the mp3 under songs/ to S3, needs BPATH
	@if [ -z "$(BUCKET)" ] || [ -z "$(BPATH)" ]; then \
		echo "upload-mp3: BUCKET and BPATH must be set"; exit 1; \
	fi; \
	local_n=$$(find songs -name '*.mp3' 2>/dev/null | wc -l); \
	if [ "$$local_n" -eq 0 ]; then \
		echo "upload-mp3: no mp3 under songs/ - nothing to upload"; exit 1; \
	fi; \
	echo "uploading $$local_n mp3 to s3://$(BUCKET)/$(BPATH)/songs"; \
	aws s3 sync songs s3://$(BUCKET)/$(BPATH)/songs --exclude '*' --include '*.mp3'

upload-mp3-prod: ## upload local mp3 to S3 prod
	make BPATH=prod upload-mp3

upload-mp3-dev: ## upload local mp3 to S3 dev
	make BPATH=dev upload-mp3

sync: ## upload songs and books to S3
	aws s3 sync songs s3://$(BUCKET)/$(BPATH)/songs
	aws s3 sync $(booksdir) s3://$(BUCKET)/$(BPATH)/books

sync-prod: ## upload songs to S3 prod
	make sync BPATH=prod

sync-dev: ## upload songs to S3 dev
	make sync BPATH=dev

reindex: ## POST /api/world to re-index a site (needs WRITE_PASSWORD and URL)
	@if [ -z "$(WRITE_PASSWORD)" ] || [ -z "$(URL)" ]; then \
		echo "reindex: WRITE_PASSWORD and URL must both be set"; exit 1; \
	fi; \
	body=$$(mktemp); \
	code=$$(curl -sk -X POST -o "$$body" -w '%{http_code}' \
		-H 'X-Write-Password: $(WRITE_PASSWORD)' 'https://$(URL)/api/world'); \
	echo "POST https://$(URL)/api/world -> HTTP $$code"; \
	head -c 500 "$$body"; echo; rm -f "$$body"; \
	case "$$code" in \
		2*) echo "reindex ok";; \
		000) echo "reindex FAILED: could not reach $(URL)"; exit 1;; \
		*) echo "reindex FAILED (HTTP $$code)"; exit 1;; \
	esac

refresh-prod: ## sync songs to S3 prod, then re-index move-the-line.org
	$(MAKE) sync BPATH=prod
	WRITE_PASSWORD='$(WRITE_PROD_PASSWORD)' $(MAKE) reindex URL=move-the-line.org

refresh-dev: ## sync songs to S3 dev, then re-index localhost
	$(MAKE) sync BPATH=dev
	WRITE_PASSWORD='$(WRITE_PASSWORD)' $(MAKE) reindex URL=localhost:3000

download: ## download prod data from S3
	aws s3 sync s3://$(BUCKET)/$(BPATH)/songs songs
	aws s3 sync s3://$(BUCKET)/$(BPATH)/drums drums


download-prod: ## download prod data from S
	make BPATH=prod download

dates: ## set meta.date in every song.yml from the song's last git commit
	@n=0; \
	for f in $$(find songs -name song.yml | sort); do \
		d=$$(dirname "$$f"); \
		gd=$$(git log -1 --format=%ad --date=short -- "$$d"); \
		if [ -z "$$gd" ]; then \
			echo "skip    $$d (not committed yet)"; continue; \
		fi; \
		dirty=""; \
		if ! git diff --quiet -- "$$d" || [ -n "$$(git ls-files --others --exclude-standard -- "$$d")" ]; then \
			dirty=" (uncommitted changes - $$gd is the last commit)"; \
		fi; \
		cur=$$(sed -n 's/^  date: *"\?\([0-9-]*\)"\?.*/\1/p' "$$f" | head -1); \
		if [ "$$cur" = "$$gd" ]; then \
			[ -n "$$dirty" ] && echo "ok      $$d$$dirty"; \
			continue; \
		fi; \
		sed -i "s|^  date: .*|  date: \"$$gd\"|" "$$f"; \
		echo "update  $$d  $$cur -> $$gd$$dirty"; \
		n=$$((n+1)); \
	done; \
	echo "$$n song.yml updated"

fmt: ## format lyrics files
	find songs -path '*/lyrics/*.tex' -exec sed -i '' 's/\\songwordfb{ }/\\songwordfb{}/g' {} +
	find songs -path '*/lyrics/*.tex' -exec sed -i '' 's/  / /g' {} +

download-dev: ## download dev data from S3
	make BPATH=dev download

run-from-s3: ## build from S3 source, deliver locally
	band-songbook --songs-srcdir s3://$(BUCKET)/songs --books-srcdir s3://$(BUCKET)/books --sandbox $(sandbox) --settings s3://$(BUCKET)/songs/settings.yml --delivery $(delivery)

prod: ## build prod from S3 with S3 delivery
	band-songbook \
		--songs-srcdir s3://$(BUCKET)/prod/songs \
		--books-srcdir s3://$(BUCKET)/prod/books \
		--sandbox $(sandbox) \
		--settings s3://$(BUCKET)/prod/songs/settings.yml \
		--delivery s3://$(BUCKET)/prod/delivery \
		--drum-patterns-dir s3://$(BUCKET)/prod/drums

dev: ## build dev from S3 with S3 delivery
	band-songbook \
		--songs-srcdir s3://$(BUCKET)/dev/songs \
		--books-srcdir s3://$(BUCKET)/dev/books \
		--sandbox $(sandbox) \
		--settings s3://$(BUCKET)/dev/songs/settings.yml \
		--delivery s3://$(BUCKET)/dev/delivery \
		--drum-patterns-dir s3://$(BUCKET)/dev/drums

upload-zip: all ## build all songs, zip delivery/pdf, and upload it to gdrive:/zik/pdf.zip
	rm -f pdf.zip
	cd $(delivery)/pdf && zip -r ../../pdf.zip .
	rclone copyto pdf.zip gdrive:/zik/pdf.zip

upload-books: all ## build all songs and books, then upload the book PDFs from delivery/pdf to gdrive:/zik
	rclone copy $(delivery)/pdf gdrive:/zik --include "book-*.pdf"


