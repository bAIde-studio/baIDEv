#!/usr/bin/env bash

export ORGANIZATION="penpotapp";
export DEVENV_IMGNAME="$ORGANIZATION/devenv";
export DEVENV_PNAME="penpotdev";

# shellcheck disable=SC2155
export CURRENT_USER_ID=$(id -u);
# shellcheck disable=SC2155
export CURRENT_VERSION=$(cat ./version.txt);
# shellcheck disable=SC2155
export CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD);
# shellcheck disable=SC2155
export CURRENT_HASH=$(git rev-parse --short HEAD);
# shellcheck disable=SC2155
export CURRENT_COMMITS=$(git rev-list --count HEAD)

set -ex

# ... (Other functions: print-current-version, build-frontend-bundle, etc. -  no changes needed)

function print-current-version {
    echo -n "$CURRENT_VERSION-$CURRENT_COMMITS-g$CURRENT_HASH"
}

function build-devenv {
    set +e;
    echo "Building development image $DEVENV_IMGNAME:latest..."

    pushd docker/devenv;

    # Podman doesn't typically need qemu setup like Docker does
    # Removed lines related to tonistiigi/binfmt

    # Buildx emulation setup
    podman buildx create --name=penpot --use
    podman buildx inspect --bootstrap > /dev/null 2>&1

    # Use podman buildx instead of docker buildx
    podman buildx build --platform linux/amd64,linux/arm64 --push -t $DEVENV_IMGNAME:latest .;
    podman pull $DEVENV_IMGNAME:latest;

    popd;
}

function build-devenv-local {
    echo "Building local only development image $DEVENV_IMGNAME:latest..."

    pushd docker/devenv;
    podman build -t $DEVENV_IMGNAME:latest .;
    popd;
}

function pull-devenv {
    set -ex
    podman pull $DEVENV_IMGNAME:latest
}

function pull-devenv-if-not-exists {
    if [[ ! $(podman images $DEVENV_IMGNAME:latest -q) ]]; then
        # shellcheck disable=SC2068
        pull-devenv $@
    fi
}

function start-devenv {
    # shellcheck disable=SC2068
    pull-devenv-if-not-exists $@;

    podman-compose -p $DEVENV_PNAME -f docker/devenv/docker-compose.yaml up -d;
}

function stop-devenv {
    podman-compose -p $DEVENV_PNAME -f docker/devenv/docker-compose.yaml stop -t 2;
}

function drop-devenv {
    podman-compose -p $DEVENV_PNAME -f docker/devenv/docker-compose.yaml down -t 2 -v;

    echo "Clean old development image $DEVENV_IMGNAME..."
    podman images $DEVENV_IMGNAME -q | awk '{print $3}' | xargs --no-run-if-empty podman rmi
}

# ... (Other functions: log-devenv, run-devenv-tmux, etc. - most need no changes)

function run-devenv-shell {
    if [[ ! $(podman ps -f "name=penpot-devenv-main" -q) ]]; then
        start-devenv
    fi
    podman exec -ti penpot-devenv-main sudo -EH -u penpot bash
}

function build {
    echo ">> build st art: $1"
    # shellcheck disable=SC2155
    local version=$(print-current-version);

    pull-devenv-if-not-exists;
    podman volume create ${DEVENV_PNAME}_user_data;

    # Use podman run instead of docker run
    podman run -t --rm \
           --mount source=${DEVENV_PNAME}_user_data,type=volume,target=/home/penpot/ \
           # shellcheck disable=SC2046
           --mount source=8`pwd`,type=bind,target=/home/penpot/penpot \
           -e EXTERNAL_UID=$CURRENT_USER_ID \
           -e SHADOWCLJS_EXTRA_PARAMS=$SHADOWCLJS_EXTRA_PARAMS \
           -w /home/penpot/penpot/$1 \
           $DEVENV_IMGNAME:latest sudo -EH -u penpot ./scripts/build $version

    echo ">> build end: $1"
}




function put-license-file {
    local target=$1;
    tee -a $target/LICENSE  >> /dev/null <<EOF
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Copyright (c) KALEIDOS INC
EOF
}

