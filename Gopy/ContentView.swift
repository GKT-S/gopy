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
    @State private var editingNoteItemId: UUID? = nil

    var body: some View {
        TahoeWindowContainer {
            HStack(alignment: .top, spacing: 16) {

                if clipboardManager.isShowingTagPanel {
                    TagSidePanel(clipboardManager: clipboardManager)
                        .frame(width: 160)
                        .transition(.move(edge: .leading))
                }

                VStack(spacing: 16) {
                    HeaderView(
                        searchText: $searchText,
                        clipboardManager: clipboardManager
                    )

                    ClipboardListView(
                        clipboardManager: clipboardManager,
                        copiedItemId: $copiedItemId,
                        editingNoteItemId: $editingNoteItemId
                    )
                }
            }
        }
        .frame(width: 580, height: 520)
        .onAppear {
            clipboardManager.updateFilteredItems(with: searchText)

            DispatchQueue.main.async {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
}

struct HeaderView: View {
    @Binding var searchText: String
    @ObservedObject var clipboardManager: ClipboardManager
    @State private var showClearConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text("Gopy")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.primary.opacity(0.9))

                Spacer(minLength: 6)

                if !clipboardManager.filteredItems.isEmpty {
                    Label("\(clipboardManager.filteredItems.count)", systemImage: clipboardManager.isShowingFavorites ? "star.fill" : "doc.on.doc")
                        .font(.system(size: 11, weight: .medium))
                        .labelStyle(.titleAndIcon)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.28), lineWidth: 0.8)
                                )
                        )
                        .foregroundStyle(Color.primary.opacity(0.75))
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: clipboardManager.filteredItems.count)
                }
            }

            HStack(spacing: 10) {
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        clipboardManager.isShowingTagPanel.toggle()
                    }
                }) {
                    Image(systemName: clipboardManager.isShowingTagPanel ? "sidebar.leading" : "sidebar.trailing")
                        .font(.system(size: 13, weight: .semibold))
                }
                .buttonStyle(TahoePillStyle())
                .focusEffectDisabled()
                .help(clipboardManager.isShowingTagPanel ? "Hide tags" : "Show tags")

                searchField

                Spacer(minLength: 4)

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                        if clipboardManager.isShowingFavorites {
                            clipboardManager.showAllItems(searchText: searchText)
                        } else {
                            clipboardManager.showFavoritesOnly(searchText: searchText)
                        }
                    }
                }) {
                    Image(systemName: clipboardManager.isShowingFavorites ? "star.fill" : "star")
                        .font(.system(size: 13, weight: .semibold))
                }
                .buttonStyle(TahoePillStyle(isProminent: clipboardManager.isShowingFavorites, tint: .yellow))
                .focusEffectDisabled()
                .help("Favorites")

                Button(role: .destructive) {
                    showClearConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .semibold))
                }
                .buttonStyle(TahoePillStyle(isProminent: true, tint: Color.red))
                .focusEffectDisabled()
                .help("Clear all")
                .alert("Clear Clipboard History", isPresented: $showClearConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Clear All", role: .destructive) {
                        clipboardManager.clearAllItems()
                    }
                } message: {
                    let favCount = clipboardManager.clipboardItems.filter { $0.isFavorite }.count
                    if favCount > 0 {
                        Text("This will delete all clipboard items except your \(favCount) favorite(s). This action cannot be undone.")
                    } else {
                        Text("This will delete all clipboard items. This action cannot be undone.")
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.secondary.opacity(0.75))
                .font(.system(size: 12, weight: .medium))
            
            TextField("Search content or tags", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .medium))
                .onChange(of: searchText) {
                    clipboardManager.updateFilteredItems(with: searchText)
                }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
        )
    }
}

struct TagSidePanel: View {
    @ObservedObject var clipboardManager: ClipboardManager

