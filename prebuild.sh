#!/bin/bash

set -e

if  [ ! -d "Build" ]; then
    mkdir Build
fi

cd Build

# Clone repository if it does not exist
if [ ! -d "rarime-mobile-identity-sdk" ]; then
    echo "⏳ Cloning the repository"
    git clone git@github.com:rarimo/rarime-mobile-identity-sdk.git
fi

# Pull latest changes
echo "⏳ Pulling latest changes"
cd rarime-mobile-identity-sdk
git stash
git pull origin main
cd ..

# Remove existing builds
echo "⏳ Removing existing builds"
rm -rf rarime-mobile-identity-sdk/Frameworks/Identity.xcframework
rm -rf ../Frameworks/Identity.xcframework

# Run build script
export PATH="$PATH:/usr/local/go/bin/"
export PATH="$PATH:$HOME/go/bin"

echo "⏳ Building SDK"
cd rarime-mobile-identity-sdk
go get -u golang.org/x/mobile/bind
gomobile bind -target ios -o ./Frameworks/Identity.xcframework

# Move built framework to the root directory
cd ..
mv rarime-mobile-identity-sdk/Frameworks/Identity.xcframework ../Frameworks/

echo "✅ Build completed successfully"
exit 0
