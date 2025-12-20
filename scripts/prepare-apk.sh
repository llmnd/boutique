#!/bin/bash

# Build script for Koyeb deployment
# Copy APK to accessible location before starting server

echo "📦 Preparing APK for deployment..."

# Create downloads directory in public build
mkdir -p ./build/web/downloads

# Copy APK if it exists locally (for development)
if [ -f "./public/downloads/boutique-mobile.apk" ]; then
  cp ./public/downloads/boutique-mobile.apk ./build/web/downloads/
  echo "✅ APK copied to build/web/downloads"
fi

# Create a simple APK info endpoint response
echo "APK deployment ready"
