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
    
    @State private var wantsToQuit = false
    
    var body: some View {
        startStopComfyDrop
        
        selectFolder
        
        #if DEBUG
        mouseVisualizer
        #endif
        
        strictGestures
        
        quitButton
    }
    
    // MARK: - Toggle
    private var startStopComfyDrop: some View {
        Button(vm.started ? "Stop" : "Start") {
            vm.toggle()
        }
    }
    
    // MARK: - Folder Selection
    private var selectFolder: some View {
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
    }
    
    // MARK: - Window
    private var mouseVisualizer: some View {
        Button("View Mouse Movements") {
            openWindow(id: "MMouseVisualizer")
        }
    }
    
    // MARK: - Strict Gestures
    private var strictGestures: some View {
        // MARK: - Gesture Control
        Toggle("Strict Gestures", isOn: $settingsStore.strictGestures)
    }
    
    // MARK: - Quit
    private var quitButton: some View {
        Button("Quit") {
            let alert = NSAlert()
            alert.messageText = "Quit ComfyDrop?"
            alert.informativeText = "Are you sure you want to quit?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Quit")
            alert.addButton(withTitle: "Cancel")
            
            if alert.runModal() == .alertFirstButtonReturn {
                NSApp.terminate(nil)
            }
        }
    }
}
