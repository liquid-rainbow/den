FROM dart:stable AS build

WORKDIR /src

COPY pubspec.yaml pubspec.lock ./
RUN dart pub get

COPY . .

RUN dart compile exe bin/server.dart -o /src/den-server

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && mkdir -p /app/certs \
    && curl --fail --silent --show-error --location \
      https://truststore.pki.rds.amazonaws.com/ap-south-1/ap-south-1-bundle.pem \
      --output /app/certs/ap-south-1-bundle.pem \
    && chmod 0444 /app/certs/ap-south-1-bundle.pem \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /src/den-server /app/den-server
COPY --from=build /src/migrations /app/migrations

RUN useradd --system --uid 10001 --no-create-home den
USER 10001

EXPOSE 5001

ENTRYPOINT ["/app/den-server"]