    var body: some View {
        TahoeSidebarBackground {
            VStack(alignment: .leading, spacing: 10) {
                Text("Collections")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .padding(.bottom, 2)

                TagFilterButton(
                    title: "All",
                    icon: "tray.fill",
                    count: clipboardManager.nonFavoriteCount,
                    isSelected: clipboardManager.selectedTag == nil && !clipboardManager.isShowingFavorites,
                    action: {
                        clipboardManager.showAllItems()
                    }
                )

                TagFilterButton(
                    title: "Favorites",
                    icon: "star.fill",
                    count: clipboardManager.itemCount(for: "Favorites"),
                    isSelected: clipboardManager.isShowingFavorites,
                    action: {
                        clipboardManager.showFavoritesOnly()
                    }
                )

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.vertical, 4)

                ForEach(TagCategory.allCases, id: \.rawValue) { category in
                    let count = clipboardManager.itemCount(for: category.rawValue)
                    if count > 0 {
                        TagFilterButton(
                            title: category.rawValue,
                            icon: category.icon,
                            count: count,
                            isSelected: clipboardManager.selectedTag == category.rawValue,
                            action: {
                                clipboardManager.selectedTag = category.rawValue
                                clipboardManager.isShowingFavorites = false
                                clipboardManager.updateFilteredItems()
                            }
                        )
                    }
                }

                if !clipboardManager.customTags.isEmpty {
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.vertical, 4)

                    ForEach(clipboardManager.customTags, id: \.self) { tag in
                        TagFilterButton(
                            title: tag,
                            icon: "tag",
                            count: clipboardManager.itemCount(for: tag),
                            isSelected: clipboardManager.selectedTag == tag,
                            action: {
                                clipboardManager.selectedTag = tag
                                clipboardManager.isShowingFavorites = false
                                clipboardManager.updateFilteredItems()
                            }
                        )
                    }
                }

                Spacer(minLength: 8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
        }
    }
}

