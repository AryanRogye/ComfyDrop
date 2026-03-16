//
//  ComfyDropMenuBar.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import SwiftUI
import Sparkle
import UniformTypeIdentifiers

/// MenuBar View
@MainActor
struct ComfyDropMenuBar: View {
    
    @Bindable private var settingsStore: SettingsStore
    @Bindable private var updaterVM: UpdaterViewModel
    private let updateController: UpdateController
    @State private var vm : ComfyDropMenuBarViewModel
    @State private var isImporting = false
    
    @Environment(\.openWindow) var openWindow
    
    init(
        mouseWatcher: MouseWatcher,
        updateController: UpdateController,
        settingsStore: SettingsStore,
        folderStore: FolderStore
    ) {
        self.updateController = updateController
        self.updaterVM = updateController.updaterVM
        self.settingsStore = settingsStore
        vm = ComfyDropMenuBarViewModel(
            mouseWatcher: mouseWatcher,
            folderStore: folderStore
        )
    }
    
    @State private var wantsToQuit = false
    
    var body: some View {
        Group {
            
            Section("Controls") {
                startStopComfyDrop
                selectFolder
            }
            
            Divider()
            
            Section("Updates") {
                updatesSection
                versionInfo
            }
#if DEBUG
            Section("Debug") {
                mouseVisualizer
            }
#endif
            Divider()
            
            Section("Settings") {
                startOnLaunch
                strictGestures
            }
            Divider()
            quitButton
        }
        .onChange(of: updaterVM.showPermissionAlert) { _, show in
            guard show else { return }
            updaterVM.presentPermissionAlert()
        }
        .onChange(of: updaterVM.showUpdateNotFoundError) { _, show in
            guard show else { return }
            updaterVM.presentNoUpdateAlert()
        }
        .onChange(of: updaterVM.showUpdateError) { _, show in
            guard show else { return }
            updaterVM.presentUpdateErrorAlert()
        }
        .onChange(of: updaterVM.appcast != nil && updaterVM.updateState != nil) { _, show in
            guard show else { return }
            updaterVM.presentUpdateFoundAlert()
        }
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
    
#if DEBUG
    // MARK: - Window
    private var mouseVisualizer: some View {
        Button("View Mouse Movements") {
            openWindow(id: "MMouseVisualizer")
        }
    }
#endif
    
    // MARK: - Update Section
    private var updatesSection: some View {
        Button {
            updateController.checkForUpdates()
        } label: {
            Label(updaterVM.checkForUpdatesTitle, systemImage: "arrow.2.circlepath.circle.fill")
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .disabled(updaterVM.showUserInitiatedUpdate)
    }
    
    // MARK: - VersionInfo
    private var versionInfo: some View {
        Group {
            if let statusLine = updaterVM.updateStatusLine {
                Text(statusLine)
            } else {
                Text("Version \(Bundle.main.versionNumber)")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
    
    // MARK: - Start On Launch
    private var startOnLaunch: some View {
        Toggle("Start On Launch", isOn: $settingsStore.startOnLaunch)
    }
    
    // MARK: - Strict Gestures
    private var strictGestures: some View {
        Toggle("Strict Gestures", isOn: $settingsStore.strictGestures)
    }
    
    // MARK: - Quit
    private var quitButton: some View {
        Button("Quit") {
            let alert = AlertMaker.makeAlert(
                messageText: "Quit ComfyDrop?",
                informativeText: "Are you sure you want to quit?",
                style: .warning,
                buttons: ["Quit", "Cancel"]
            )

            if alert.runModal() == .alertFirstButtonReturn {
                NSApp.terminate(nil)
            }
        }
    }
}
