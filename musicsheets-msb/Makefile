SONGBOOK  ?= $(HOME)/perso/songbook
PDF_DIR   ?= $(SONGBOOK)/delivery/pdf
SONGS_DIR ?= $(SONGBOOK)/songs
TEMPLATE  ?= MobileSheets_2026-11-03.msb
TABLET    ?= tablet
TABLET_DIR ?= /sdcard/Download/songbook
BIN       := gen_msb/target/release/gen_msb
OUT       := current.msb

.PHONY: msb push clean

# Build current.msb from the delivery PDFs (one collection per song.yml tag).
msb: $(OUT)

$(OUT): $(BIN) $(TEMPLATE) $(wildcard $(PDF_DIR)/*.pdf) $(wildcard $(SONGS_DIR)/*/*/song.yml)
	$(BIN) --template $(TEMPLATE) --pdf-dir $(PDF_DIR) --songs-dir $(SONGS_DIR) --out $@

$(BIN): $(wildcard gen_msb/src/*.rs) gen_msb/Cargo.toml
	cargo build --release --manifest-path gen_msb/Cargo.toml

# Build and copy to the tablet as current.msb.
push: $(OUT)
	scp $(OUT) $(TABLET):$(TABLET_DIR)/current.msb

clean:
	rm -f $(OUT)
