#!/bin/bash

#######################################################
#                   PROJECT PATHS
#  !! MODIFY THESE TO MATCH YOUR PROJECT HIERARCHY !!
#  Paths are relative to the location of this script.
#######################################################

# The path to the folder containing GRDBCustom.xcodeproj:
GRDB_SOURCE_PATH="GRDB"

# The path to your custom "SQLiteLib-USER.xcconfig":
SQLITELIB_XCCONFIG_USER_PATH="GRDBCustomSQLite/SQLiteLib-USER.xcconfig"

# The path to your custom "GRDBCustomSQLite-USER.xcconfig":
CUSTOMSQLITE_XCCONFIG_USER_PATH="GRDBCustomSQLite/GRDBCustomSQLite-USER.xcconfig"

# The path to your custom "GRDBCustomSQLite-USER.h":
CUSTOMSQLITE_H_USER_PATH="GRDBCustomSQLite/GRDBCustomSQLite-USER.h"

# The name of the .framework output file (We usually want GRDB.framework)
FRAMEWORK_NAME="GRDB"

# The directory in which the .framework file will be placed (must be reachable for the Swift Package)
OUTPUT_PATH="Generated"

# Build configuration. Usually Release is fine.
CONFIGURATION="Release"

#######################################################
#
#######################################################

# The path to the GRDBCustom.xcodeproj file
GRDB_PROJECT_PATH="${GRDB_SOURCE_PATH}/GRDBCustom.xcodeproj"

# The scheme that builds GRDBCustom
GRDB_SCHEME_NAME="GRDBCustom"

# Create a temporary build location
BUILD_DIR="$(mktemp -d)/Build"

#######################################################
#
#######################################################

# Helper function to copy over the configuration files
copy_config_file() {
    local source_file="$1"
    local dest_path="$2"
    local full_source="${source_file}"
    local full_dest="${dest_path}"

    if [ ! -f "$full_source" ]; then
        echo "error: Source configuration file missing: $full_source"
        exit 1
    fi

    echo "  Copying ${source_file} to ${dest_path}"
    # Create destination directory if it doesn't exist
    mkdir -p "$(dirname "$full_dest")"
    # Copy file preserving metadata
    cp -p "$full_source" "$full_dest"
}

#######################################################
#
#######################################################

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Sync Custom Config Files ---

echo "Syncing custom configuration files..."

# Define source file names and their destination paths within FRAMEWORK_PROJ_DIR
copy_config_file "${SQLITELIB_XCCONFIG_USER_PATH}" "${GRDB_SOURCE_PATH}/SQLiteCustom/src/SQLiteLib-USER.xcconfig"
copy_config_file "${CUSTOMSQLITE_XCCONFIG_USER_PATH}" "${GRDB_SOURCE_PATH}/SQLiteCustom/GRDBCustomSQLite-USER.xcconfig"
copy_config_file "${CUSTOMSQLITE_H_USER_PATH}" "${GRDB_SOURCE_PATH}/SQLiteCustom/GRDBCustomSQLite-USER.h"

echo "✓ Finished syncing configuration files."

# --- End Sync ---

echo "--- Building XCFramework for ${FRAMEWORK_NAME} ---"
echo "Framework Project: ${GRDB_PROJECT_PATH}"
echo "Output Directory: ${OUTPUT_PATH}"
echo "Build Directory: ${BUILD_DIR}"
echo "Configuration: ${CONFIGURATION}"

# Ensure output directory exists
mkdir -p "${OUTPUT_PATH}"

# Derive archive paths
BASE_ARCHIVE_PATH="${BUILD_DIR}/${FRAMEWORK_NAME}-${CONFIGURATION}"
IOS_DEVICE_ARCHIVE_PATH="${BASE_ARCHIVE_PATH}-iphoneos.xcarchive"
IOS_SIMULATOR_ARCHIVE_PATH="${BASE_ARCHIVE_PATH}-iphonesimulator.xcarchive"

# Clean previous builds (optional, but recommended)
rm -rf "${IOS_DEVICE_ARCHIVE_PATH}" "${IOS_SIMULATOR_ARCHIVE_PATH}"
rm -rf "${OUTPUT_PATH}/${FRAMEWORK_NAME}.xcframework"

echo "Archiving for iOS Device..."
xcodebuild archive \
    -project "${GRDB_PROJECT_PATH}" \
    -scheme "${GRDB_SCHEME_NAME}" \
    -configuration "${CONFIGURATION}" \
    -destination "generic/platform=iOS" \
    -archivePath "${IOS_DEVICE_ARCHIVE_PATH}" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "Archiving for iOS Simulator..."
xcodebuild archive \
    -project "${GRDB_PROJECT_PATH}" \
    -scheme "${GRDB_SCHEME_NAME}" \
    -configuration "${CONFIGURATION}" \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "${IOS_SIMULATOR_ARCHIVE_PATH}" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework "${IOS_DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -framework "${IOS_SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -output "${OUTPUT_PATH}/${FRAMEWORK_NAME}.xcframework"

echo "✓ XCFramework created at: ${OUTPUT_PATH}/${FRAMEWORK_NAME}.xcframework"
echo "--- XCFramework script finished ---"
