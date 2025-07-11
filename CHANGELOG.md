# Changelog

This file records all important changes to the Gopy project.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) standard,
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned Features
- iCloud synchronization
- Encryption support
- Theme customization
- iOS companion app
- Multi-language support

## [1.1.0] - 2025-01-11

### Added Features
- ✅ Screenshot support (Images category)
- ✅ Image thumbnail display in clipboard items
- ✅ Automatic screenshot detection from clipboard
- ✅ Support for multiple image formats (PNG, TIFF, PDF)
- ✅ Image copying back to clipboard functionality

### Improvements
- 🔧 Code cleanup and comment removal for production
- 🔧 Optimized clipboard monitoring for both text and images
- 🔧 Enhanced content analysis for image items
- 🔧 Improved UI for image items with thumbnail preview

### Technical Details
- Added support for `public.png`, `public.tiff`, and other image formats
- Enhanced ClipboardItem model to handle both text and image data
- Custom Codable implementation to exclude large image data from UserDefaults
- Improved pasteboard monitoring with multiple format detection

### Usage Notes
- Screenshots work with Cmd+Control+Shift+3/4 (copies to clipboard)
- Regular Cmd+Shift+3/4 only saves files, not detected by Gopy
- Images appear with 📷 icon and thumbnail preview
- All image operations (copy, favorite, notes) work like text items

## [1.0.0] - 2025-01-XX

### Added Features
- ✅ Automatic clipboard monitoring
- ✅ Smart content categorization
  - Links (Web addresses)
  - Code (Code snippets)
  - Emails (Email addresses)
  - Passwords (Passwords)
  - APIs (API keys)
  - Numbers (Phone numbers)
  - Text (General text)
- ✅ Favorites system
- ✅ Quick search functionality
- ✅ Note-taking system
- ✅ Menu bar integration
- ✅ Settings window
- ✅ Auto-launch (login at startup)
- ✅ Keyboard shortcuts support
- ✅ Dark mode compatibility
- ✅ Smart filtering (favorites visibility)
- ✅ Custom tag support
- ✅ Notification system
- ✅ Drag & drop support

### Technical Details
- Modern macOS interface with SwiftUI
- AppKit integration
- Settings management with UserDefaults
- Timer-based clipboard monitoring
- Regex-based content analysis
- JSON-based data storage

### Performance
- Maximum 40 items support (configurable)
- Efficient memory usage
- Fast search algorithm
- Smart favorites management

### Security
- Local data storage
- Automatic password content detection
- Privacy-focused design

---

## Release Notes

### v1.1.0 Screenshot Support Update
This release adds comprehensive screenshot support to Gopy. Screenshots are automatically detected and categorized when copied to clipboard using the correct keyboard shortcuts.

**New Features:**
- Screenshot detection and categorization
- Image thumbnail previews
- Support for multiple image formats
- Image copying functionality

**Important Usage Notes:**
- Use Cmd+Control+Shift+3 (full screen) or Cmd+Control+Shift+4 (selection) for screenshots
- These shortcuts copy images to clipboard AND save files
- Regular Cmd+Shift+3/4 only save files and won't be detected by Gopy

### v1.0.0 Initial Release
This is the first stable release of Gopy. All core features have been implemented and tested.

**Known Limitations:**
- Visual content support added in v1.1.0
- Network synchronization is not available

**System Requirements:**
- macOS 12.0 or later
- At least 50MB free disk space
- Accessibility permissions required 