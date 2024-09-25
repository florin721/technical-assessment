# Stage 1: Builder
FROM rust:1.72-slim-buster AS builder

WORKDIR /usr/src/myapp

COPY Cargo.toml ./ 
COPY src ./src

RUN cargo build --release

# Stage 2: Runtime
FROM debian:buster-slim

RUN groupadd -r appuser && useradd --no-log-init -r -g appuser appuser

COPY --from=builder /usr/src/myapp/target/release/myapp /usr/local/bin/myapp

RUN chown appuser:appuser /usr/local/bin/myapp

USER appuser

CMD ["myapp"]
