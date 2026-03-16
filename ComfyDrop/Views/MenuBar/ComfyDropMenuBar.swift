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
            startStopComfyDrop
            selectFolder
            Divider()
            updatesSection
#if DEBUG
            mouseVisualizer
#endif
            Divider()
            strictGestures
            Divider()
            quitButton
        }
            .onChange(of: updaterVM.showPermissionAlert) { _, show in
                guard show else { return }
                presentPermissionAlert()
            }
            .onChange(of: updaterVM.showUpdateNotFoundError) { _, show in
                guard show else { return }
                presentNoUpdateAlert()
            }
            .onChange(of: updaterVM.showUpdateError) { _, show in
                guard show else { return }
                presentUpdateErrorAlert()
            }
            .onChange(of: updaterVM.appcast != nil && updaterVM.updateState != nil) { _, show in
                guard show else { return }
                presentUpdateFoundAlert()
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
    
    // MARK: - Window
    private var mouseVisualizer: some View {
        Button("View Mouse Movements") {
            openWindow(id: "MMouseVisualizer")
        }
    }
    
    private var checkForUpdates: some View {
        Button {
            updateController.checkForUpdates()
        } label: {
            Label(checkForUpdatesTitle, systemImage: "arrow.trianglehead.clockwise")
        }
        .disabled(!updateController.canCheckForUpdates || updaterVM.showUserInitiatedUpdate)
    }

    @ViewBuilder
    private var updatesSection: some View {
        checkForUpdates
        
        if let statusLine = updateStatusLine {
            Text(statusLine)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
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
            let alert = makeAlert(
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

    private var checkForUpdatesTitle: String {
        if updaterVM.showUserInitiatedUpdate {
            return "Checking for Updates..."
        }
        return "Check for Updates..."
    }

    private var updateStatusLine: String? {
        switch updaterVM.phase {
        case .downloading(let progress, let total):
            if let total, total > 0 {
                let percent = min(Double(progress) / Double(total), 1.0)
                return "Downloading update \(Int(percent * 100))%"
            }
            return "Downloading update..."
        case .extracting(let progress):
            if let progress {
                return "Preparing update \(Int(progress * 100))%"
            }
            return "Preparing update..."
        case .installing:
            return "Installing update..."
        default:
            return nil
        }
    }

    private func presentPermissionAlert() {
        let alert = makeAlert(
            messageText: "Enable Automatic Updates?",
            informativeText: "ComfyDrop can automatically check for new versions in the background.",
            style: .informational,
            buttons: ["Enable", "Not Now"]
        )

        let response = alert.runModal()
        updaterVM.completePermission(
            automaticUpdateChecks: response == .alertFirstButtonReturn
        )
    }

    private func presentNoUpdateAlert() {
        let alert = makeAlert(
            messageText: "You're Up to Date",
            informativeText: updaterVM.updateNotFoundError ?? "No updates are available right now.",
            style: .informational,
            buttons: ["OK"]
        )

        alert.runModal()
        updaterVM.acknowledgeNoUpdateFound()
    }

    private func presentUpdateErrorAlert() {
        let alert = makeAlert(
            messageText: "Update Failed",
            informativeText: updaterVM.updateErrorMessage ?? "Something went wrong while checking for updates.",
            style: .warning,
            buttons: ["OK"]
        )

        alert.runModal()
        updaterVM.acknowledgeUpdateError()
    }

    private func presentUpdateFoundAlert() {
        guard let appcast = updaterVM.appcast else { return }

        let version = appcast.displayVersionString
        let title = version.isEmpty
            ? "Update Available"
            : "Version \(version) Is Available"

        let body = (appcast.itemDescription?.isEmpty == false)
            ? appcast.itemDescription!
            : "A new version of ComfyDrop is ready to install."

        let alert = makeAlert(
            messageText: title,
            informativeText: body,
            style: .informational,
            buttons: ["Install", "Skip This Version", "Later"]
        )

        switch alert.runModal() {
        case .alertFirstButtonReturn:
            updaterVM.completeUpdateFound(choice: .install)
        case .alertSecondButtonReturn:
            updaterVM.completeUpdateFound(choice: .skip)
        default:
            updaterVM.completeUpdateFound(choice: .dismiss)
        }
    }

    private func makeAlert(
        messageText: String,
        informativeText: String,
        style: NSAlert.Style,
        buttons: [String]
    ) -> NSAlert {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.alertStyle = style

        for button in buttons {
            alert.addButton(withTitle: button)
        }

        return alert
    }
}
