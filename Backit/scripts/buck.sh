#!/bin/bash
echo "Building..."
output=$(buck build backit --config="cxx.default_platform=iphonesimulator-x86_64" 2>&1)
#buck build bkfoundation --config="cxx.default_platform=iphoneos-arm64"

# TODO: Only work on the static libs that were changed. This shoudl be possible as we can access which files were outputed.

prjdir="$PROJECT_DIR"
if [ "$PROJECT_DIR" == "" ]; then
    prjdir="."
fi
libdir="$prjdir/Libraries"

# TODO: Only lipo required archs. This avoids creating static libs for archs that do not need to be included in some builds.
# Options: DEVICE SIMULATOR
build_archs="arch64 x86_64"

# TODO: These libs could be created automatically from a list provided by the output of 'buck build'
libs="BackitApp BKFoundation"
for lib in $libs; do
    echo "Creating library for: $lib..."
    # Make {Library}.swiftmodule to store all arch swiftmidules
    mkdir -p "$libdir/$lib.swiftmodule"
    # Copy static libs, and respective modulemaps, to library directory
    files=`find $prjdir/buck-out/gen -name "$lib.swiftmodule"`
    for file in $files; do
        # Move arch swiftmodules
        # Takes a path 'MyLibrary#apple-swift-compile,iphonesimulator-x86_64/MyLibrary.swiftmodule' and returns 'x86_64'
        arch=`echo "$file" | cut -d , -f 2 | cut -d - -f 2 | cut -d / -f 1`
        cp "$file" "$libdir/$lib.swiftmodule/$arch.swiftmodule"
    done
    libname="lib$lib.a"
    # Finds files like 'libMyModule.a' and creates fat binary from them
    files=`find $prjdir/buck-out/gen -name "$libname"`
    lipo -create $files -output "$libdir/$libname"
done

exit 0
