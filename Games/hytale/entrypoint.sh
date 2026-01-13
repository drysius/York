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

# Initialize variables
HYTALE_SERVER_ACCESS_TOKEN=""
HYTALE_SESSION_TOKEN=""
HYTALE_IDENTITY_TOKEN=""
HYTALE_PROFILE_UUID=""

# Check for existing credentials
if [ -f ".hytale-downloader-credentials.json" ]; then
    echo "Reading access_token from credentials file"
    
    # Simple extraction using grep and sed
    if HYTALE_ACCESS_TOKEN=$(grep -o '"access_token":"[^"]*"' .hytale-downloader-credentials.json | head -1 | sed 's/"access_token":"\([^"]*\)"/\1/'); then
        if [ -n "$HYTALE_ACCESS_TOKEN" ]; then
            echo "Using access_token from credentials file"
            HYTALE_SERVER_ACCESS_TOKEN="$HYTALE_ACCESS_TOKEN"
        else
            echo "access_token not found in credentials file"
        fi
    fi
fi

# Get session if we have an access token
if [ -n "$HYTALE_SERVER_ACCESS_TOKEN" ] && [ "$HYTALE_SERVER_ACCESS_TOKEN" != "null" ]; then
    echo "Fetching game profiles..."

    PROFILES_DATA=$(curl -s -X GET "https://account-data.hytale.com/my-account/get-profiles" -H "Authorization: Bearer $HYTALE_SERVER_ACCESS_TOKEN")

    # Check if profiles list is empty
    PROFILES_COUNT=$(echo "$PROFILES_DATA" | jq '.profiles | length')

    if [ "$PROFILES_COUNT" -eq 0 ]; then
        echo "Error: No game profiles found. You need to purchase Hytale to run a server."
        exit 1
    fi

    HYTALE_PROFILE_UUID=$(echo "$PROFILES_DATA" | jq -r '.profiles[0].uuid')
    HYTALE_PROFILE_USERNAME=$(echo "$PROFILES_DATA" | jq -r '.profiles[0].username')

    echo "✓ Profile: $HYTALE_PROFILE_USERNAME (UUID: $HYTALE_PROFILE_UUID)"
    echo "Creating game server session..."

    SESSION_RESPONSE=$(curl -s -X POST "https://sessions.hytale.com/game-session/new" \
      -H "Authorization: Bearer $HYTALE_SERVER_ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"uuid\": \"${HYTALE_PROFILE_UUID}\"}")

    # Validate JSON response
    if ! echo "$SESSION_RESPONSE" | jq empty 2>/dev/null; then
        echo "Error: Invalid JSON response from game session creation"
        echo "Response: $SESSION_RESPONSE"
        exit 1
    fi

    # Extract session and identity tokens
    HYTALE_SESSION_TOKEN=$(echo "$SESSION_RESPONSE" | jq -r '.sessionToken')
    HYTALE_IDENTITY_TOKEN=$(echo "$SESSION_RESPONSE" | jq -r '.identityToken')

    if [ -z "$HYTALE_SESSION_TOKEN" ] || [ "$HYTALE_SESSION_TOKEN" = "null" ]; then
        echo "Error: Failed to create game server session"
        echo "Response: $SESSION_RESPONSE"
        exit 1
    fi

    echo "✓ Game server session created successfully!"
fi

# If HYTALE_SESSION_TOKEN isn't set, assume the user will log in themselves
if [[ -z "$HYTALE_SESSION_TOKEN" || "$HYTALE_SERVER_ACCESS_TOKEN" == "null" ]]; then
	echo "Starting hytale without authentication..."
    
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

# Check if we have all required tokens for authenticated mode
if [[ -z "$HYTALE_SESSION_TOKEN" || -z "$HYTALE_IDENTITY_TOKEN" || -z "$HYTALE_PROFILE_UUID" ]]; then
    echo "Starting Hytale without session tokens..."
    # Start without authentication
    exec /java.sh "$@"
else
    echo "Starting Hytale with authentication..."
    # Start with authentication tokens
    exec /java.sh "$@" --session-token "${HYTALE_SESSION_TOKEN}" --identity-token "${HYTALE_IDENTITY_TOKEN}" --owner-uuid "${HYTALE_PROFILE_UUID}"
fi