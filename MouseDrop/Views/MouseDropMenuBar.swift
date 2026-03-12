//
//  MouseDropMenuBar.swift
//  MouseDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import SwiftUI
import UniformTypeIdentifiers

/// MenuBar View
struct MouseDropMenuBar: View {
    
    @State private var settingsStore: SettingsStore
    @State private var vm : MouseDropViewModel
    @State private var isImporting = false
    
    @Environment(\.openWindow) var openWindow
    
    init(mouseWatcher: MouseWatcher, settingsStore: SettingsStore, folderStore: FolderStore) {
        self.settingsStore = settingsStore
        vm = MouseDropViewModel(
            mouseWatcher: mouseWatcher,
            folderStore: folderStore
        )
    }
    
    var body: some View {
        Button(vm.started ? "Stop" : "Start") {
            vm.toggle()
        }
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
        
        Button("View Mouse Movements") {
            openWindow(id: "MMouseVisualizer")
        }
        
        Toggle("Strict Gestures", isOn: $settingsStore.strictGestures)
    }
}
