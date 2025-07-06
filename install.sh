#!/bin/bash

# Gopy Otomatik Kurulum Scripti
# curl -fsSL https://raw.githubusercontent.com/yourusername/gopy/main/install.sh | bash

set -e

# Renkli çıktı için
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logo göster
echo -e "${BLUE}"
echo "  ╔═══════════════════════════════════════╗"
echo "  ║              📋 GOPY                   ║"
echo "  ║        Clipboard Manager              ║"
echo "  ║                                       ║"
echo "  ║        Otomatik Kurulum               ║"
echo "  ╚═══════════════════════════════════════╝"
echo -e "${NC}"

# Sistem kontrolü
echo -e "${YELLOW}🔍 Sistem kontrol ediliyor...${NC}"

# macOS kontrolü
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Hata: Bu uygulama sadece macOS'ta çalışır!${NC}"
    exit 1
fi

# macOS versiyonu kontrolü
macos_version=$(sw_vers -productVersion | cut -d. -f1,2)
required_version="12.0"

if [[ $(echo "$macos_version >= $required_version" | bc -l) -eq 0 ]]; then
    echo -e "${RED}❌ Hata: macOS 12.0 veya üzeri gerekli! (Mevcut: $macos_version)${NC}"
    exit 1
fi

echo -e "${GREEN}✅ macOS $macos_version - Uyumlu${NC}"

# Geçici klasör oluştur
TEMP_DIR="/tmp/gopy_install"
APP_DIR="/Applications"
DOWNLOAD_URL="https://github.com/yourusername/gopy/releases/latest/download/Gopy-v1.0.0.zip"

echo -e "${YELLOW}📥 Gopy indiriliyor...${NC}"

# Geçici klasörü temizle ve oluştur
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# En son sürümü indir
if ! curl -fsSL "$DOWNLOAD_URL" -o "Gopy.zip"; then
    echo -e "${RED}❌ Hata: İndirme başarısız oldu!${NC}"
    echo -e "${YELLOW}💡 Manuel kurulum için: https://github.com/yourusername/gopy/releases${NC}"
    exit 1
fi

echo -e "${GREEN}✅ İndirme tamamlandı${NC}"

# Zip dosyasını aç
echo -e "${YELLOW}📦 Paket açılıyor...${NC}"
if ! unzip -q "Gopy.zip"; then
    echo -e "${RED}❌ Hata: Paket açılamadı!${NC}"
    exit 1
fi

# Gopy.app'in var olduğunu kontrol et
if [ ! -d "Gopy.app" ]; then
    echo -e "${RED}❌ Hata: Gopy.app bulunamadı!${NC}"
    exit 1
fi

# Applications klasörüne kopyala
echo -e "${YELLOW}🚀 Uygulama kuruluyor...${NC}"

# Eski sürümü kaldır (varsa)
if [ -d "$APP_DIR/Gopy.app" ]; then
    echo -e "${YELLOW}🗑️ Eski sürüm kaldırılıyor...${NC}"
    rm -rf "$APP_DIR/Gopy.app"
fi

# Yeni sürümü kopyala
if ! cp -R "Gopy.app" "$APP_DIR/"; then
    echo -e "${RED}❌ Hata: Kurulum başarısız oldu!${NC}"
    echo -e "${YELLOW}💡 Manuel kurulum için Applications klasörüne sürükleyin${NC}"
    exit 1
fi

# Quarantine attribute'unu kaldır (macOS güvenlik)
xattr -d com.apple.quarantine "$APP_DIR/Gopy.app" 2>/dev/null || true

echo -e "${GREEN}✅ Kurulum tamamlandı!${NC}"

# Temizlik yap
cd /
rm -rf "$TEMP_DIR"

# Kullanıcıya bilgi ver
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                      🎉 KURULUM TAMAMLANDI                    ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║                                                               ║"
echo "║  📍 Konum: /Applications/Gopy.app                            ║"
echo "║                                                               ║"
echo "║  🚀 Başlatmak için:                                          ║"
echo "║     • Spotlight'ta 'Gopy' yazın (Cmd+Space)                 ║"
echo "║     • Applications klasöründe Gopy'ye çift tıklayın         ║"
echo "║                                                               ║"
echo "║  🔧 İlk çalıştırma:                                          ║"
echo "║     • Sistem Tercihleri → Güvenlik → Erişilebilirlik        ║"
echo "║     • Gopy'yi etkinleştirin                                  ║"
echo "║                                                               ║"
echo "║  📋 Menu bar'da 'G' ikonu görünecek                          ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Kullanıcının isteğiyle uygulamayı başlat
echo -e "${YELLOW}🤔 Gopy'yi şimdi başlatmak ister misiniz? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}🚀 Gopy başlatılıyor...${NC}"
    open "$APP_DIR/Gopy.app"
    
    # 3 saniye bekle
    sleep 3
    
    echo -e "${BLUE}💡 Menu bar'da 'G' ikonuna tıklayarak Gopy'yi kullanabilirsiniz!${NC}"
fi

echo -e "${GREEN}✨ Gopy'yi kullandığınız için teşekkürler!${NC}"
echo -e "${BLUE}🌟 Proje faydalı olduysa GitHub'da yıldız vermeyi unutmayın!${NC}"
echo -e "${YELLOW}🐛 Sorun mu var? GitHub Issues'da bildirin: https://github.com/yourusername/gopy/issues${NC}" 