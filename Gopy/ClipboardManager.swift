import SwiftUI
import AppKit
import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

class ClipboardManager: ObservableObject {
    @Published var clipboardItems: [ClipboardItem] = []
    @Published var filteredItems: [ClipboardItem] = []
    @Published var selectedTag: String? = nil
    @Published var customTags: [String] = []
    @Published var isShowingFavorites: Bool = false
    @Published var isShowingTagPanel: Bool = false
    @Published var activeSearchText: String = ""
    
    private var pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0
    private var timer: Timer?
    private let sharedDefaults = SharedDefaults.instance
    
    @AppStorage("clipboardMonitoringInterval", store: SharedDefaults.instance) private var clipboardMonitoringInterval = 1.0
    @AppStorage("maxClipboardItems", store: SharedDefaults.instance) private var maxClipboardItems = 40
    @AppStorage("enableNotifications", store: SharedDefaults.instance) private var enableNotifications = true
    
    init() {
        loadClipboardItems()
        loadCustomTags()
        persistWidgetFavorites()
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
    
    func setSelectedTag(_ tag: String?, searchText: String? = nil) {
        selectedTag = tag
        isShowingFavorites = tag?.caseInsensitiveCompare("Favorites") == .orderedSame
        updateFilteredItems(with: searchText ?? activeSearchText)
    }
    
    func showAllItems(searchText: String? = nil) {
        selectedTag = nil
        isShowingFavorites = false
        updateFilteredItems(with: searchText ?? activeSearchText)
    }
    
    func showFavoritesOnly(searchText: String? = nil) {
        selectedTag = nil
        isShowingFavorites = true
        updateFilteredItems(with: searchText ?? activeSearchText)
    }
    
    func updateFilteredItems(with searchText: String? = nil) {
        let currentSearch = searchText ?? activeSearchText
        activeSearchText = currentSearch
        
        var items = clipboardItems
        
        if isShowingFavorites {
            items = items.filter { $0.isFavorite }
        } else if let selectedTag = selectedTag, !selectedTag.isEmpty {
            if selectedTag.caseInsensitiveCompare("favorites") == .orderedSame {
                items = items.filter { $0.isFavorite }
            } else if selectedTag == "Tümü" || selectedTag == "All" {
                items = clipboardItems
            } else {
                items = items.filter { $0.tags.contains(selectedTag) }
            }
        } else {
            items = clipboardItems.filter { !$0.isFavorite }
        }
        
        if !currentSearch.isEmpty {
            items = items.filter { item in
                (item.content?.localizedCaseInsensitiveContains(currentSearch) ?? false) ||
                item.displayContent.localizedCaseInsensitiveContains(currentSearch) ||
                item.tags.contains { $0.localizedCaseInsensitiveContains(currentSearch) }
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
        clipboardItems.removeAll { !$0.isFavorite }
        filteredItems.removeAll()
        saveClipboardItems()
        updateFilteredItems()
    }
    
    func itemCount(for tag: String) -> Int {
        if tag.caseInsensitiveCompare("Favorites") == .orderedSame {
            return clipboardItems.filter { $0.isFavorite }.count
        }
        return clipboardItems.filter { !$0.isFavorite && $0.tags.contains(tag) }.count
    }

    var nonFavoriteCount: Int {
        clipboardItems.filter { !$0.isFavorite }.count
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
        content.title = "Gopy - New Content"
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
    
    private func persistWidgetFavorites() {
        let favorites = clipboardItems
            .filter { $0.isFavorite }
            .sorted(by: { $0.date > $1.date })
            .prefix(6)
            .map { item in
                WidgetFavorite(
                    id: item.id,
                    title: item.displayContent,
                    note: item.note,
                    isImage: item.isImage,
                    date: item.date
                )
            }
        
        if let encoded = try? JSONEncoder().encode(favorites) {
            sharedDefaults.set(encoded, forKey: StorageKeys.widgetFavorites)
        }
    }
    
    private func refreshWidgets() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.favorites)
        #endif
    }
    
    private func saveClipboardItems() {
        if let encoded = try? JSONEncoder().encode(clipboardItems) {
            sharedDefaults.set(encoded, forKey: StorageKeys.clipboardItems)
        }
        persistWidgetFavorites()
        refreshWidgets()
    }
    
    private func loadClipboardItems() {
        if let data = sharedDefaults.data(forKey: StorageKeys.clipboardItems),
           let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            clipboardItems = decoded
        }
    }
    
    private func saveCustomTags() {
        sharedDefaults.set(customTags, forKey: StorageKeys.customTags)
    }
    
    private func loadCustomTags() {
        customTags = sharedDefaults.stringArray(forKey: StorageKeys.customTags) ?? []
    }
}

import UserNotifications

