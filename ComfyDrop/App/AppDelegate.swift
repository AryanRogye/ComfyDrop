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
    var onboarding       : OnboardingCoordinator
    var settingsStore = SettingsStore()
    
    @MainActor
    override init() {
        NSApp.setActivationPolicy(.accessory)
        self.mouseWatcher = MouseWatcher(settingsStore: settingsStore)
        self.comfyDropOverlay = .init(
            mouseWatcher: mouseWatcher,
            folderStore: folderStore
        )
        self.onboarding = OnboardingCoordinator()
        super.init()
        
        settingsStore.onStartOnLaunchIsOn = { [weak self] in
            guard let self else { return }
            self.mouseWatcher.start()
        }
        settingsStore.onStartOnLaunchIsOff = { [weak self] in
            guard let self else { return }
            self.mouseWatcher.stop()
        }
        
        mouseWatcher.onMouseActivation = { [weak self] in
            guard let self else { return }
            comfyDropOverlay.hide()
            comfyDropOverlay.show()
        }
        mouseWatcher.onFirstLaunchDemo = { [weak self] in
            guard let self else { return }
            onboarding.show()
        }
        settingsStore.sync()
    }
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
        mouseWatcher.stop()
        settingsStore.isFirstLaunch = false
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
