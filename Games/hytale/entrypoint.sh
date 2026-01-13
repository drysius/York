#!/bin/bash
set -e

cd /home/container

# check if exist hytale-downloader folder and check update
if [ ! -d "./hytale-downloader" ] || [[ "$(./hytale-downloader/hytale-downloader-linux -check-update 2>/dev/null)" != *"is up to date"* ]]; then
    echo "updating/downloading hytale-downloader..."
    
    DOWNLOAD_URL="https://downloader.hytale.com/hytale-downloader.zip"
    
    rm -f hytale-downloader.zip
    rm -rf hytale-downloader
    
    curl -s -o hytale-downloader.zip "$DOWNLOAD_URL"
    
    if [ $? -eq 0 ] && [ -f "hytale-downloader.zip" ]; then
        echo "downloaded complete, extracting..."
        
        unzip -q hytale-downloader.zip -d hytale-downloader
        
        # move binary
        mv hytale-downloader/hytale-downloader-linux-amd64 hytale-downloader/hytale-downloader-linux

        # Define execution permissions
        chmod 555 hytale-downloader/hytale-downloader-linux
    fi
else
    echo "hytale-downloader updated."
fi

# If HYTALE_SERVER_SESSION_TOKEN isn't set, assume the user will log in themselves, rather than a host's GSP
if [[ -z "$HYTALE_SERVER_SESSION_TOKEN" ]]; then
    # Example "2026.01.13-dcad8778f"
    HYTALE_VERSION=$(./hytale-downloader/hytale-downloader-linux -print-version)

    # check if version file exists and matches
    if [[ ! -f ".hytale_version" || "$(cat .hytale_version)" != "$HYTALE_VERSION" ]]; then
        echo "Downloading Hytale version $HYTALE_VERSION..."

        ./hytale-downloader/hytale-downloader-linux -version "$HYTALE_VERSION"

        unzip -o $HYTALE_VERSION.zip -d .

        rm $HYTALE_VERSION.zip

        echo "$HYTALE_VERSION" > .hytale_version
    else
        echo "Hytale version $HYTALE_VERSION already downloaded."
    fi
fi

/java.sh $@