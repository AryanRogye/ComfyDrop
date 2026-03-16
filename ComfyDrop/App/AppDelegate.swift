//
//  AppDelegate.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let updateController = UpdateController()
    var mouseWatcher : MouseWatcher
    var folderStore  = FolderStore()
    var comfyDropOverlay : ComfyDropOverlayCoordinator
    var settingsStore = SettingsStore()
    
    @MainActor
    override init() {
        NSApp.setActivationPolicy(.accessory)
        self.mouseWatcher = MouseWatcher(settingsStore: settingsStore)
        self.comfyDropOverlay = .init(
            mouseWatcher: mouseWatcher,
            folderStore: folderStore
        )
        super.init()
        mouseWatcher.onMouseActivation = { [weak self] in
            guard let self else { return }
            comfyDropOverlay.hide()
            comfyDropOverlay.show()
        }
    }
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
