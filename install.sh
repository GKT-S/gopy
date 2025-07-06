#!/bin/bash

# Gopy Otomatik Kurulum Scripti
# curl -fsSL https://raw.githubusercontent.com/GKT-S/gopy/main/install.sh | bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

# Logo göster
echo -e "${BLUE}"
echo "  ╔═══════════════════════════════════════╗"
echo "  ║              📋 GOPY                   ║"
echo "  ║        Clipboard Manager              ║"
echo "  ║                                       ║"
echo "  ║        Otomatik Kurulum               ║"
echo "  ╚═══════════════════════════════════════╝"
echo -e "${NC}"


echo -e "${YELLOW}🔍 Sistem kontrol ediliyor...${NC}"


if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Hata: Bu uygulama sadece macOS'ta çalışır!${NC}"
    exit 1
fi


macos_version=$(sw_vers -productVersion | cut -d. -f1,2)
required_version="12.0"

if [[ $(echo "$macos_version >= $required_version" | bc -l) -eq 0 ]]; then
    echo -e "${RED}❌ Hata: macOS 12.0 veya üzeri gerekli! (Mevcut: $macos_version)${NC}"
    exit 1
fi

echo -e "${GREEN}✅ macOS $macos_version - Uyumlu${NC}"


TEMP_DIR="/tmp/gopy_install"
APP_DIR="/Applications"
DOWNLOAD_URL="https://github.com/GKT-S/gopy/releases/latest/download/Gopy-v1.0.0.zip"

echo -e "${YELLOW}📥 Gopy indiriliyor...${NC}"


rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"


if ! curl -fsSL "$DOWNLOAD_URL" -o "Gopy.zip"; then
    echo -e "${RED}❌ Hata: İndirme başarısız oldu!${NC}"
    echo -e "${YELLOW}💡 Manuel kurulum için: https://github.com/GKT-S/gopy/releases${NC}"
    exit 1
fi

echo -e "${GREEN}✅ İndirme tamamlandı${NC}"

echo -e "${YELLOW}📦 Paket açılıyor...${NC}"
if ! unzip -q "Gopy.zip"; then
    echo -e "${RED}❌ Hata: Paket açılamadı!${NC}"
    exit 1
fi

if [ ! -d "Gopy.app" ]; then
    echo -e "${RED}❌ Hata: Gopy.app bulunamadı!${NC}"
    exit 1
fi

echo -e "${YELLOW}🚀 Uygulama kuruluyor...${NC}"

if [ -d "$APP_DIR/Gopy.app" ]; then
    echo -e "${YELLOW}🗑️ Eski sürüm kaldırılıyor...${NC}"
    rm -rf "$APP_DIR/Gopy.app"
fi

if ! cp -R "Gopy.app" "$APP_DIR/"; then
    echo -e "${RED}❌ Hata: Kurulum başarısız oldu!${NC}"
    echo -e "${YELLOW}💡 Manuel kurulum için Applications klasörüne sürükleyin${NC}"
    exit 1
fi

xattr -d com.apple.quarantine "$APP_DIR/Gopy.app" 2>/dev/null || true

echo -e "${GREEN}✅ Kurulum tamamlandı!${NC}"

cd /
rm -rf "$TEMP_DIR"

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

echo -e "${YELLOW}🤔 Gopy'yi şimdi başlatmak ister misiniz? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}🚀 Gopy başlatılıyor...${NC}"
    open "$APP_DIR/Gopy.app"
    
    sleep 3
    
    echo -e "${BLUE}💡 Menu bar'da 'G' ikonuna tıklayarak Gopy'yi kullanabilirsiniz!${NC}"
fi

echo -e "${GREEN}✨ Gopy'yi kullandığınız için teşekkürler!${NC}"
echo -e "${BLUE}🌟 Proje faydalı olduysa GitHub'da yıldız vermeyi unutmayın!${NC}"
echo -e "${YELLOW}🐛 Sorun mu var? GitHub Issues'da bildirin: https://github.com/GKT-S/gopy/issues${NC}" 