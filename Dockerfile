FROM debian:bookworm-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY . .
RUN cmake -S . -B /build -DCMAKE_BUILD_TYPE=Release \
    -DBREEZE_VULKAN=OFF -DBREEZE_CUDA=OFF -DBREEZE_BUILD_CLI=OFF \
    -DBREEZE_BUILD_SHARED=OFF -DBUILD_SHARED_LIBS=OFF -DGGML_NATIVE=OFF \
    && cmake --build /build --target breeze-server --parallel

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends libgomp1 libstdc++6 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --uid 10001 --create-home breeze \
    && mkdir -p /data/voices && chown -R breeze:breeze /data
COPY --from=build /build/breeze-server /usr/local/bin/breeze-server
USER breeze
WORKDIR /data
EXPOSE 8080 8081
ENTRYPOINT ["breeze-server"]
CMD ["--help"]
