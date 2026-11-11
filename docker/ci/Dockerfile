# Image the CI builds the songbook in: everything `make all` needs, on the same Ubuntu release and the same
# packages as the dev machine (Ubuntu 24.04: TeX Live 2023, LilyPond 2.24.3), so that the CI renders the sheets
# the way they come out locally. Built by .github/workflows/ci-image.yml when this directory changes.
#
# Not in the image, on purpose:
#   - band-songbook: installed by the deploy job from main of songbook-lambda (cached per commit), so the image does
#     not need a rebuild at every change of the tool;
#   - the chord fonts (songbook*.ttf): they come with songbook-lambda and change when a chord glyph is added, the
#     deploy job copies them to ~/.fonts at each run.
FROM ubuntu:24.04

LABEL org.opencontainers.image.source="https://github.com/laurentcarrie/songbook"
LABEL org.opencontainers.image.description="Build image of the songbook CI: texlive, lilypond, fluidsynth, ffmpeg, aws, rust"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Same TeX Live packages as the dev machine (the recommended ones are installed too, as there).
RUN apt-get update && apt-get install -y \
        texlive-base texlive-binaries texlive-extra-utils \
        texlive-fonts-extra texlive-fonts-extra-links texlive-fonts-recommended \
        texlive-latex-base texlive-latex-extra texlive-latex-recommended \
        texlive-luatex texlive-pictures texlive-plain-generic \
    && rm -rf /var/lib/apt/lists/*

# LilyPond, the mp3 renders (fluidsynth + soundfont + ffmpeg), the system fonts the sheets can ask for, and the
# tools of the Makefile and of the deploy job.
RUN apt-get update && apt-get install -y \
        lilypond fluidsynth fluid-soundfont-gm ffmpeg \
        fonts-adf-accanthis fonts-adf-berenis fonts-adf-gillius fonts-adf-universalis fonts-cabin fonts-cantarell \
        fonts-clear-sans fonts-comfortaa fonts-comic-neue fonts-croscore fonts-crosextra-caladea \
        fonts-crosextra-carlito fonts-droid-fallback fonts-ebgaramond-extra fonts-font-awesome fonts-freefont-otf \
        fonts-freefont-ttf fonts-gfs-artemisia fonts-gfs-complutum fonts-gfs-didot fonts-gfs-neohellenic \
        fonts-gfs-olga fonts-gfs-solomos fonts-go fonts-inter fonts-lato fonts-linuxlibertine fonts-lmodern \
        fonts-lobster fonts-lobstertwo fonts-oflb-asana-math fonts-open-sans fonts-opensymbol fonts-paratype \
        fonts-roboto-slab fonts-roboto-unhinted fonts-sil-andika fonts-sil-charis fonts-sil-gentium \
        fonts-sil-gentium-basic fonts-sil-gentiumplus fonts-sil-gentiumplus-compact fonts-stix fonts-texgyre \
        fonts-texgyre-math fonts-tuffy fonts-ubuntu fonts-urw-base35 fontconfig \
        make git curl ca-certificates unzip python3 tar gzip \
        build-essential pkg-config libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# AWS CLI v2 (not in the Ubuntu 24.04 repositories).
RUN curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp && /tmp/aws/install && rm -rf /tmp/aws /tmp/awscliv2.zip

# Rust, to install band-songbook: copied from the official image (same version as the Lambda image of songbook-lambda),
# not `curl | sh` from sh.rustup.rs: a failed download of a piped script does not fail the build, and behind a proxy
# that re-signs TLS (a dev machine on the company network) it fails.
COPY --from=rust:1.88-bookworm /usr/local/rustup /usr/local/rustup
COPY --from=rust:1.88-bookworm /usr/local/cargo /usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup CARGO_HOME=/usr/local/cargo PATH=/usr/local/cargo/bin:$PATH

# Fails the build of the image, not a deploy, when a tool is missing.
RUN set -e; \
    for t in lilypond lualatex fluidsynth ffmpeg aws cargo make python3 curl; do command -v "$t" >/dev/null || { echo "missing: $t"; exit 1; }; done; \
    test -f /usr/share/sounds/sf2/FluidR3_GM.sf2; \
    ffmpeg -hide_banner -encoders 2>/dev/null | grep -q libmp3lame; \
    lilypond --version | head -1; lualatex --version | head -1; aws --version; cargo --version
