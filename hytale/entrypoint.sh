#!/bin/bash
set -e

cd /home/container

HYTALE_DOWNLOADER_DIR="./hytale-downloader"
HYTALE_DOWNLOADER_BIN="$HYTALE_DOWNLOADER_DIR/hytale-downloader-linux"
DOWNLOAD_URL="https://downloader.hytale.com/hytale-downloader.zip"

# Function to check if hytale-downloader needs update
check_downloader_update() {
    echo "[INFO] Checking hytale-downloader status..."
    
    # If directory doesn't exist, definitely need to download
    if [ ! -d "$HYTALE_DOWNLOADER_DIR" ]; then
        echo "[INFO] hytale-downloader directory not found"
        return 0  # Needs download
    fi
    
    # If binary doesn't exist, need to download
    if [ ! -f "$HYTALE_DOWNLOADER_BIN" ]; then
        echo "[INFO] hytale-downloader binary not found"
        return 0  # Needs download
    fi
    
    # Check if binary is executable
    if [ ! -x "$HYTALE_DOWNLOADER_BIN" ]; then
        echo "[INFO] hytale-downloader binary is not executable"
        return 0  # Needs download/reconfiguration
    fi
    
    # Try to check for updates
    echo "[INFO] Checking for hytale-downloader updates..."
    local update_output
    if update_output=$("$HYTALE_DOWNLOADER_BIN" -check-update 2>&1); then
        if [[ "$update_output" == *"is up to date"* ]]; then
            echo "[INFO] hytale-downloader is up to date"
            return 1  # Does not need update
        else
            echo "[INFO] hytale-downloader update available: $update_output"
            return 0  # Needs update
        fi
    else
        echo "[WARNING] Failed to check hytale-downloader update status: $update_output"
        echo "[INFO] Assuming hytale-downloader needs update"
        return 0  # Needs update on error
    fi
}

# Download and setup hytale-downloader if needed
if check_downloader_update; then
    echo "[INFO] Updating/downloading hytale-downloader..."
    
    # Clean up existing files
    echo "[INFO] Cleaning up existing hytale-downloader files..."
    rm -f hytale-downloader.zip
    rm -rf "$HYTALE_DOWNLOADER_DIR"
    
    # Download new version
    echo "[INFO] Downloading hytale-downloader from: $DOWNLOAD_URL"
    if curl -s -o hytale-downloader.zip "$DOWNLOAD_URL"; then
        if [ -f "hytale-downloader.zip" ]; then
            echo "[INFO] Download completed successfully"
            echo "[INFO] Extracting hytale-downloader..."
            
            # Extract and rename binary
            if unzip -q hytale-downloader.zip -d hytale-downloader; then
                echo "[INFO] Extraction completed"
                
                # Move and set permissions
                if [ -f "hytale-downloader/hytale-downloader-linux-amd64" ]; then
                    mv hytale-downloader/hytale-downloader-linux-amd64 "$HYTALE_DOWNLOADER_BIN"
                    echo "[INFO] Binary moved to: $HYTALE_DOWNLOADER_BIN"
                else
                    echo "[ERROR] Expected binary file not found in archive"
                    exit 1
                fi
                
                # Set execution permissions
                chmod 555 "$HYTALE_DOWNLOADER_BIN"
                echo "[INFO] Execution permissions set"
                
                # Verify binary works
                if "$HYTALE_DOWNLOADER_BIN" -version >/dev/null 2>&1; then
                    echo "[INFO] hytale-downloader verified and ready"
                else
                    echo "[ERROR] hytale-downloader binary verification failed"
                    exit 1
                fi
            else
                echo "[ERROR] Failed to extract hytale-downloader.zip"
                exit 1
            fi
        else
            echo "[ERROR] Downloaded file not found: hytale-downloader.zip"
            exit 1
        fi
    else
        echo "[ERROR] Failed to download hytale-downloader"
        exit 1
    fi
else
    echo "[INFO] hytale-downloader is already up to date"
fi

# Handle Hytale game download if no session token (manual mode)
if [[ -z "$HYTALE_SERVER_SESSION_TOKEN" ]]; then
    echo "[INFO] Starting Hytale server setup..."
    
    # Get current Hytale version
    echo "[INFO] Retrieving Hytale version from downloader..."
    HYTALE_VERSION=$("$HYTALE_DOWNLOADER_BIN" -print-version 2>/dev/null)
    
    if [ -z "$HYTALE_VERSION" ]; then
        echo "[ERROR] Failed to retrieve Hytale version"
        exit 1
    fi
    
    echo "[INFO] Detected Hytale version: $HYTALE_VERSION"
    
    VERSION_FILE=".hytale_version"
    NEED_DOWNLOAD=0
    
    # Check if version file exists and matches
    if [ ! -f "$VERSION_FILE" ]; then
        echo "[INFO] Version file not found: $VERSION_FILE"
        NEED_DOWNLOAD=1
    elif [ "$(cat "$VERSION_FILE" 2>/dev/null)" != "$HYTALE_VERSION" ]; then
        echo "[INFO] Version mismatch: local=$(cat "$VERSION_FILE"), remote=$HYTALE_VERSION"
        NEED_DOWNLOAD=1
    else
        echo "[INFO] Hytale version $HYTALE_VERSION already downloaded"
    fi
    
    # Download if needed
    if [ $NEED_DOWNLOAD -eq 1 ]; then
        echo "[INFO] Downloading Hytale version: $HYTALE_VERSION"
        echo "[INFO] Using patchline: ${HYTALE_PATCHLINE:-default}"
        
        ZIP_FILE="$HYTALE_VERSION.zip"
        
        # Download game files
        if "$HYTALE_DOWNLOADER_BIN" -patchline "${HYTALE_PATCHLINE}" -download-path "$ZIP_FILE"; then
            echo "[INFO] Hytale download completed"
            
            # Extract game files
            echo "[INFO] Extracting Hytale files..."
            if unzip -o "$ZIP_FILE" -d .; then
                echo "[INFO] Extraction completed successfully"
                
                # Clean up zip file
                rm "$ZIP_FILE"
                echo "[INFO] Cleaned up temporary download file"
                
                # Update version file
                echo "$HYTALE_VERSION" > "$VERSION_FILE"
                echo "[INFO] Updated version file: $VERSION_FILE"
            else
                echo "[ERROR] Failed to extract Hytale files"
                exit 1
            fi
        else
            echo "[ERROR] Failed to download Hytale version: $HYTALE_VERSION"
            exit 1
        fi
    fi
else
    echo "[INFO] HYTALE_SERVER_SESSION_TOKEN set, skipping manual download"
fi

# Start the server
echo "[INFO] Starting Java runtime..."
exec /java.sh "$@"