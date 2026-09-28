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
xcodebuild -project Gopy.xcodeproj \
    -scheme Gopy \
    -configuration Release \
    -derivedDataPath ./DerivedData \
    -archivePath ./build/Gopy.xcarchive \
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