#
# GitLab CI Android Runner
#
#
FROM openjdk:8-jdk

ENV ANDROID_BUILD_TOOLS "27.0.1"
ENV ANDROID_SDK_TOOLS "27.0.1"
ENV ANDROID_HOME "/android-sdk"
# emulator is in its own path since 25.3.0 (not in sdk tools anymore)
ENV PATH=$PATH:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# Prepare dependencies
RUN mkdir $ANDROID_HOME \
  && apt-get update --yes \
  && apt-get install --yes wget tar unzip lib32stdc++6 lib32z1 libqt5widgets5 expect \
  && apt-get clean \
  && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install sdk tools
RUN wget -O android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip \
  && unzip -q android-sdk.zip -d $ANDROID_HOME \
  && rm android-sdk.zip

# Workaround for 
# Warning: File /root/.android/repositories.cfg could not be loaded.
RUN mkdir /root/.android \
  && touch /root/.android/repositories.cfg

# Workaround for host bitness error with android emulator
# https://stackoverflow.com/a/37604675/455578
RUN mv /bin/sh /bin/sh.backup \
  && cp /bin/bash /bin/sh

RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

# Update platform and build tools
RUN sdkmanager "tools" "platform-tools" "build-tools;${ANDROID_BUILD_TOOLS}"

# Update SDKs
RUN sdkmanager "platforms;android-27" "platforms;android-24"

# Update emulators
RUN sdkmanager "system-images;android-24;google_apis;x86_64"

# Update extra
RUN sdkmanager "extras;android;m2repository" "extras;google;m2repository" "extras;google;google_play_services"

# Constraint Layout
RUN sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
RUN sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"

# echo actually installed Android SDK packages
RUN sdkmanager --list
