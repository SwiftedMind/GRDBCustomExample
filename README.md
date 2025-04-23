# Install GRDB with Custom SQLite Build

## Add GRDB and SQLiteLib
To make versioning more convenient, we will add GRDB and SQLiteLib as subtrees to our app repository. That way we can easily update them, but all the files are actually inside the app repository, so CLIs and stuff have easy access to them.

Go to your **app project's** directory and run the following commands:
```bash
git remote add grdb https://github.com/groue/GRDB.swift.git
git fetch grdb --tags
git subtree add --prefix GRDB grdb v7.4.1 --squash
```

This will create a new folder `GRDB` in your project. Next, we will add SQLiteLib as subtree:

```bash
rm -rf GRDB/SQLiteCustom/src

# Must clear the working directory before adding new subtrees, so we commit the changes
git add -u GRDB/SQLiteCustom/src
git commit -m "Remove placeholder SQLiteCustom/src"

git remote add sqlite-custom https://github.com/swiftlyfalling/SQLiteLib.git
git fetch sqlite-custom --tags
git subtree add --prefix GRDB/SQLiteCustom/src sqlite-custom master --squash
```

Now, the SQLiteLib repository will be in `GRDB/SQLiteCustom/src`.

Later, we can update both subtrees like this:

```bash
# GRDB
git fetch grdb --tags
git subtree pull --prefix GRDB grdb v7.5.0 --squash

# B. SQLiteLib
git fetch sqlite-custom --tags
git subtree pull --prefix GRDB/SQLiteCustom/src sqlite-custom master --squash

```

## Add GRDB to Your App Project

Follow the [official guide](https://github.com/groue/GRDB.swift/blob/master/Documentation/CustomSQLiteBuilds.md), starting with step 2 (since we've already completed step 1 above, using subtrees).

One note: Step 5 says to "embed" the `GRDBCustom.xcodeproj` project in your own project. This simply means dragging that file (not the entire directory) into your app project as reference. Then it will show up in your **Target Dependencies** in step 5.

That's it! Now you can use `GRDB` in your app project.

## Use In Swift Package

To use `GRDB` in a local Swift package, the approach above does not work. You need to compile `GRDBCustom` and create a .xcframework file that you can pass to the package as binary target. To do this, remove the pre-action build phase from the guide (which copies the configuration files into the GRDBCustom directory) and then remove `GRDBCustom` from the "Target Dependencies", and the "Embedded Binaries" (in the General tab). We don't want the project to link to or build this anymore.

Instead, create a `build_GRDB_binary.sh` file in the root directory of your project, put the following code in it and adjust the paths to your setup:

```bash
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
```

Run this script via terminal whenever you have pulled a new GRDB version and it will generate a new binary file in `Generated/GRDB.xcframework`.
