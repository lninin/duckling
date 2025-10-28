# ---- Etapa de compilación ----
FROM haskell:9.6 AS builder

RUN apt-get update -qq && \
  apt-get install -qq -y libpcre3 libpcre3-dev build-essential pkg-config curl git --fix-missing --no-install-recommends && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /duckling
COPY . .

# Pre-cargar snapshot de Stack (evita descarga gigante en Railway)
RUN mkdir -p ~/.stack && echo "system-ghc: true" > ~/.stack/config.yaml && \
    stack update && \
    stack build --only-dependencies

# Compilar el binario
RUN stack install --system-ghc

# ---- Imagen final ----
FROM debian:bookworm-slim

RUN apt-get update -qq && \
  apt-get install -qq -y libpcre3 libgmp10 --no-install-recommends && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /root/.local/bin/duckling-example-exe /usr/local/bin/
EXPOSE 8000
CMD ["duckling-example-exe", "-p", "8000"]

