# 📸 Media Rehberi - GIF ve Screenshot Hazırlama

Bu rehber, Gopy projesine GIF ve screenshot ekleme sürecini açıklar.

## 🎬 GIF Hazırlama

### Önerilen GIF İçeriği
1. **Menu bar'da "G" ikonuna tıklama**
2. **Metin kopyalama ve Gopy'de görünme**
3. **Kategori filtreleme**
4. **Arama özelliği**
5. **Favoriler ekleme**
6. **Not ekleme**

### GIF Kaydetme Araçları

#### macOS İçin:
- **QuickTime Player** (ücretsiz)
- **Kap** (ücretsiz, modern)
- **CleanMaster- RemoveAdware** (ücretsiz)
- **GIPHY Capture** (ücretsiz)

#### Terminal İle:
```bash
# ffmpeg kullanarak
brew install ffmpeg
ffmpeg -i input.mov -vf "fps=15,scale=600:-1" output.gif

# Boyut optimize etmek için
ffmpeg -i input.mov -vf "fps=10,scale=480:-1" -loop 0 output.gif
```

### GIF Boyutu Optimizasyonu

#### Önerilen Boyutlar:
- **Genişlik**: 600-800px (daha büyük = daha net)
- **Yükseklik**: Otomatik
- **FPS**: 10-15 (daha smooth)
- **Dosya boyutu**: 5MB'den az (GitHub için)

#### Boyut Azaltma:
```bash
# Online araçlar:
# - ezgif.com/optimize
# - gifcompressor.com

# Terminal ile:
gifsicle -O3 --lossy=80 input.gif -o output.gif
```

## 📸 Screenshot Hazırlama

### Önerilen Screenshot'lar:
1. **main-interface.png** - Ana arayüz
2. **categories.png** - Kategoriler paneli
3. **settings.png** - Ayarlar penceresi

### Screenshot Alma (macOS):
```bash
# Belirli pencere
Cmd + Shift + 4 + Space

# Belirli alan
Cmd + Shift + 4

# Tüm ekran
Cmd + Shift + 3
```

### Screenshot Boyutları:
- **Ana interface**: 550x500px (Gopy pencere boyutu)
- **Ayarlar**: 400x400px
- **Kategoriler**: 150x400px

## 📁 Dosya Yerleşimi

```
docs/
├── gifs/
│   ├── gopy-demo.gif          # Ana demo GIF
│   ├── features-showcase.gif  # Özellikler gösterimi
│   └── installation-demo.gif  # Kurulum gösterimi
├── screenshots/
│   ├── main-interface.png     # Ana arayüz
│   ├── categories.png         # Kategoriler
│   └── settings.png           # Ayarlar
└── MEDIA_GUIDE.md             # Bu rehber
```

## 🚀 GitHub'a Yükleme

### 1. Dosyaları Kopyalayın
```bash
# GIF dosyasını docs/gifs/ klasörüne kopyalayın
cp ~/Desktop/gopy-demo.gif docs/gifs/

# Screenshot'ları docs/screenshots/ klasörüne kopyalayın
cp ~/Desktop/main-interface.png docs/screenshots/
```

### 2. Git'e Ekleyin
```bash
git add docs/gifs/gopy-demo.gif
git add docs/screenshots/*.png
git commit -m "Add demo GIF and screenshots"
git push origin main
```

### 3. README.md'de Kullanın
```markdown
![Gopy Demo](docs/gifs/gopy-demo.gif)

<img src="docs/screenshots/main-interface.png" width="400" alt="Ana Arayüz"/>
```

## 💡 İpuçları

### GIF Kalitesi:
- ✅ Yavaş hareket edin (kullanıcılar takip edebilsin)
- ✅ Önemli kısımlarda 2-3 saniye bekleyin
- ✅ Cursor'u açık tutun
- ✅ Temiz masaüstü kullanın

### Screenshot Kalitesi:
- ✅ Retina çözünürlükte çekin
- ✅ Gerçek veri kullanın (Lorem ipsum değil)
- ✅ Karanlık/aydınlık mod tutarlılığı

### Dosya Boyutu:
- ✅ GIF: 5MB altı
- ✅ PNG: 1MB altı
- ✅ Gerekirse sıkıştırın

## 🔧 Otomatik Optimize Scripti

```bash
#!/bin/bash
# optimize_media.sh

# GIF optimize et
for gif in docs/gifs/*.gif; do
    if [ -f "$gif" ]; then
        gifsicle -O3 --lossy=80 "$gif" -o "$gif.optimized"
        mv "$gif.optimized" "$gif"
        echo "Optimized: $gif"
    fi
done

# PNG optimize et
for png in docs/screenshots/*.png; do
    if [ -f "$png" ]; then
        pngquant --force --ext .png "$png"
        echo "Optimized: $png"
    fi
done
```

## 📊 Kalite Kontrol

Yüklemeden önce kontrol edin:
- [ ] GIF düzgün döngüde mi?
- [ ] Dosya boyutu uygun mu?
- [ ] Görüntü kalitesi yeterli mi?
- [ ] README.md'de doğru gösteriliyor mu?

---

🎬 Harika GIF'ler ve screenshot'lar hazırladığınız için teşekkürler! 