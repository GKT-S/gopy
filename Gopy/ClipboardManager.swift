import SwiftUI
import AppKit
import Foundation

// MARK: - Clipboard Manager
class ClipboardManager: ObservableObject {
    @Published var clipboardItems: [ClipboardItem] = []
    @Published var filteredItems: [ClipboardItem] = []
    @Published var selectedTag: String? = nil
    @Published var customTags: [String] = []
    @Published var isShowingFavorites: Bool = false
    @Published var isShowingTagPanel: Bool = false
    
    private var pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0
    private var timer: Timer?
    
    // Settings from UserDefaults
    @AppStorage("clipboardMonitoringInterval") private var clipboardMonitoringInterval = 1.0
    @AppStorage("maxClipboardItems") private var maxClipboardItems = 40 // Reduced to 40 as requested
    @AppStorage("enableNotifications") private var enableNotifications = true
    
    // MARK: - Initialization
    init() {
        loadClipboardItems()
        loadCustomTags()
        startMonitoring()
        updateFilteredItems()
        
        // Listen for settings changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func settingsChanged() {
        // Restart timer if interval changed
        restartTimer()
    }
    
    // MARK: - Pasteboard Monitoring
    func startMonitoring() {
        lastChangeCount = pasteboard.changeCount
        restartTimer()
    }
    
