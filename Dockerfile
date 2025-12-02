# Waldo Coffee - Flutter Development Container
FROM ubuntu:22.04

# Timezone ayarla (interactive olmasın diye)
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Istanbul

# Temel paketler
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Flutter SDK indir
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter

# Path'e ekle
ENV PATH="/opt/flutter/bin:${PATH}"

# Flutter doctor önce çalışsın
RUN flutter doctor -v

# Android SDK indirme (cmdline-tools)
RUN mkdir -p /opt/android-sdk/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip -q commandlinetools-linux-9477386_latest.zip -d /opt/android-sdk/cmdline-tools && \
    mv /opt/android-sdk/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest && \
    rm commandlinetools-linux-9477386_latest.zip

# Android SDK environment
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"

# Android licenses kabul et
RUN yes | sdkmanager --licenses || true

# Android SDK tools indir
RUN sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Chrome (web için)
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && apt-get install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb

# Çalışma dizini
WORKDIR /app

# Flutter web için
RUN flutter config --enable-web

# Port aç (web için)
EXPOSE 8080

# Varsayılan komut
CMD ["bash"]

