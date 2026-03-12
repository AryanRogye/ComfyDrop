//
//  MouseDropOverlay.swift
//  MouseDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import AppKit
import SwiftUI

struct MouseDropOverlay: View {
    @Bindable var mouseWatcher: MouseWatcher
    @ObservedObject var folderStore: FolderStore
    var onClose: () -> Void
    
    @State private var folderItems: [OverlayFolderItem] = []
    @State private var loadError: String?
    @State private var hoveredID: URL? = nil
    
    var body: some View {
        MouseDropOverlayCard(
            selectedFolderName: selectedFolderName,
            hasSelectedFolder: hasSelectedFolder,
            loadError: loadError,
            folderItems: folderItems,
            hoveredID: $hoveredID,
            onClose: onClose,
            dragProvider: dragProvider(for:)
        )
            .position(x: overlayPosition.x, y: overlayPosition.y)
            .onAppear(perform: reloadFolderItems)
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                reloadFolderItems()
            }
            .ignoresSafeArea()
    }
    
    // MARK: - Helpers
    
    private var hasSelectedFolder: Bool {
        folderStore.watchFolder != nil || folderStore.resolvedWatchFolderURL() != nil
    }
    
    private var selectedFolderName: String {
        folderStore.watchFolder?.lastPathComponent
        ?? folderStore.resolvedWatchFolderURL()?.lastPathComponent
        ?? "No Folder Selected"
    }
    
    private var overlayPosition: CGPoint {
        guard let screen = screenContaining(point: mouseWatcher.center) else { return .zero }
        let localX = mouseWatcher.center.x - screen.frame.minX
        let localY = mouseWatcher.center.y - screen.frame.minY
        return CGPoint(x: localX, y: screen.frame.height - localY)
    }
    
    private func screenContaining(point: NSPoint) -> NSScreen? {
        NSScreen.screens.first { NSMouseInRect(point, $0.frame, false) }
    }
    
    private func reloadFolderItems() {
        guard let folderURL = folderStore.resolvedWatchFolderURL() else {
            folderItems = []
            loadError = nil
            return
        }
        
        let startedAccess = folderURL.startAccessingSecurityScopedResource()
        defer { if startedAccess { folderURL.stopAccessingSecurityScopedResource() } }
        
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .contentModificationDateKey]
        
        do {
            let urls = try FileManager.default.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: Array(keys),
                options: [.skipsHiddenFiles]
            )
            
            folderItems = urls.compactMap { url -> OverlayFolderItem? in
                guard let values = try? url.resourceValues(forKeys: keys) else { return nil }
                let isDirectory = values.isDirectory ?? false
                let previewImage = (!isDirectory && OverlayFolderItem.isImageFile(url))
                ? NSImage(contentsOf: url)
                : nil
                return OverlayFolderItem(id: url, url: url, isDirectory: isDirectory, previewImage: previewImage)
            }
            .sorted { lhs, rhs in
                // Folders after files
                if lhs.isDirectory != rhs.isDirectory {
                    return !lhs.isDirectory && rhs.isDirectory
                }
                // Most recently modified first
                let lDate = (try? lhs.url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
                let rDate = (try? rhs.url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
                return lDate > rDate
            }
            
            loadError = nil
        } catch {
            folderItems = []
            loadError = "Could not read folder: \(error.localizedDescription)"
        }
    }
    
    private func dragProvider(for item: OverlayFolderItem) -> NSItemProvider {
        // Start access before creating the provider
        _ = item.url.startAccessingSecurityScopedResource()
        
        let provider = NSItemProvider(contentsOf: item.url)
        ?? NSItemProvider(object: item.url as NSURL)
        
        // Stop after a short delay to let the drag session pick it up
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            item.url.stopAccessingSecurityScopedResource()
        }
        
        return provider
    }
}