    private func restartTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: clipboardMonitoringInterval, repeats: true) { [weak self] _ in
            self?.checkForNewContent()
        }
    }
    
    private func checkForNewContent() {
        let currentChangeCount = pasteboard.changeCount
        
        guard currentChangeCount != lastChangeCount else { return }
        
        lastChangeCount = currentChangeCount
        
        if let newContent = pasteboard.string(forType: .string),
           !newContent.isEmpty,
           !clipboardItems.contains(where: { $0.content == newContent }) {
            
            let analyzedTags = ContentAnalyzer.analyzeContent(newContent)
            let newItem = ClipboardItem(content: newContent, tags: analyzedTags)
            
            addClipboardItem(newItem)
        }
    }
    
    // MARK: - Item Management
    func addClipboardItem(_ item: ClipboardItem) {
        clipboardItems.insert(item, at: 0) // Add new item at the top

        // Keep ALL favorites, and at most `maxClipboardItems` non-favorites.
        let favorites = clipboardItems.filter { $0.isFavorite }
        var nonFavorites = clipboardItems.filter { !$0.isFavorite }

        // If there are too many non-favorites, trim the oldest ones.
        if nonFavorites.count > maxClipboardItems {
            // `nonFavorites` is sorted newest to oldest, so we take the `prefix`
            // which are the newest ones, effectively dropping the oldest.
            nonFavorites = Array(nonFavorites.prefix(maxClipboardItems))
        }

        // Reconstruct the main list, sorted by date (newest first)
        clipboardItems = (favorites + nonFavorites).sorted(by: { $0.date > $1.date })

        saveClipboardItems()
        updateFilteredItems()
        
        // Show notification if enabled
        if enableNotifications {
            showNotification(for: item)
        }
    }
    
    func deleteItem(_ item: ClipboardItem) {
        clipboardItems.removeAll { $0.id == item.id }
        saveClipboardItems()
        updateFilteredItems()
    }
    
    func toggleFavorite(_ item: ClipboardItem) {
        toggleFavorite(for: item.id)
    }
    
    func toggleFavorite(for itemId: UUID) {
        if let index = clipboardItems.firstIndex(where: { $0.id == itemId }) {
            clipboardItems[index].isFavorite.toggle()
            
            // If favorited, add to favorites tag
            if clipboardItems[index].isFavorite {
                if !clipboardItems[index].tags.contains("Favorites") {
                    clipboardItems[index].tags.append("Favorites")
                }
            } else {
                // Remove from favorites tag
                clipboardItems[index].tags.removeAll { $0 == "Favorites" }
            }
            
            saveClipboardItems()
            updateFilteredItems()
        }
    }
    
    func copyToClipboard(_ content: String) {
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
    }
    
    func toggleTagPanel() {
        isShowingTagPanel.toggle()
    }
    
    // MARK: - Filtering
    func setSelectedTag(_ tag: String?) {
        selectedTag = tag
        updateFilteredItems()
    }
    
    func toggleFavorites() {
        isShowingFavorites.toggle()
        updateFilteredItems()
    }
    
    func updateFilteredItems() {
        updateFilteredItems(with: "")
    }
    
    func updateFilteredItems(with searchText: String) {
        var items: [ClipboardItem]
        
        // Apply tag/favorites filter first
        if isShowingFavorites {
            // "Favorites" folder: only favorited items
            items = clipboardItems.filter { $0.isFavorite }
        } else if selectedTag != nil {
            // Belirli bir tag seçiliyse: o tag'e sahip öğeler
            items = clipboardItems.filter { $0.tags.contains(selectedTag!) }
        } else {
            // "Tümü" klasörü: Akıllı filtreleme
            // Bir favori öğeyi, kendisinden sonra 40'tan fazla favori olmayan
            // öğe eklendiyse "Tümü" listesinden gizle.
            items = clipboardItems.filter { item in
                if !item.isFavorite {
                    return true // Favori olmayanlar her zaman görünür
                }
                
                // Öğenin index'ini bul
                guard let itemIndex = clipboardItems.firstIndex(where: { $0.id == item.id }) else {
                    return true // Bulunamazsa güvenlik için göster
                }
                
                // Kendisinden yeni olan öğeleri al (array'in başından kendi index'ine kadar olanlar)
                let newerItems = clipboardItems.prefix(upTo: itemIndex)
                // Bu yeni öğelerden kaçı favori değil?
                let newerNonFavoritesCount = newerItems.filter { !$0.isFavorite }.count
                
                // Eğer 40'tan az ise göster
                return newerNonFavoritesCount < maxClipboardItems
            }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            items = items.filter { item in
                item.content.localizedCaseInsensitiveContains(searchText) ||
                item.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        filteredItems = items
    }
    
    // MARK: - Custom Tags
    func addCustomTag(_ tag: String) {
        let trimmedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !customTags.contains(trimmedTag) {
            customTags.append(trimmedTag)
            saveCustomTags()
        }
    }
    
    func removeCustomTag(_ tag: String) {
        customTags.removeAll { $0 == tag }
        saveCustomTags()
    }
    
    func addTagToItem(_ item: ClipboardItem, tag: String) {
        if let index = clipboardItems.firstIndex(where: { $0.id == item.id }) {
            if !clipboardItems[index].tags.contains(tag) {
                clipboardItems[index].tags.append(tag)
                saveClipboardItems()
                updateFilteredItems()
            }
        }
    }
    
    func removeTagFromItem(_ item: ClipboardItem, tag: String) {
        if let index = clipboardItems.firstIndex(where: { $0.id == item.id }) {
            clipboardItems[index].tags.removeAll { $0 == tag }
            saveClipboardItems()
            updateFilteredItems()
        }
    }
    
    // MARK: - Persistence
    func saveClipboardItems() {
        if let encoded = try? JSONEncoder().encode(clipboardItems) {
            UserDefaults.standard.set(encoded, forKey: "ClipboardItems")
        }
    }
    
    func loadClipboardItems() {
        if let data = UserDefaults.standard.data(forKey: "ClipboardItems"),
           let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            clipboardItems = decoded
        }
    }
    
    private func saveCustomTags() {
        UserDefaults.standard.set(customTags, forKey: "CustomTags")
    }
    
    private func loadCustomTags() {
        customTags = UserDefaults.standard.stringArray(forKey: "CustomTags") ?? []
    }
    
    // MARK: - Cleanup
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Notifications
    private func showNotification(for item: ClipboardItem) {
        let notification = NSUserNotification()
        notification.title = "Yeni Clipboard Öğesi"
        notification.informativeText = String(item.content.prefix(100))
        notification.soundName = nil
        
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    // MARK: - Additional Helper Methods
    func getAllTags() -> [String] {
        let predefinedTags = TagCategory.allCases.map { $0.rawValue }
        let allTags = Set(predefinedTags + customTags + clipboardItems.flatMap { $0.tags })
        return Array(allTags).sorted()
    }
    
    func clearAllItems() {
        clipboardItems.removeAll { !$0.isFavorite }
        saveClipboardItems()
        updateFilteredItems()
    }
    
    func getTagColor(_ tag: String) -> Color {
        if let category = TagCategory(rawValue: tag) {
            return category.color
        }
        return .cyan // Custom tags color
    }
    
    func getTagIcon(_ tag: String) -> String {
        if let category = TagCategory(rawValue: tag) {
            return category.icon
        }
        return "tag" // Custom tags icon
    }
    
    func addTag(_ tag: String, to itemId: UUID) {
        if let index = clipboardItems.firstIndex(where: { $0.id == itemId }) {
            if !clipboardItems[index].tags.contains(tag) {
                clipboardItems[index].tags.append(tag)
            }
            saveClipboardItems()
            updateFilteredItems()
        }
    }
    
    func removeItem(withId id: UUID) {
        clipboardItems.removeAll { $0.id == id }
        saveClipboardItems()
        updateFilteredItems()
    }
    
    // MARK: - Note Management
    func updateNote(for itemId: UUID, newNote: String) {
        if let index = clipboardItems.firstIndex(where: { $0.id == itemId }) {
            clipboardItems[index].note = newNote
            saveClipboardItems()
            updateFilteredItems()
        }
    }
    
}

// MARK: - Content View Components
// ... existing code ... 