# Etapa de compilación
FROM haskell:9.4-bullseye AS builder

# Instalar dependencias necesarias
RUN apt-get update -qq && \
  apt-get install -qq -y libpcre3 libpcre3-dev build-essential pkg-config --fix-missing --no-install-recommends && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /duckling
COPY . .

ENV LANG=C.UTF-8

# Preparar entorno Stack y compilar
RUN stack setup && stack install

# Imagen final (runtime)
FROM debian:bullseye-slim

ENV LANG C.UTF-8

# Dependencias mínimas en el contenedor final
RUN apt-get update -qq && \
  apt-get install -qq -y libpcre3 libgmp10 --no-install-recommends && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copiar el ejecutable desde la etapa de build
COPY --from=builder /root/.local/bin/duckling-example-exe /usr/local/bin/

EXPOSE 8000

# Ejecutar el servidor HTTP de Duckling
CMD ["duckling-example-exe", "-p", "8000"]