function build-frontend-bundle {
    echo ">> bundle frontend start";

    mkdir -p ./bundles
    local version=$(print-current-version);
    local bundle_dir="./bundles/frontend";

    build "frontend";

    rm -rf $bundle_dir;
    mv ./frontend/target/dist $bundle_dir;
    echo $version > $bundle_dir/version.txt;
    put-license-file $bundle_dir;
    echo ">> bundle frontend end";
}

function build-backend-bundle {
    echo ">> bundle backend start";

    mkdir -p ./bundles
    local version=$(print-current-version);
    local bundle_dir="./bundles/backend";

    build "backend";

    rm -rf $bundle_dir;
    mv ./backend/target/dist $bundle_dir;
    echo $version > $bundle_dir/version.txt;
    put-license-file $bundle_dir;
    echo ">> bundle backend end";
}

function build-exporter-bundle {
    echo ">> bundle exporter start";

    mkdir -p ./bundles
    local version=$(print-current-version);
    local bundle_dir="./bundles/exporter";

    build "exporter";

    rm -rf $bundle_dir;
    mv ./exporter/target $bundle_dir;

    echo $version > $bundle_dir/version.txt
    put-license-file $bundle_dir;

    echo ">> bundle exporter end";
}

function build-docker-images {
    rsync -avr --delete ./bundles/frontend/ ./docker/images/bundle-frontend/;
    rsync -avr --delete ./bundles/backend/ ./docker/images/bundle-backend/;
    rsync -avr --delete ./bundles/exporter/ ./docker/images/bundle-exporter/;

    pushd ./docker/images;

    docker build -t penpotapp/frontend:$CURRENT_BRANCH -t penpotapp/frontend:latest -f Dockerfile.frontend .;
    docker build -t penpotapp/backend:$CURRENT_BRANCH -t penpotapp/backend:latest -f Dockerfile.backend .;
    docker build -t penpotapp/exporter:$CURRENT_BRANCH -t penpotapp/exporter:latest -f Dockerfile.exporter .;

    popd;
}

function usage {
    echo "PENPOT build & release manager"
    echo "USAGE: $0 OPTION"
    echo "Options:"
    echo "- pull-devenv                      Pulls docker development oriented image"
    echo "- build-devenv                     Build docker development oriented image"
    echo "- start-devenv                     Start the development oriented docker compose service."
    echo "- stop-devenv                      Stops the development oriented docker compose service."
    echo "- drop-devenv                      Remove the development oriented docker compose containers, volumes and clean images."
    echo "- run-devenv                       Attaches to the running devenv container and starts development environment"
    echo ""
}

case $1 in
    version)
        print-current-version
        ;;

    ## devenv related commands
    pull-devenv)
        # shellcheck disable=SC2068
        pull-devenv ${@:2};
        ;;

    build-devenv)
        # shellcheck disable=SC2068
        build-devenv ${@:2}
        ;;

    build-devenv-local)
        # shellcheck disable=SC2068
        build-devenv-local ${@:2}
        ;;

    push-devenv)
        # shellcheck disable=SC2068
        push-devenv ${@:2}
        ;;

    start-devenv)
        # shellcheck disable=SC2068
        start-devenv ${@:2}
        ;;
    run-devenv)
        # shellcheck disable=SC2068
        run-devenv-tmux ${@:2}
        ;;
    run-devenv-shell)
        # shellcheck disable=SC2068
        run-devenv-shell ${@:2}
        ;;
    stop-devenv)
        # shellcheck disable=SC2068
        stop-devenv ${@:2}
        ;;
    drop-devenv)
        # shellcheck disable=SC2068
        drop-devenv ${@:2}
        ;;
    log-devenv)
        # shellcheck disable=SC2068
        log-devenv ${@:2}
        ;;

    # production builds
    build-bundle)
        build-frontend-bundle;
        build-backend-bundle;
        build-exporter-bundle;
        ;;

    build-frontend-bundle)
        build-frontend-bundle;
        ;;

    build-backend-bundle)
        build-backend-bundle;
        ;;

    build-exporter-bundle)
        build-exporter-bundle;
        ;;

    build-docker-images)
        build-docker-images
        ;;

    # Docker Image Tasks
    *)
        usage
        ;;
esac