struct TagFilterButton: View {
    let title: String
    let icon: String
    var count: Int = 0
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : getIconColor().opacity(0.85))
                    .frame(width: 16)

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(0.85))

                Spacer(minLength: 6)

                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(isSelected ? Color.white.opacity(0.9) : Color.secondary.opacity(0.7))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                        )
                }

                if isSelected {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.8))
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(buttonBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(buttonStroke, lineWidth: 1)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: isSelected)
    }
    
    private var buttonBackground: LinearGradient {
        if isSelected {
            return LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.45),
                    Color.accentColor.opacity(0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        return LinearGradient(
            colors: [
                Color.white.opacity(0.14),
                Color.white.opacity(0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var buttonStroke: Color {
        if isSelected {
            return Color.white.opacity(0.42)
        }
        return Color.white.opacity(0.18)
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
    @Binding var editingNoteItemId: UUID?

    private var emptyStateInfo: (icon: String, message: String) {
        if clipboardManager.isShowingFavorites {
            return ("star.slash", "No favorites yet. Star an item to save it here.")
        } else if let tag = clipboardManager.selectedTag {
            return ("tag.slash", "No \(tag) items found.")
        } else if !clipboardManager.activeSearchText.isEmpty {
            return ("magnifyingglass", "No results for \"\(clipboardManager.activeSearchText)\"")
        }
        return ("doc.on.clipboard", "No clipboard items yet. Copy something to get started.")
    }

    var body: some View {
        if clipboardManager.filteredItems.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: emptyStateInfo.icon)
                    .font(.system(size: 28))
                    .foregroundColor(.secondary.opacity(0.7))

                Text(emptyStateInfo.message)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(clipboardManager.filteredItems) { item in
                        ClipboardItemRow(
                            item: item,
                            clipboardManager: clipboardManager,
                            copiedItemId: $copiedItemId,
                            editingNoteItemId: $editingNoteItemId
                        )
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 10)
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .tahoeSmoothList()
        }
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem
    @ObservedObject var clipboardManager: ClipboardManager
    @Binding var copiedItemId: UUID?
    @Binding var editingNoteItemId: UUID?
    @State private var noteText: String = ""
    @FocusState private var isNoteFieldFocused: Bool

    private var isEditingNote: Bool {
        editingNoteItemId == item.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                contentView
                    .frame(maxWidth: .infinity, alignment: .leading)

                controlStack
            }

            if let note = item.note, !note.isEmpty, !isEditingNote {
                Text(note)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.secondary.opacity(0.9))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            if isEditingNote {
                HStack(spacing: 8) {
                    TextField("Add a note...", text: $noteText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.white.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.accentColor.opacity(0.4), lineWidth: 1)
                                )
                        )
                        .focused($isNoteFieldFocused)
                        .onSubmit {
                            saveNote()
                        }

                    Button(action: saveNote) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.green)
                    }
                    .buttonStyle(.plain)

                    Button(action: { editingNoteItemId = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Time at bottom-right
            HStack {
                Spacer()
                Text(timeAgoString(from: item.date))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.secondary.opacity(0.7))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(rowBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(rowStroke, lineWidth: copiedItemId == item.id ? 1.4 : 0.9)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.accentColor.opacity(copiedItemId == item.id ? 0.4 : 0.0), lineWidth: 1.6)
        )
        .shadow(color: Color.black.opacity(item.isFavorite ? 0.14 : 0.08), radius: copiedItemId == item.id ? 9 : 6, x: 0, y: 6)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture {
            guard !isEditingNote else { return }
            clipboardManager.copyItemToClipboard(item)
            copiedItemId = item.id

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                copiedItemId = nil
                NotificationCenter.default.post(name: .hidGopyPanel, object: nil)
            }
        }
        .contextMenu {
            Button {
                clipboardManager.copyItemToClipboard(item)
                copiedItemId = item.id
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    copiedItemId = nil
                }
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }

            Button {
                clipboardManager.toggleFavorite(for: item.id)
            } label: {
                Label(item.isFavorite ? "Remove from Favorites" : "Add to Favorites", systemImage: item.isFavorite ? "star.slash" : "star")
            }

            Button {
                noteText = item.note ?? ""
                editingNoteItemId = item.id
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isNoteFieldFocused = true
                }
            } label: {
                Label(item.note?.isEmpty == false ? "Edit Note" : "Add Note", systemImage: "note.text")
            }

            Divider()

            Button(role: .destructive) {
                clipboardManager.deleteItem(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .scaleEffect(copiedItemId == item.id ? 0.985 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.78), value: copiedItemId)
    }

    private func saveNote() {
        clipboardManager.updateNote(for: item.id, newNote: noteText)
        editingNoteItemId = nil
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 6) {
            if item.isImage, let image = item.image {
                HStack(alignment: .center, spacing: 10) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 38, height: 38)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.8)
                        )
                    
                    Text(item.displayContent)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.primary.opacity(0.92))
                        .lineLimit(2)
                }
            } else {
                Text(singleLineContent)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.primary.opacity(0.96))
                    .lineLimit(2)
            }
        }
    }
    
    private var controlStack: some View {
        HStack(spacing: 8) {
            Button(action: {
                if isEditingNote {
                    editingNoteItemId = nil
                } else {
                    noteText = item.note ?? ""
                    editingNoteItemId = item.id
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isNoteFieldFocused = true
                    }
                }
            }) {
                Image(systemName: item.note?.isEmpty == false ? "note.text" : "note.text.badge.plus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isEditingNote ? Color.accentColor : Color.primary.opacity(0.9))
                    .padding(6)
                    .background(controlBackground(isActive: item.note?.isEmpty == false || isEditingNote, tint: .blue))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
            .help(item.note?.isEmpty == false ? "Edit note" : "Add note")
            
            Button(action: {
                clipboardManager.toggleFavorite(for: item.id)
            }) {
                Image(systemName: item.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(item.isFavorite ? Color.yellow : Color.primary.opacity(0.75))
                    .padding(6)
                    .background(controlBackground(isActive: item.isFavorite, tint: .yellow))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
            .help(item.isFavorite ? "Remove from favorites" : "Add to favorites")
        }
    }
    
    private func controlBackground(isActive: Bool, tint: Color) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        tint.opacity(isActive ? 0.32 : 0.18),
                        tint.opacity(isActive ? 0.2 : 0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(isActive ? 0.45 : 0.25), lineWidth: isActive ? 1.1 : 0.6)
            )
    }
    
    private var rowBackground: LinearGradient {
        if item.isFavorite {
            return LinearGradient(
                colors: [
                    Color.yellow.opacity(0.18),
                    Color.yellow.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        return LinearGradient(
            colors: [
                Color.white.opacity(0.12),
                Color.white.opacity(0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var rowStroke: Color {
        item.isFavorite ? Color.yellow.opacity(0.35) : Color.white.opacity(0.2)
    }
    
    private var singleLineContent: String {
        let content = item.content ?? item.displayContent
        let cleaned = content
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return String(cleaned.prefix(160))
    }
}

func copyToClipboard(_ content: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(content, forType: .string)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ClipboardManager())
            .frame(width: 400, height: 500)
    }
}
