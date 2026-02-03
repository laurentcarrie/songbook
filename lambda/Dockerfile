# Build stage - compile band-songbook from crates.io
FROM rustlang/rust:nightly-bookworm AS builder

# Install band-songbook from crates.io
RUN cargo install band-songbook

# Runtime stage - AWS Lambda base image
FROM public.ecr.aws/lambda/provided:al2023

# Install required runtime dependencies
# - AWS CLI for S3 operations
# - jq for JSON processing
# - ca-certificates for HTTPS
# - texlive for PDF generation (lualatex with full packages)
RUN dnf install -y \
    unzip \
    tar \
    jq \
    ca-certificates \
    texlive-scheme-full \
    && dnf clean all

# Install lilypond for music notation
RUN curl -L "https://gitlab.com/lilypond/lilypond/-/releases/v2.24.4/downloads/lilypond-2.24.4-linux-x86_64.tar.gz" -o /tmp/lilypond.tar.gz \
    && tar -xzf /tmp/lilypond.tar.gz -C /opt \
    && ln -s /opt/lilypond-2.24.4/bin/lilypond /usr/local/bin/lilypond \
    && rm /tmp/lilypond.tar.gz

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip

# Copy the compiled binary
COPY --from=builder /usr/local/cargo/bin/band-songbook /usr/local/bin/band-songbook

# Copy the bootstrap script (Lambda entry point)
COPY bootstrap /var/runtime/bootstrap
RUN chmod +x /var/runtime/bootstrap

# Set the entrypoint
ENTRYPOINT ["/var/runtime/bootstrap"]
