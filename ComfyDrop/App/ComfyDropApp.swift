//
//  ComfyDropApp.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import SwiftUI

struct Helpers {
    public static func screenUnderMouse() -> NSScreen? {
        let loc = NSEvent.mouseLocation
        return NSScreen.screens.first {
            NSMouseInRect(loc, $0.frame, false)
        }
    }
}

@main
struct ComfyDropApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            ComfyDropMenuBar(
                mouseWatcher: appDelegate.mouseWatcher,
                settingsStore: appDelegate.settingsStore,
                folderStore: appDelegate.folderStore
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } label: {
            Image(systemName: "computermouse")
        }
        
#if DEBUG
        Window("MouseVisualizer", id: "MMouseVisualizer") {
            MouseVisualizer(mouseWatcher: appDelegate.mouseWatcher)
        }
        .defaultLaunchBehavior(.suppressed)
#endif
    }
}
