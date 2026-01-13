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
		echo "starting hytale downloader..."
    fi
else
    echo "hytale-downloader updated."
fi

# use to get newest credentials
./hytale-downloader/hytale-downloader-linux -print-version

if [ -f ".hytale-downloader-credentials.json" ]; then
    echo "Reading access_token from credentials file"
    
    # Simple extraction using grep and sed
    if HYTALE_SERVER_ACCESS_TOKEN=$(grep -o '"access_token":"[^"]*"' .hytale-downloader-credentials.json | head -1 | sed 's/"access_token":"\([^"]*\)"/\1/'); then
        if [ -n "$HYTALE_SERVER_ACCESS_TOKEN" ]; then
            echo "Using access_token from credentials file"
        else
            echo "access_token not found in credentials file not authenticated"
        fi
    fi
fi

# If HYTALE_SERVER_SESSION_TOKEN isn't set, assume the user will log in themselves, rather than a host's GSP
if [[ -z "$HYTALE_SERVER_SESSION_TOKEN" || "$HYTALE_SERVER_ACCESS_TOKEN" == "null" ]]; then
	echo "starting hytale..."
    
    # Example "2026.01.13-dcad8778f"
    HYTALE_VERSION=$(./hytale-downloader/hytale-downloader-linux -print-version)

    # check if version file exists and matches
    if [[ ! -f ".hytale_version" || "$(cat .hytale_version)" != "$HYTALE_VERSION" ]]; then
        echo "Downloading Hytale version $HYTALE_VERSION..."

        ./hytale-downloader/hytale-downloader-linux -patchline "$HYTALE_PATCHLINE" -download-path "$HYTALE_VERSION.zip"

        unzip -o $HYTALE_VERSION.zip -d .

        rm $HYTALE_VERSION.zip

        echo "$HYTALE_VERSION" > .hytale_version
    else
        echo "Hytale version $HYTALE_VERSION already downloaded."
    fi
fi

/java.sh $@