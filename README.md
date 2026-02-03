# Songbook

A collection of song sheets for band practice, built with [band-songbook](https://crates.io/crates/band-songbook).

## Requirements

- [Rust](https://rustup.rs/) (for installing band-songbook)
- [LilyPond](https://lilypond.org/) (for music notation)
- LaTeX (for PDF generation)

## Installation

```bash
cargo install band-songbook
```

## Usage

Build all songs:

```bash
make all
```

Build a specific song:

```bash
make song song=pixies
make song song="black_velvet"
```

Clean build output:

```bash
make clean
```

Show available targets:

```bash
make help
```

## Project Structure

```
songbook/
├── songs/                  # Song sources organized by artist
│   └── <artist>/
│       └── <song>/
│           ├── song.yml    # Song metadata and structure
│           ├── body.tex    # LaTeX body (optional)
│           ├── *.ly        # LilyPond notation files
│           └── lyrics/     # Lyrics files
├── settings.yml            # Global rendering settings
├── Makefile                # Build targets
└── sandbox/                # Build output (git-ignored)
```

## Song Configuration

Each song has a `song.yml` file defining:

- **info**: title, author, tempo, time signature
- **structure**: ordered sections (couplet, refrain, intro, solo, etc.)
- **files**: associated LilyPond, TeX, and audio files

## Settings

`settings.yml` configures rendering options including section colors:

- intro, couplet, prerefrain, refrain
- pont, solo, interlude, outro
- and more...
