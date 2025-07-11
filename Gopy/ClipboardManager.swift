import SwiftUI
import AppKit
import Foundation

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
    
    @AppStorage("clipboardMonitoringInterval") private var clipboardMonitoringInterval = 1.0
    @AppStorage("maxClipboardItems") private var maxClipboardItems = 40
    @AppStorage("enableNotifications") private var enableNotifications = true
    
    init() {
        loadClipboardItems()
        loadCustomTags()
        startMonitoring()
        updateFilteredItems()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func settingsChanged() {
        restartTimer()
    }
    
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
            return
        }
        
        let imageTypes: [NSPasteboard.PasteboardType] = [
            NSPasteboard.PasteboardType("public.png"),
            NSPasteboard.PasteboardType("public.tiff"),
            .tiff,
            .png,
            .pdf,
            NSPasteboard.PasteboardType("public.image")
        ]
        
        for imageType in imageTypes {
            if let imageData = pasteboard.data(forType: imageType),
               let image = NSImage(data: imageData),
               !clipboardItems.contains(where: { $0.imageData == imageData }) {
                
                let analyzedTags = ContentAnalyzer.analyzeImageContent()
                let newItem = ClipboardItem(image: image, tags: analyzedTags)
                
                addClipboardItem(newItem)
                return
            }
        }
    }
    
    func addClipboardItem(_ item: ClipboardItem) {
        clipboardItems.insert(item, at: 0)

        let favorites = clipboardItems.filter { $0.isFavorite }
        var nonFavorites = clipboardItems.filter { !$0.isFavorite }

        if nonFavorites.count > maxClipboardItems {
            nonFavorites = Array(nonFavorites.prefix(maxClipboardItems))
        }

        clipboardItems = (favorites + nonFavorites).sorted(by: { $0.date > $1.date })

        saveClipboardItems()
        updateFilteredItems()
        
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
            
            if clipboardItems[index].isFavorite {
                if !clipboardItems[index].tags.contains("Favorites") {
                    clipboardItems[index].tags.append("Favorites")
                }
            } else {
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
    
    func copyImageToClipboard(_ image: NSImage) {
        pasteboard.clearContents()
        if let tiffData = image.tiffRepresentation {
            pasteboard.setData(tiffData, forType: .tiff)
        }
    }
    
    func copyItemToClipboard(_ item: ClipboardItem) {
        if let content = item.content {
            copyToClipboard(content)
        } else if let image = item.image {
            copyImageToClipboard(image)
        }
    }
    
    func toggleTagPanel() {
        isShowingTagPanel.toggle()
    }
    
    func setSelectedTag(_ tag: String?) {
        selectedTag = tag
        updateFilteredItems()
    }
    
    func updateFilteredItems(with searchText: String = "") {
        var items: [ClipboardItem]
        
        if let selectedTag = selectedTag {
            if selectedTag == "Favorites" {
                items = clipboardItems.filter { $0.isFavorite }
            } else if selectedTag == "Tümü" {
                items = clipboardItems
            } else {
                items = clipboardItems.filter { $0.tags.contains(selectedTag) }
            }
        } else {
            items = clipboardItems.filter { item in
                if !item.isFavorite {
                    return true 
                }
                
                guard let itemIndex = clipboardItems.firstIndex(where: { $0.id == item.id }) else {
                    return true 
                }
                
                let newerItems = clipboardItems.prefix(upTo: itemIndex)
                let newerNonFavoritesCount = newerItems.filter { !$0.isFavorite }.count
                
                return newerNonFavoritesCount < maxClipboardItems
            }
        }
        
        if !searchText.isEmpty {
            items = items.filter { item in
                (item.content?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                item.displayContent.localizedCaseInsensitiveContains(searchText) ||
                item.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        filteredItems = items
    }
    
    func addCustomTag(_ tag: String) {
        if !customTags.contains(tag) && !tag.isEmpty {
            customTags.append(tag)
            saveCustomTags()
        }
    }
    
    func removeCustomTag(_ tag: String) {
        customTags.removeAll { $0 == tag }
        saveCustomTags()
        
        for index in clipboardItems.indices {
            clipboardItems[index].tags.removeAll { $0 == tag }
        }
        saveClipboardItems()
        updateFilteredItems()
    }
    
    func addTagToItem(_ itemId: UUID, tag: String) {
        if let index = clipboardItems.firstIndex(where: { $0.id == itemId }) {
            if !clipboardItems[index].tags.contains(tag) {
                clipboardItems[index].tags.append(tag)
                saveClipboardItems()
                updateFilteredItems()
            }
        }
    }
    
    func removeTagFromItem(_ itemId: UUID, tag: String) {
        if let index = clipboardItems.firstIndex(where: { $0.id == itemId }) {
            clipboardItems[index].tags.removeAll { $0 == tag }
            saveClipboardItems()
            updateFilteredItems()
        }
    }
    
    func clearAllItems() {
        clipboardItems.removeAll()
        filteredItems.removeAll()
        saveClipboardItems()
    }
    
    func getTagColor(for tag: String) -> Color {
        if let category = TagCategory.allCases.first(where: { $0.rawValue == tag }) {
            return category.color
        }
        return .cyan
    }
    
    func getTagIcon(for tag: String) -> String {
        if let category = TagCategory.allCases.first(where: { $0.rawValue == tag }) {
            return category.icon
        }
        return "tag"
    }
    
    private func showNotification(for item: ClipboardItem) {
        let content = UNMutableNotificationContent()
        content.title = "Gopy - Yeni İçerik"
        content.body = String(item.displayContent.prefix(50))
        content.sound = nil
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    func updateNote(for itemId: UUID, newNote: String) {
        if let index = clipboardItems.firstIndex(where: { $0.id == itemId }) {
            clipboardItems[index].note = newNote.isEmpty ? nil : newNote
            saveClipboardItems()
            updateFilteredItems()
        }
    }
    
    private func saveClipboardItems() {
        if let encoded = try? JSONEncoder().encode(clipboardItems) {
            UserDefaults.standard.set(encoded, forKey: "clipboardItems")
        }
    }
    
    private func loadClipboardItems() {
        if let data = UserDefaults.standard.data(forKey: "clipboardItems"),
           let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            clipboardItems = decoded
        }
    }
    
    private func saveCustomTags() {
        UserDefaults.standard.set(customTags, forKey: "customTags")
    }
    
    private func loadCustomTags() {
        customTags = UserDefaults.standard.stringArray(forKey: "customTags") ?? []
    }
}

import UserNotifications

