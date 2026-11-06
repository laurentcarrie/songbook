SONGBOOK  ?= $(HOME)/perso/songbook
PDF_DIR   ?= $(SONGBOOK)/delivery/pdf
# ready-made pdfs of the songs that have `raw` in song.yml
RAW_DIR   ?= $(SONGBOOK)/delivery/raw
SONGS_DIR ?= $(SONGBOOK)/songs
BOOKS_DIR ?= $(SONGBOOK)/books
# where the build renders the snippets listed in song.yml (files.mp3)
SNIPPETS_DIR ?= $(SONGBOOK)/delivery/mp3-renders
AUDIO_DIR := audio
TEMPLATE  ?= MobileSheets_2026-11-03.msb
TABLET    ?= tablet
TABLET_DIR ?= /sdcard/Download/songbook
BIN       := gen_msb/target/release/gen_msb
OUT       := current.msb

.PHONY: msb clean

# Build current.msb from the delivery PDFs (one collection per song.yml tag).
msb: $(OUT)

$(OUT): $(BIN) $(TEMPLATE) $(wildcard $(PDF_DIR)/*.pdf) $(wildcard $(RAW_DIR)/*.pdf) $(wildcard $(SONGS_DIR)/*/*/song.mp3) $(wildcard $(SNIPPETS_DIR)/*.mp3) $(wildcard $(SONGS_DIR)/*/*/song.yml) $(wildcard $(BOOKS_DIR)/*.yml)
	$(BIN) --template $(TEMPLATE) --pdf-dir $(PDF_DIR) --songs-dir $(SONGS_DIR) --raw-dir $(RAW_DIR) --books-dir $(BOOKS_DIR) --snippets-dir $(SNIPPETS_DIR) --install-dir $(AUDIO_DIR) --out $@

$(BIN): $(wildcard gen_msb/src/*.rs) gen_msb/Cargo.toml
	cargo build --release --manifest-path gen_msb/Cargo.toml

clean:
	rm -rf $(OUT) $(AUDIO_DIR)
