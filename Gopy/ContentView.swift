//
//  ContentView.swift
//  Gopy
//
//  Created by Göktuğ Şahin on 6.07.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var searchText = ""
    @State private var copiedItemId: UUID? = nil
    
    @State private var noteEditorWindow: NSWindow? = nil
    @State private var noteEditorItem: ClipboardItem? = nil
    @State private var currentNoteText = ""
    
    var body: some View {
        HStack(spacing: 0) {
            
            if clipboardManager.isShowingTagPanel {
                TagSidePanel(clipboardManager: clipboardManager)
                    .frame(width: 150)
                    .transition(.move(edge: .leading))
            }
            
            VStack(spacing: 0) {
                HeaderView(
                    searchText: $searchText,
                    clipboardManager: clipboardManager
                )
                
                ClipboardListView(
                    clipboardManager: clipboardManager,
                    copiedItemId: $copiedItemId,
                    onEditNote: { item in
                        self.showNoteEditor(for: item)
                    }
                )
            }
        }
        .frame(width: 550, height: 500)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        .onAppear {
            clipboardManager.updateFilteredItems(with: searchText)
            
            DispatchQueue.main.async {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
    
    private func showNoteEditor(for item: ClipboardItem) {
        DispatchQueue.main.async {
            noteEditorWindow?.close()
            noteEditorWindow = nil
        }
        
        noteEditorItem = item
        currentNoteText = item.note ?? ""
        
        DispatchQueue.main.async {
            let noteEditor = NoteEditorWindowView(
                item: item,
                noteText: currentNoteText,
                onSave: { updatedItem, note in
                    DispatchQueue.main.async {
                        clipboardManager.updateNote(for: updatedItem.id, newNote: note)
                        noteEditorWindow?.close()
                        noteEditorWindow = nil
                    }
                },
                onCancel: {
                    DispatchQueue.main.async {
                        noteEditorWindow?.close()
                        noteEditorWindow = nil
                    }
                }
            )
            
            let hostingController = NSHostingController(rootView: noteEditor)
            
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 360),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            
            window.title = "Not Ekle - Gopy"
            window.contentViewController = hostingController
            window.isReleasedWhenClosed = false
            
            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.popUpMenuWindow)))
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.minSize = NSSize(width: 500, height: 280)
            window.maxSize = NSSize(width: 800, height: 450)
            window.center()
            
            noteEditorWindow = window
            
            window.orderFrontRegardless()
            window.makeKeyAndOrderFront(nil)
            
            NSApp.activate(ignoringOtherApps: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                window.makeKey()
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}

struct HeaderView: View {
    @Binding var searchText: String
    @ObservedObject var clipboardManager: ClipboardManager
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    clipboardManager.isShowingTagPanel.toggle()
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .foregroundColor(.primary)
                    .font(.system(size: 14))
            }
            .buttonStyle(.plain)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
                
                TextField("Search...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .onChange(of: searchText) {
                        clipboardManager.updateFilteredItems(with: searchText)
                    }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
            
            Button("Clear") {
                clipboardManager.clearAllItems()
            }
            .font(.system(size: 11))
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.8))
    }
}

struct TagSidePanel: View {
    @ObservedObject var clipboardManager: ClipboardManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TagFilterButton(
                title: "All",
                icon: "tray.fill",
                isSelected: clipboardManager.selectedTag == nil && !clipboardManager.isShowingFavorites,
                action: {
                    clipboardManager.selectedTag = nil
                    clipboardManager.isShowingFavorites = false
                    clipboardManager.updateFilteredItems()
                }
            )
            
            TagFilterButton(
                title: "Favorites",
                icon: "star.fill",
                isSelected: clipboardManager.isShowingFavorites,
                action: {
                    clipboardManager.isShowingFavorites = true
                    clipboardManager.selectedTag = nil
                    clipboardManager.updateFilteredItems()
                }
            )
            
            Divider()
                .padding(.vertical, 4)
            
            ForEach(TagCategory.allCases, id: \.rawValue) { category in
                TagFilterButton(
                    title: category.rawValue.capitalized,
                    icon: category.icon,
                    isSelected: clipboardManager.selectedTag == category.rawValue,
                    action: {
                        clipboardManager.selectedTag = category.rawValue
                        clipboardManager.isShowingFavorites = false
                        clipboardManager.updateFilteredItems()
                    }
                )
            }
            
            if !clipboardManager.customTags.isEmpty {
                Divider()
                    .padding(.vertical, 4)
                
                ForEach(clipboardManager.customTags, id: \.self) { tag in
                    TagFilterButton(
                        title: tag,
                        icon: "tag",
                        isSelected: clipboardManager.selectedTag == tag,
                        action: {
                            clipboardManager.selectedTag = tag
                            clipboardManager.isShowingFavorites = false
                            clipboardManager.updateFilteredItems()
                        }
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
}

struct TagFilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .white : getIconColor())
                
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.accentColor : Color.clear)
            .cornerRadius(6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func getIconColor() -> Color {
        if title == "All" {
            return .blue
        } else if title == "Favorites" {
            return .yellow
        }
        
        if let category = TagCategory(rawValue: title) {
            return category.color
        }
        
        return .cyan
    }
}

struct ClipboardListView: View {
    @ObservedObject var clipboardManager: ClipboardManager
    @Binding var copiedItemId: UUID?
    let onEditNote: (ClipboardItem) -> Void
    
