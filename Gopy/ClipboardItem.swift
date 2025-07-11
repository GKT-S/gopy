import SwiftUI
import Foundation
import AppKit

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let content: String?
    private let _imageData: Data?
    let date: Date
    var tags: [String]
    var isFavorite: Bool = false
    var note: String?
    
    var imageData: Data? {
        return _imageData
    }
    
    enum CodingKeys: String, CodingKey {
        case id, content, date, tags, isFavorite, note
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(date, forKey: .date)
        try container.encode(tags, forKey: .tags)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(note, forKey: .note)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String?.self, forKey: .content)
        date = try container.decode(Date.self, forKey: .date)
        tags = try container.decode([String].self, forKey: .tags)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        note = try container.decode(String?.self, forKey: .note)
        _imageData = nil
    }
    
    var displayContent: String {
        if let content = content {
            return content
        } else if imageData != nil {
            return "📷 Ekran Görüntüsü"
        } else {
            return "Boş İçerik"
        }
    }
    
    var isImage: Bool {
        return imageData != nil
    }
    
    var image: NSImage? {
        guard let imageData = imageData else { return nil }
        return NSImage(data: imageData)
    }
    
    init(content: String, tags: [String] = []) {
        self.id = UUID()
        self.content = content
        self._imageData = nil
        self.date = Date()
        self.tags = tags
    }
    
    init(image: NSImage, tags: [String] = []) {
        self.id = UUID()
        self.content = nil
        self._imageData = image.tiffRepresentation
        self.date = Date()
        self.tags = tags
    }
}

enum TagCategory: String, CaseIterable {
    case links = "Links"
    case code = "Code"
    case text = "Text"
    case apis = "APIs"
    case password = "Passwords"
    case mail = "Emails"
    case numbers = "Numbers"
    case images = "Images"
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
        case .images: return "photo"
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
        case .images: return .pink
        case .custom: return .yellow
        }
    }
}

class ContentAnalyzer {
    static func analyzeContent(_ content: String) -> [String] {
        var tags: [String] = []
        
        if content.contains("http://") || content.contains("https://") || content.contains("www.") {
            tags.append(TagCategory.links.rawValue)
        }
        
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        if content.range(of: emailRegex, options: .regularExpression) != nil {
            tags.append(TagCategory.mail.rawValue)
        }
        
        if content.contains("{") && content.contains("}") ||
           content.contains("function") || content.contains("class") ||
           content.contains("import") || content.contains("let ") ||
           content.contains("var ") || content.contains("def ") ||
           content.contains("<?php") || content.contains("<!DOCTYPE") {
            tags.append(TagCategory.code.rawValue)
        }
        
        let apiKeyRegex = "^[A-Za-z0-9_-]{20,}$"
        if content.range(of: apiKeyRegex, options: .regularExpression) != nil {
            tags.append(TagCategory.apis.rawValue)
        }
        
        if content.count > 8 && content.count < 50 &&
           content.rangeOfCharacter(from: CharacterSet.letters) != nil &&
           content.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
            tags.append(TagCategory.password.rawValue)
        }
        
        let phoneRegex = "^[+]?[0-9\\s\\-\\(\\)]{7,}$"
        if content.range(of: phoneRegex, options: .regularExpression) != nil ||
           content.hasPrefix("+") && content.count > 7 {
            tags.append(TagCategory.numbers.rawValue)
        }
        
        if tags.isEmpty {
            tags.append(TagCategory.text.rawValue)
        }
        
        return tags
    }
    
    static func analyzeImageContent() -> [String] {
        return [TagCategory.images.rawValue]
    }
} 