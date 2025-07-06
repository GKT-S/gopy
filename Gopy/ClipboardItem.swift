import SwiftUI
import Foundation

// MARK: - Clipboard Item Model
struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let content: String
    let date: Date
    var tags: [String]
    var isFavorite: Bool = false
    var note: String?
    
    init(content: String, tags: [String] = []) {
        self.id = UUID()
        self.content = content
        self.date = Date()
        self.tags = tags
    }
}

// MARK: - Tag Categories
enum TagCategory: String, CaseIterable {
    case links = "Links"
    case code = "Code"
    case text = "Text"
    case apis = "APIs"
    case password = "Passwords"
    case mail = "Emails"
    case numbers = "Numbers"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .links: return "link"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .text: return "text.alignleft"
        case .apis: return "key"
        case .password: return "lock"
        case .mail: return "envelope"
        case .numbers: return "phone"
        case .custom: return "tag"
        }
    }
    
    var color: Color {
        switch self {
        case .links: return .blue
        case .code: return .purple
        case .text: return .gray
        case .apis: return .orange
        case .password: return .red
        case .mail: return .green
        case .numbers: return .cyan
        case .custom: return .yellow
        }
    }
}

// MARK: - Content Analyzer
class ContentAnalyzer {
    static func analyzeContent(_ content: String) -> [String] {
        var tags: [String] = []
        
        // URL/Link detection
        if content.contains("http://") || content.contains("https://") || content.contains("www.") {
            tags.append(TagCategory.links.rawValue)
        }
        
        // Email detection
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        if content.range(of: emailRegex, options: .regularExpression) != nil {
            tags.append(TagCategory.mail.rawValue)
        }
        
        // Code detection
        if content.contains("{") && content.contains("}") ||
           content.contains("function") || content.contains("class") ||
           content.contains("import") || content.contains("let ") ||
           content.contains("var ") || content.contains("def ") ||
           content.contains("<?php") || content.contains("<!DOCTYPE") {
            tags.append(TagCategory.code.rawValue)
        }
        
        // API Key detection (long alphanumeric strings)
        let apiKeyRegex = "^[A-Za-z0-9_-]{20,}$"
        if content.range(of: apiKeyRegex, options: .regularExpression) != nil {
            tags.append(TagCategory.apis.rawValue)
        }
        
        // Password detection (specific patterns)
        if content.count > 8 && content.count < 50 &&
           content.rangeOfCharacter(from: CharacterSet.letters) != nil &&
           content.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
            tags.append(TagCategory.password.rawValue)
        }
        
        // Phone number detection
        let phoneRegex = "^[+]?[0-9\\s\\-\\(\\)]{7,}$"
        if content.range(of: phoneRegex, options: .regularExpression) != nil ||
           content.hasPrefix("+") && content.count > 7 {
            tags.append(TagCategory.numbers.rawValue)
        }
        
        // Default to text if no specific category found
        if tags.isEmpty {
            tags.append(TagCategory.text.rawValue)
        }
        
        return tags
    }
} 