    var body: some View {
        if clipboardManager.filteredItems.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 32))
                    .foregroundColor(.secondary)
                
                Text("No clipboard items yet")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(clipboardManager.filteredItems) { item in
                        ClipboardItemRow(
                            item: item,
                            clipboardManager: clipboardManager,
                            copiedItemId: $copiedItemId,
                            onEditNote: onEditNote
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem
    @ObservedObject var clipboardManager: ClipboardManager
    @Binding var copiedItemId: UUID?
    let onEditNote: (ClipboardItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                HStack(spacing: 2) {
                    ForEach(item.tags.prefix(2), id: \.self) { tag in
                        TagIcon(tag: tag)
                    }
                    
                    if item.tags.count > 2 {
                        Text("+\(item.tags.count - 2)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 2)
                    }
                }
                .frame(width: 60, alignment: .leading)
                
                if item.isImage {
                    HStack(spacing: 8) {
                        if let image = item.image {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .cornerRadius(4)
                        }
                        
                        Text(item.displayContent)
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                    }
                } else {
                    Text(singleLineContent)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                
                Spacer()
                
                Button(action: {
                    onEditNote(item)
                }) {
                    Image(systemName: item.note?.isEmpty == false ? "note.text" : "note.text.badge.plus")
                        .foregroundColor(item.note?.isEmpty == false ? .blue : .secondary)
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)

                Button(action: {
                    clipboardManager.toggleFavorite(for: item.id)
                }) {
                    Image(systemName: item.isFavorite ? "star.fill" : "star")
                        .foregroundColor(item.isFavorite ? .yellow : .secondary)
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 10)
            }
            
            if let note = item.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 68)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .background(
            Rectangle()
                .fill(Color.clear)
                .overlay(
                    Color.accentColor.opacity(copiedItemId == item.id ? 0.15 : 0)
                )
        )
        .onTapGesture {
            clipboardManager.copyItemToClipboard(item)
            copiedItemId = item.id
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                copiedItemId = nil
                NSApp.keyWindow?.close()
            }
        }
        .scaleEffect(copiedItemId == item.id ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: copiedItemId)
    }
    
    private var singleLineContent: String {
        let content = item.content ?? item.displayContent
        
        let cleaned = content
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return String(cleaned.prefix(100))
    }
}

struct TagIcon: View {
    let tag: String
    
    var body: some View {
        Image(systemName: getTagIcon(tag))
            .font(.system(size: 10))
            .foregroundColor(getTagColor(tag))
            .padding(2)
            .background(getTagColor(tag).opacity(0.2))
            .clipShape(Circle())
    }
    
    private func getTagIcon(_ tag: String) -> String {
        if let category = TagCategory(rawValue: tag) {
            return category.icon
        }
        return "tag"
    }
    
    private func getTagColor(_ tag: String) -> Color {
        if let category = TagCategory(rawValue: tag) {
            return category.color
        }
        return .cyan
    }
}

func copyToClipboard(_ content: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(content, forType: .string)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 400, height: 500)
    }
}

struct NoteEditorWindowView: View {
    let item: ClipboardItem
    @State private var noteText: String
    let onSave: (ClipboardItem, String) -> Void
    let onCancel: () -> Void
    @FocusState private var isTextEditorFocused: Bool
    
    init(item: ClipboardItem, noteText: String, onSave: @escaping (ClipboardItem, String) -> Void, onCancel: @escaping () -> Void) {
        self.item = item
        self._noteText = State(initialValue: noteText)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "note.text")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Add Note")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(String(item.displayContent.prefix(120)) + (item.displayContent.count > 120 ? "..." : ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 20)
            .background(Color(NSColor.windowBackgroundColor))
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Note:")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(noteText.count) characters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.textBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isTextEditorFocused ? Color.blue : Color.secondary.opacity(0.3),
                                        lineWidth: isTextEditorFocused ? 2 : 1
                                    )
                            )
                            .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
                        
                        TextEditor(text: $noteText)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .focused($isTextEditorFocused)
                    }
                    .frame(minHeight: 120, maxHeight: 180)
                }
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .keyboardShortcut(.cancelAction)
                    .buttonStyle(.bordered)
                    .foregroundColor(.secondary)
                    .controlSize(.large)
                    
                    Spacer()
                    
                    Button("Save") {
                        onSave(item, noteText)
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(minWidth: 480, idealWidth: 480, maxWidth: .infinity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextEditorFocused = true
            }
        }
    }
}
