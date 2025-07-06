#!/bin/bash
echo "🔨 Gopy uygulaması derleniyor..."
xcodebuild -project Gopy.xcodeproj -scheme Gopy -configuration Debug > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Derleme başarılı! Uygulama açılıyor..."
    open ~/Library/Developer/Xcode/DerivedData/Gopy-*/Build/Products/Debug/Gopy.app
else
    echo "❌ Derleme hatası! Lütfen Xcode'da kontrol edin."
    exit 1
fi 