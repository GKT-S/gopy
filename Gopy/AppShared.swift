import Foundation

enum AppGroup {
    static let identifier = "group.com.gopy.shared"
}

enum StorageKeys {
    static let clipboardItems = "clipboardItems"
    static let customTags = "customTags"
    static let widgetFavorites = "widgetFavorites"
}

enum WidgetKind {
    static let favorites = "GopyFavoritesWidget"
}

enum SharedDefaults {
    static let instance: UserDefaults = {
        guard let defaults = UserDefaults(suiteName: AppGroup.identifier) else {
            return UserDefaults.standard
        }
        return defaults
    }()
}

struct WidgetFavorite: Codable, Identifiable {
    let id: UUID
    let title: String
    let note: String?
    let isImage: Bool
    let date: Date
}

func timeAgoString(from date: Date) -> String {
    let now = Date()
    let timeInterval = now.timeIntervalSince(date)
    
    if timeInterval < 60 {
        return "now"
    } else if timeInterval < 3600 {
        let minutes = Int(timeInterval / 60)
        return "\(minutes)m ago"
    } else if timeInterval < 86400 {
        let hours = Int(timeInterval / 3600)
        return "\(hours)h ago"
    } else {
        let days = Int(timeInterval / 86400)
        return "\(days)d ago"
    }
}
