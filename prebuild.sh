#!/bin/bash

set -e

if  [ ! -d "Build" ]; then
    mkdir Build
fi

cd Build

# Step 1: Pull the repository if not already pulled
if [ ! -d "rarime-mobile-identity-sdk" ]; then
    git clone git@github.com:rarimo/rarime-mobile-identity-sdk.git
fi

# Step 2: Run the build script if the xcframework folder does not exist
if [ ! -d "rarime-mobile-identity-sdk/Frameworks/Identity.xcframework" ]; then
    export PATH="$PATH:/usr/local/go/bin/"
    export PATH="$PATH:$HOME/go/bin"

    cd rarime-mobile-identity-sdk
    go get -u golang.org/x/mobile/bind
    gomobile bind -target ios -o ./Frameworks/Identity.xcframework
    cd ..
fi

# Step 3: Move the xcframework folder to the Frameworks folder if not already moved
if [ ! -d "../Frameworks/Identity.xcframework" ]; then
    mv rarime-mobile-identity-sdk/Frameworks/Identity.xcframework ../Frameworks/
fi

exit 0
