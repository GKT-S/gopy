#!/bin/bash

# Gopy Release Build Script
# Bu script, GitHub Release için hazır .app dosyası oluşturur

VERSION=$(grep -m1 "MARKETING_VERSION" Gopy.xcodeproj/project.pbxproj | sed 's/.*= *\(.*\);/\1/')
ZIP_NAME="Gopy-v${VERSION}.zip"

echo "🚀 Gopy v${VERSION} Release Build başlatılıyor..."

# Proje dizinini kontrol et
if [ ! -f "Gopy.xcodeproj/project.pbxproj" ]; then
    echo "❌ Hata: Gopy.xcodeproj bulunamadı!"
    echo "Bu scripti proje kök dizininde çalıştırın."
    exit 1
fi

# Build klasörünü temizle
echo "🧹 Eski build dosyalarını temizleniyor..."
rm -rf build/
rm -rf DerivedData/

# Release build yap
echo "🔨 Release build yapılıyor..."
# Release, geliştirici sertifikası olmadan ad-hoc imzalanır: development
# provisioning profile sadece kayıtlı cihazlarda açılır. App group izni
# (widget için) profile gerektirdiğinden release'ten çıkarılır.
mkdir -p build
RELEASE_ENTITLEMENTS="$PWD/build/Release.entitlements"
cp Gopy/Gopy.entitlements "$RELEASE_ENTITLEMENTS"
/usr/libexec/PlistBuddy -c "Delete :com.apple.security.application-groups" "$RELEASE_ENTITLEMENTS" 2>/dev/null || true

xcodebuild -project Gopy.xcodeproj \
    -scheme Gopy \
    -configuration Release \
    -derivedDataPath ./DerivedData \
    -archivePath ./build/Gopy.xcarchive \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGN_STYLE=Manual \
    DEVELOPMENT_TEAM="" \
    PROVISIONING_PROFILE_SPECIFIER="" \
    CODE_SIGN_ENTITLEMENTS="$RELEASE_ENTITLEMENTS" \
    archive

# Export edilen app'i kontrol et
if [ ! -d "./build/Gopy.xcarchive/Products/Applications/Gopy.app" ]; then
    echo "❌ Build başarısız oldu!"
    exit 1
fi

# Build klasörünü oluştur
mkdir -p build

# App'i kopyala
echo "📦 App dosyası hazırlanıyor..."
cp -R "./build/Gopy.xcarchive/Products/Applications/Gopy.app" "./build/"

# Zip dosyası oluştur
echo "🗜️ Zip dosyası oluşturuluyor..."
cd build
ditto -c -k --keepParent "Gopy.app" "${ZIP_NAME}"
cd ..

# Checksum oluştur
echo "🔐 Checksum hesaplanıyor..."
shasum -a 256 build/${ZIP_NAME} > build/${ZIP_NAME}.sha256

echo "✅ Release build tamamlandı!"
echo "📂 Dosyalar build/ klasöründe:"
ls -la build/

echo ""
echo "🎉 GitHub Release için hazır dosyalar:"
echo "   - Gopy.app (Uygulama)"
echo "   - ${ZIP_NAME} (Zip dosyası)"
echo "   - ${ZIP_NAME}.sha256 (Checksum)"
echo ""
echo "🔗 GitHub'da Release oluşturmak için:"
echo "   1. GitHub repository'nize gidin"
echo "   2. 'Releases' sekmesine tıklayın"
echo "   3. 'Create a new release' butonuna tıklayın"
echo "   4. build/${ZIP_NAME} dosyasını upload edin" 