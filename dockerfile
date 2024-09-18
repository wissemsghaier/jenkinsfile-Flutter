
# dockerfile with install Fastlane


# Utiliser Ubuntu 23.04 comme image de base
FROM ubuntu:23.04

# Définir les variables d'environnement pour le mode non interactif
ENV DEBIAN_FRONTEND=noninteractive

# Configurer la locale en UTF-8
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Mettre à jour les paquets, installer les dépendances nécessaires, et nettoyer les caches en une seule commande
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    software-properties-common \
    unzip \
    curl \
    git \
    apt-transport-https \
    openjdk-17-jdk \
    libglu1-mesa \
    xz-utils \
    zip \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    chromium-browser \
    libx11-xcb1 \
    libxkbfile1 \
    libsecret-1-0 \
    gnome-keyring \
    lib32z1 \
    lib32ncurses6 \
    libbz2-1.0 \
    lib32stdc++6 \
    ruby-full \
    build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/ /tmp/ /var/tmp/

# Installer Fastlane via RubyGems
RUN gem install fastlane -NV

# Définir la version de Flutter et l'emplacement d'installation
ENV FLUTTER_VERSION=3.24.2
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Télécharger et installer Flutter, puis supprimer l'archive téléchargée
RUN curl -L "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o flutter.tar.xz && \
    tar xf flutter.tar.xz -C /opt && \
    rm flutter.tar.xz && \
    ln -s /opt/flutter/bin/flutter /usr/local/bin/flutter

# Configurer Git pour éviter les erreurs de propriété
RUN git config --global --add safe.directory /opt/flutter

# Installer Android SDK Command Line Tools et nettoyer les fichiers temporaires
RUN mkdir -p /opt/android-sdk/cmdline-tools && \
    curl -L "https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip" -o commandlinetools.zip && \
    unzip commandlinetools.zip -d /opt/android-sdk/cmdline-tools && \
    rm commandlinetools.zip && \
    mv /opt/android-sdk/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest

# Définir les variables d'environnement pour l'Android SDK
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

# Configurer Flutter avec le SDK Android
RUN flutter config --android-sdk $ANDROID_SDK_ROOT

# Installer les outils Android SDK et accepter les licences
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses && \
    ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager "platform-tools" "build-tools;33.0.1" "platforms;android-34"

# Définir CHROME_EXECUTABLE pour le développement web
ENV CHROME_EXECUTABLE=/usr/bin/chromium-browser

# Vérifier l'installation de Flutter
RUN flutter doctor --android-licenses

# Définir le répertoire de travail
WORKDIR /app

# Exposer le port 8080 si nécessaire
EXPOSE 8080

# Commande par défaut pour exécuter le conteneur
CMD ["flutter", "doctor", "-v"]
