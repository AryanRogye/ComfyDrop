//
//  ComfyDropMenuBar.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import SwiftUI
import UniformTypeIdentifiers

/// MenuBar View
struct ComfyDropMenuBar: View {
    
    @State private var settingsStore: SettingsStore
    @State private var vm : ComfyDropMenuBarViewModel
    @State private var isImporting = false
    
    @Environment(\.openWindow) var openWindow
    
    init(mouseWatcher: MouseWatcher, settingsStore: SettingsStore, folderStore: FolderStore) {
        self.settingsStore = settingsStore
        vm = ComfyDropMenuBarViewModel(
            mouseWatcher: mouseWatcher,
            folderStore: folderStore
        )
    }
    
    var body: some View {
        // MARK: - Toggle
        Button(vm.started ? "Stop" : "Start") {
            vm.toggle()
        }
        
        // MARK: - Folder Selection
        Button(action: {
            isImporting = true
        }) {
            if let folder = vm.folderStore.watchFolder {
                Text("Selected: \(folder.lastPathComponent)")
            } else {
                Text("Pick Folder")
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.directory],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                
                let startedAccess = url.startAccessingSecurityScopedResource()
                defer {
                    if startedAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                
                vm.folderStore.setWatchFolder(url)
                
            case .failure(let error):
                print("Error selecting folder: \(error.localizedDescription)")
            }
        }
        
        // MARK: - Window
        Button("View Mouse Movements") {
            openWindow(id: "MMouseVisualizer")
        }
        
        // MARK: - Gesture Control
        Toggle("Strict Gestures", isOn: $settingsStore.strictGestures)
    }
}
