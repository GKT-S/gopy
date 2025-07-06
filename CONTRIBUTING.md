# Contributing Guide

Thank you for wanting to contribute to the Gopy project! This guide explains how you can contribute to the project.

## 🤝 Ways to Contribute

### 1. Bug Reports
- Create bug reports using GitHub Issues
- Provide as much detail as possible
- Specify reproduction steps
- Include your system information (macOS version, etc.)

### 2. Feature Suggestions
- Open GitHub Issues for new features
- Explain why the feature would be useful
- Provide possible mockups or examples

### 3. Code Contributions
- Fork and create a new branch
- Implement your changes
- Test and update documentation
- Submit a Pull Request

## 🔧 Development Setup

### Requirements
```bash
# Required tools
- macOS 12.0+
- Xcode 14.0+
- Swift 5.0+
```

### Installation
```bash
# Clone the project
git clone https://github.com/GKT-S/gopy.git
cd gopy

# Open with Xcode
open Gopy.xcodeproj

# Run the project
# Run with Cmd+R in Xcode
```

## 📝 Code Style

### Swift Code Style
```swift

class ClipboardManager {
    private var clipboardItems: [ClipboardItem] = []
    
    func addClipboardItem(_ item: ClipboardItem) {
        // Implementation
    }
}


func addClipboardItem(_ item: ClipboardItem) {
    // Implementation
}
```

### SwiftUI Code Style
```swift
// View structure
struct ContentView: View {
    @StateObject private var clipboardManager = ClipboardManager()
    
    var body: some View {
        VStack {
            // View content
        }
        .onAppear {
            // Setup code
        }
    }
}
```

## 🧪 Testing

### Unit Tests
```swift

import XCTest
@testable import Gopy

class ClipboardManagerTests: XCTestCase {
    var clipboardManager: ClipboardManager!
    
    override func setUp() {
        clipboardManager = ClipboardManager()
    }
    
    func testAddClipboardItem() {
        // Test implementation
    }
}
```

### UI Tests
```swift

import XCTest

class GopyUITests: XCTestCase {
    func testBasicFunctionality() {
        let app = XCUIApplication()
        app.launch()
        
        // UI test steps
    }
}
```

## 📋 Pull Request Process

### 1. Branch Creation
```bash
# Feature branch
git checkout -b feature/amazing-feature

# Bugfix branch
git checkout -b bugfix/fix-clipboard-issue

# Hotfix branch
git checkout -b hotfix/urgent-fix
```

### 2. Commit Messages
```bash
# Commit format
git commit -m "type: description

- Detailed explanation
- What was changed
- Why it was changed

Closes #123"

# Examples
git commit -m "feat: add iCloud sync support"
git commit -m "fix: resolve clipboard monitoring issue"
git commit -m "docs: update README with new features"
```

### 3. Pull Request Template
```markdown
## Changes
- [ ] New feature added
- [ ] Bug fixed
- [ ] Documentation updated
- [ ] Test added

## Description
This PR does:
- Detailed explanation
- What was changed
- Reasons

## Tested
- [ ] Unit tests pass
- [ ] UI tests pass
- [ ] Manual testing completed

## Screenshots
(Add screenshots of UI changes if applicable)
```

## 🐛 Bug Report Template

```markdown
## Bug Description
Briefly describe what the bug is.

## Reproduction Steps
1. Do this
2. Click that
3. Expect this
4. See error

## Expected Behavior
Describe what should happen.

## Screenshots
Add screenshots if applicable.

## System Information
- macOS version: [e.g. 13.0]
- Gopy version: [e.g. 1.0.0]
- Xcode version: [e.g. 14.0]

## Additional Information
Add any other important details.
```

## 🎯 Feature Request Template

```markdown
## Feature Summary
Briefly describe the feature.

## Motivation
Why would this feature be useful?

## Detailed Description
Describe in detail how the feature would work.

## Alternatives
What other solutions were considered?

## Additional Information
Mockups, examples, etc.
```

## 📚 Documentation

### README Updates
- Update README.md for new features
- Add usage examples
- Update screenshots

### Code Documentation
```swift
/// Clipboard manager class
/// 
/// This class monitors and manages clipboard content
/// - Automatic content capture
/// - Smart categorization
/// - Search and filtering
class ClipboardManager: ObservableObject {
    // Implementation
}
```

## 🔍 Code Review

### As a Reviewer
- Check code quality
- Ensure tests are adequate
- Review documentation
- Provide constructive feedback

### As a PR Author
- Clearly explain changes
- Add tests
- Update documentation
- Address code review comments

## 🎯 Roadmap

### Short-term Goals
- [ ] iCloud synchronization
- [ ] Encryption support
- [ ] Theme customization

### Long-term Goals
- [ ] iOS companion app
- [ ] Multi-language support
- [ ] Plugin system

## 💬 Communication

- GitHub Issues: For technical matters
- Email: [email@example.com](mailto:email@example.com)
- Discussions: For general discussions

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

---

Thank you again! 🙏 Feel free to ask if you have any questions. 