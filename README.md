# 📋 Gopy - Smart Clipboard Manager

> A powerful and user-friendly clipboard manager for modern macOS

**Gopy** is a clipboard manager born from personal needs to solve everyday problems in daily usage. What sets it apart from traditional clipboard managers is its **unique combination of clipboard and note-taking features** in a single application, allowing you to add custom notes to every copied content.

This project was developed for personal use and is shared as open source for users with similar needs who might find it useful. 

[![macOS](https://img.shields.io/badge/macOS-12.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🎬 Demo

<div align="center">
  <img src="docs/gifs/gopy-demo.gif" alt="Gopy Demo" width="600"/>
</div>

*Demo showcasing Gopy's core features*

## 🌟 Features

### 🚀 Core Features
- **Automatic Clipboard Tracking**: Everything you copy is automatically saved
- **Smart Categorization**: Automatic tagging based on content type
- **Quick Search**: Instant search through your clipboard history
- **Favorites System**: Mark important items as favorites
- **📝 Advanced Note System**: Add detailed notes to every clipboard item and store context information
- **💾 Smart Memory Management**: Last 40 copies are stored in history, favorites are permanent

### 🎯 Unique Advantages
- **Clipboard + Note-Taking Combination**: Stores not only your copied content but also your notes related to that content
- **Personal Need-Focused**: Designed to solve real problems encountered in daily usage
- **Open Source Approach**: Shared with the community despite being a personal project

### 🏷️ Smart Categories
- **🔗 Links**: Web addresses and URLs
- **💻 Code**: Code snippets and software code
- **📧 Emails**: Email addresses
- **🔐 Passwords**: Secure passwords
- **🔑 APIs**: API keys and tokens
- **📱 Numbers**: Phone numbers
- **📝 Text**: General text content

### 🎯 User-Friendly Interface
- **Menu Bar Integration**: Easy access with "G" icon in system tray
- **Drag & Drop Support**: Easy content management
- **Dark Mode Support**: Compatible with macOS theme settings
- **Auto-Launch**: Automatic startup on system boot

## 📥 Installation

### 🚀 Easy Installation Methods

#### 1. **Automatic Installation (Recommended)** ⚡
One-command installation:
```bash
curl -fsSL https://raw.githubusercontent.com/GKT-S/gopy/main/install.sh | bash
```

#### 2. **Manual Download** 📦
1. Download the latest version from [Releases page](https://github.com/GKT-S/gopy/releases)
2. Extract the `Gopy.zip` file
3. Drag `Gopy.app` to your `Applications` folder
4. Launch Gopy

#### 3. **Homebrew Installation** 🍺
```bash
# Coming soon
brew install --cask gopy
```

### 🔧 Developer Setup

#### Requirements
- macOS 12.0 or later
- Xcode 14.0 or later

#### Building from Source
1. **Clone the project**
```bash
git clone https://github.com/GKT-S/gopy.git
cd gopy
```

2. **Open with Xcode**
```bash
open Gopy.xcodeproj
```

3. **Build and run**
- Run the project with `Cmd + R` in Xcode
- The app will appear with "G" icon in the menu bar

#### Quick Test
```bash
chmod +x run_gopy.sh
./run_gopy.sh
```

#### Release Build
```bash
chmod +x build_release.sh
./build_release.sh
```

## 🎮 Usage

### Basic Usage
1. **Launch Gopy** - Click the "G" icon in the menu bar
2. **Copy content** - Copy any text (Cmd+C)
3. **Access history** - View your clipboard history from the Gopy window
4. **Reuse** - Click on any item to copy it back to clipboard

### Advanced Features
- **Favorites**: Use ⭐ icon to add important items to favorites
- **Search**: Quick filtering with 🔍 search bar
- **Categories**: Category-based filtering from the left panel
- **📝 Smart Note System**: 
  - Add unlimited text notes to every clipboard item
  - Clipboard content + note information displayed together
  - Items with notes are marked with special icons
  - Notes are also searchable

### 💾 Data Storage and Memory Management

Gopy uses an intelligent memory management system for performance and storage balance:

#### 📋 Temporary Storage (Last 40 Copies)
- **Automatic Limit**: System automatically stores the last 40 clipboard items
- **FIFO System**: After the 40th item, oldest items are automatically deleted  
- **Daily Usage**: Sufficient memory space for normal daily usage
- **Performance**: Maintains app speed and system performance

#### ⭐ Permanent Storage (Favorites)
- **Unlimited Storage**: Items marked as favorites are **never deleted**
- **Important Content**: Add frequently used items to favorites
- **Notes Preserved**: Notes of favorite items are also permanently stored
- **Manual Control**: Only removable by manually unfavoriting

#### 🔄 Practical Usage Tips
- Use normal copying for temporary needs
- Use the favorites system for code snippets, passwords, frequently used texts
- Add notes to important information to store context



## 🏗️ Development

### Project Structure
```
Gopy/
├── Gopy/
│   ├── GopyApp.swift          # Main application file
│   ├── ContentView.swift      # Main interface
│   ├── ClipboardManager.swift # Clipboard management
│   ├── ClipboardItem.swift    # Data model
│   ├── SettingsView.swift     # Settings interface
│   └── Assets.xcassets/       # Application resources
├── GopyTests/                 # Unit tests
├── GopyUITests/               # UI tests
└── run_gopy.sh               # Quick launch script
```

### Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Use standard Swift code style for Swift code
- Follow SwiftUI best practices
- Write unit tests for every new feature

## 🐛 Troubleshooting

### Common Issues

**App won't start**
- Make sure Gopy.entitlements file is configured correctly
- Check macOS security settings

**Clipboard not being tracked**
- Check the app's privacy permissions
- System Preferences → Security & Privacy → Privacy → Accessibility

**Icon not visible in menu bar**
- Restart the application
- Check system tray settings

## 📖 Version History

### v1.0.0 (Current)
- ✅ Basic clipboard management
- ✅ Smart categorization
- ✅ Favorites system
- ✅ Search functionality
- ✅ Note-taking
- ✅ Menu bar integration

### Planned Features
- 🔄 Synchronization (iCloud)
- 🔐 Encryption support
- 🎨 Theme customization
- 📱 iOS companion app
- 🌍 Multi-language support

## 🤝 Contributors

This project is developed by [Göktuğ Şahin](https://github.com/GKT-S).

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Apple SwiftUI team for the amazing framework
- macOS developer community for inspiration
- All beta testers for their feedback

---

⭐ If you like this project, please don't forget to give it a star!

📧 For questions: [goktgsahin@gmail.com](mailto:goktgsahin@gmail.com) 