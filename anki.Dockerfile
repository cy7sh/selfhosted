FROM rust:1.81-bookworm AS builder

RUN apt-get update && apt install --yes gnupg ca-certificates && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198 \
	&& echo "deb https://apt.buildkite.com/buildkite-agent stable main" > /etc/apt/sources.list.d/buildkite-agent.list \
	&& apt-get update \
	&& apt-get install --yes --no-install-recommends \
	autoconf \
	bash \
	buildkite-agent \
	ca-certificates \
	curl \
	findutils \
	g++ \
	gcc \
	git \
	grep \
	libdbus-1-3 \
	libegl1 \
	libfontconfig1 \
	libgl1 \
	libgstreamer-gl1.0-0 \
	libgstreamer-plugins-base1.0 \
	libgstreamer1.0-0 \
	libnss3 \
	libpulse-mainloop-glib0 \
	libpulse-mainloop-glib0 \    
	libssl-dev \
	libxcomposite1 \
	libxcursor1 \
	libxi6 \
	libxkbcommon-x11-0 \
	libxkbcommon0 \
	libxkbfile1	\
	libxrandr2 \
	libxrender1 \
	libxtst6 \
	make \
	pkg-config \
	portaudio19-dev \
	python3-dev \
	rsync \
	unzip \
	zstd \
	protobuf-compiler \
	&& rm -rf /var/lib/apt/lists/*

RUN cargo install --git https://github.com/ankitects/anki.git --tag 24.06.3 anki-sync-server

FROM debian:bookworm-slim
COPY --from=builder /usr/local/cargo/bin/anki-sync-server /usr/local/bin/

CMD ["anki-sync-server"]
