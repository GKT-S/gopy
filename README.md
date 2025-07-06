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

### ⚠️ First Run & Security Approval

Since Gopy is distributed outside the App Store, the macOS **Gatekeeper** security feature may show a warning on the first launch stating that the app "cannot be verified." This is expected and normal behavior.

To run the application, you only need to use one of the following methods **once**:

#### Method 1: Right-Click to Open (Recommended)
1.  Locate the app in your `Applications` folder.
2.  **Right-click** on the `Gopy.app` icon (or hold down the `Control` key and click).
3.  Select **"Open"** from the context menu.
4.  A warning dialog will appear again. This time, click the **"Open"** button in that window.

After this process, macOS will trust Gopy, and you won't see this warning again.

#### Method 2: Terminal Command (Alternative)
If you prefer, you can open the Terminal and paste the following command to permanently remove the app's security quarantine flag:
```bash
xattr -d com.apple.quarantine /Applications/Gopy.app
```
After running this command, you can open the app by double-clicking it normally.

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
Contributions are welcome! Please read the [Contributing Guide](CONTRIBUTING.md) for details on how to submit pull requests, report bugs, and suggest features.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Apple SwiftUI team for the amazing framework
- The macOS developer community for inspiration and support
- All beta testers for their valuable feedback

---

⭐ If you find this project useful, please consider giving it a star!

📧 For questions or support, please open an issue or contact [goktgsahin@gmail.com](mailto:goktgsahin@gmail.com).