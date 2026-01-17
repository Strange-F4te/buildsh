#!/bin/bash

# Automatic cleanup
echo "Performing cleanup..."
rm -rf .repo/local_manifests/
rm -rf device/infinix
rm -rf vendor/infinix
echo "Cleanup completed."
echo ""

# Initialize the ROM source repository
repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --git-lfs --no-clone-bundle
if [ $? -ne 0 ]; then
    echo "Repo initialization failed. Exiting."
    exit 1
fi
echo "================="
echo "Repo init success"
echo "================="


# Clone local manifests
git clone https://github.com/Strange-F4te/device_infinix_X6882 device/infinix/X6882 
git clone https://github.com/Strange-F4te/kernel_infinix_X6882 device/infinix/X6882-kernel 
git clone https://github.com/Strange-F4te/vendor_infinix_X6882 vendor/infinix/X6882 
git clone https://github.com/Strange-F4te/hardware_transsion hardware/transsion 
git clone https://github.com/Strange-F4te/hardware_mediatek hardware/mediatek 
git clone https://github.com/techyminati/android_vendor_mediatek_ims vendor/mediatek/ims
git clone https://github.com/TogoFire/packages_apps_ViPER4AndroidFX packages/apps/ViPER4AndroidFX 
git clone https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr device/mediatek/sepolicy_vndr 
if [ $? -ne 0 ]; then
    echo "Failed to clone tree source. Exiting."
    exit 1
fi
echo "============================"
echo "Tree Source clone success"
echo "============================"
echo ""

# Sync the repositories using the Crave sync script
/opt/crave/resync.sh
if [ $? -ne 0 ]; then
    echo "Crave sync failed. Exiting."
    exit 1
fi
echo "============================"
echo "Crave sync success"
echo "============================"
echo ""

# Build environment setup
. build/envsetup.sh
export BUILD_USERNAME=F4T3
export BUILD_HOSTNAME=Miracleprjkt
export ALLOW_MISSING_DEPENDENCIES=true
export BUILD_BROKEN_MISSING_REQUIRED_MODULES=true

# Build the ROM
breakfast X6882
if [ $? -ne 0 ]; then
    echo "Build failed. Exiting."
    exit 1
fi

brunch X6882
if [ $? -ne 0 ]; then
    echo "Installclean failed. Exiting."
    exit 1
fi

echo "============================"
echo "Build process completed successfully!"
echo "============================"

# Upload ROM zip file to PixelDrain
ROM_DIR="out/target/product/X6882/"
ROM_NAME=$(ls $ROM_DIR | grep "*.zip$" | tail -n 1)

if [ -n "$ROM_NAME" ]; then
    ROM_PATH="$ROM_DIR$ROM_NAME"
    echo "Uploading ROM file to PixelDrain..."
    curl -T "$ROM_PATH" -u :ee28f852-4cfe-420e-96bd-6fa8ba1a3905 https://pixeldrain.com/api/file/
    if [ $? -eq 0 ]; then
        echo "ROM uploaded successfully to PixelDrain!"
    else
        echo "Failed to upload ROM to PixelDrain. Check your network or credentials."
    fi
else
    echo "ROM file not found. Upload skipped."
fi

echo "============================"
echo "Script completed!"
echo "============================"
