#!/bin/bash

# Setup variables
version="1.13.0-beta"
commit_hash="2901045"
babashka_version="0.8.2"
clj_kondo_version="2022.04.25"

# Setup Java Home
export PATH="/usr/lib/jvm/java-18-openjdk/bin:$PATH"

# Cleanup old files
rm -rf bin penpot.jar public src *.tar.gz*

# Create bin and src
mkdir -p {bin,src}

# Download the latest version of penpot
wget -O penpot-$version.tar.gz https://github.com/penpot/penpot/archive/$commit_hash.tar.gz
tar -xf penpot-$version.tar.gz --strip-components=1 -C src

# Patch backend to allow for redis sockets
sed -i 's/io.lettuce\/lettuce-core {:mvn\/version "6.1.6.RELEASE"}/io.lettuce\/lettuce-core {:mvn\/version "6.1.8.RELEASE"}\n  io.netty\/netty-transport-native-epoll$linux-x86_64 {:mvn\/version "4.1.77.Final"}\n/' src/backend/deps.edn

# Patch backend to allow setting the temporary asset directory
sed -i 's/"\/tmp\/penpot"/(cf\/get :tmp-directory)/' src/backend/src/app/main.clj

# Build backend
pushd src/backend
./scripts/build $version
popd
mv src/backend/target/dist/penpot.jar .

# Build exporter
pushd src/exporter
./scripts/build $version
cd target
yarn add pkg
yarn pkg -C GZip -t node18-linux-x64 -o penpot-exporter app.js
popd
mv src/exporter/target/penpot-exporter bin/penpot-exporter
chmod +x bin/penpot-exporter

# Patch frontend build to get commit hash from $2
sed -i 's/CURRENT_HASH=${CURRENT_HASH:-$(git rev-parse --short HEAD)};/CURRENT_HASH=$2/' src/frontend/scripts/build

# Build frontend
pushd src/frontend
./scripts/build $version $commit_hash
popd
mv src/frontend/target/dist public
mv src/docker/images/files/config.js public/js/config.js

# Clean up
rm penpot-$version.tar.gz
rm -r src

# Download babashka
wget -O - https://github.com/borkdude/babashka/releases/download/v$babashka_version/babashka-$babashka_version-linux-amd64-static.tar.gz | tar -zxf -
mv bb bin/bb
chmod +x bin/bb

# Download clj-kondo
wget -O - https://github.com/clj-kondo/clj-kondo/releases/download/v$clj_kondo_version/clj-kondo-$clj_kondo_version-linux-static-amd64.zip | zcat > bin/clj-kondo
chmod +x bin/clj-kondo




















































##!/bin/bash
#
## Setup variables
#version="1.13.0-beta"
#commit_hash="2901045"
#babashka_version="0.8.2"
#clj_kondo_version="2022.04.25"
#
## Setup Java Home
#export PATH="/usr/lib/jvm/java-18-openjdk/bin:$PATH"
#
## Cleanup old files
#rm -rf bin penpot.jar public src *.tar.gz*
#
## Create bin and src
#mkdir -p {bin,src}
#
## Download the latest version of penpot
#wget -O penpot-$version.tar.gz https://github.com/penpot/penpot/archive/$commit_hash.tar.gz
#tar -xf penpot-$version.tar.gz --strip-components=1 -C src
#
## Patch backend to allow for redis sockets
#sed -i 's/io.lettuce\/lettuce-core {:mvn\/version "6.1.6.RELEASE"}/io.lettuce\/lettuce-core {:mvn\/version "6.1.8.RELEASE"}\n  io.netty\/netty-transport-native-epoll$linux-x86_64 {:mvn\/version "4.1.77.Final"}\n/' src/backend/deps.edn
#
## Patch backend to allow setting the temporary asset directory
#sed -i 's/"\/tmp\/penpot"/(cf\/get :tmp-directory)/' src/backend/src/app/main.clj
#
## Build backend
#pushd src/backend
#./scripts/build $version
#popd
#mv src/backend/target/dist/penpot.jar .
#
## Build exporter
#pushd src/exporter
#./scripts/build $version
#cd target
#yarn add pkg
#yarn pkg -C GZip -t node18-linux-x64 -o penpot-exporter app.js
#popd
#mv src/exporter/target/penpot-exporter bin/penpot-exporter
#chmod +x bin/penpot-exporter
#
## Patch frontend build to get commit hash from $2
#sed -i 's/CURRENT_HASH=${CURRENT_HASH:-$(git rev-parse --short HEAD)};/CURRENT_HASH=$2/' src/frontend/scripts/build
#
## Build frontend
#pushd src/frontend
#./scripts/build $version $commit_hash
#popd
#mv src/frontend/target/dist public
#mv src/docker/images/files/config.js public/js/config.js
#
## Clean up
#rm penpot-$version.tar.gz
#rm -r src
#
## Download babashka
#wget -O - https://github.com/borkdude/babashka/releases/download/v$babashka_version/babashka-$babashka_version-linux-amd64-static.tar.gz | tar -zxf -
#mv bb bin/bb
#chmod +x bin/bb
#
## Download clj-kondo
#wget -O - https://github.com/clj-kondo/clj-kondo/releases/download/v$clj_kondo_version/clj-kondo-$clj_kondo_version-linux-static-amd64.zip | zcat > bin/clj-kondo
#chmod +x bin/clj-kondo