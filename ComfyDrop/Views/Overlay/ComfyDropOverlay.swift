//
//  ComfyDropOverlay.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import AppKit
import SwiftUI

struct ComfyDropOverlay: View {
    @State private var vm : ComfyDropOverlayViewModel
    var onClose: () -> Void
    
    init(folderStore: FolderStore, onClose: @escaping () -> Void) {
        self.vm = .init(folderStore: folderStore)
        self.onClose = onClose
        vm.reloadFolderItems()
    }
    
    @State private var hoveredID: URL? = nil
    
    private var hasSelectedFolder: Bool {
        vm.folderStore.watchFolder != nil
    }
    
    private var selectedFolderName: String {
        vm.folderStore.watchFolder?.lastPathComponent
        ?? "No Folder Selected"
    }
    
    var body: some View {
        ComfyDropOverlayCard(
            vm: vm,
            selectedFolderName: selectedFolderName,
            hasSelectedFolder: hasSelectedFolder,
            hoveredID: $hoveredID,
            onClose: onClose,
            dragProvider: dragProvider(for:)
        )
        .onAppear {
            vm.reloadFolderItems()
            vm.startMonitoringFolder()
        }
        .onDisappear {
            vm.stop()
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
