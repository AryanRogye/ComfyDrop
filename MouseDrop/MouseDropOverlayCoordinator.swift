//
//  MouseDropOverlayCoordinator.swift
//  MouseDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import AppKit
import SwiftUI

class MouseDropOverlayCoordinator {
    
    var mouseWatcher: MouseWatcher
    var folderStore : FolderStore
    var panel: NSPanel!
    
    init(mouseWatcher: MouseWatcher, folderStore: FolderStore) {
        self.mouseWatcher = mouseWatcher
        self.folderStore  = folderStore
    }
    
    public func setup() {
        guard let screen = Helpers.screenUnderMouse() else { return }
        panel = FocusablePanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.setFrame(screen.frame, display: true)
        /// Allow content to draw outside panel bounds
        panel.contentView?.wantsLayer = true
        
        panel.registerForDraggedTypes([.fileURL])
        panel.title = "SS"
        panel.acceptsMouseMovedEvents = true
        
        let overlayRaw = CGWindowLevelForKey(.overlayWindow)
        panel.level = NSWindow.Level(rawValue: Int(overlayRaw))
        
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .fullScreenDisallowsTiling,
            .ignoresCycle,
            .transient
        ]
        
        panel.isMovableByWindowBackground = false
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        
        let view: NSView = NSHostingView(
            rootView: MouseDropOverlay(
                mouseWatcher: mouseWatcher,
                folderStore: folderStore,
                onClose: hide
            )
        )
        
        /// Allow hosting view to overflow
        view.wantsLayer = true
        view.layer?.masksToBounds = false
        
        panel.contentView = view
        panel.makeKeyAndOrderFront(nil)
    }
    
    public func show() {
        if panel == nil {
            setup()
        }
        if let screen = screenContaining(point: mouseWatcher.center) {
            panel.setFrame(screen.frame, display: true)
        }
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }
    
    public func hide() {
        panel?.orderOut(nil)
    }

    private func screenContaining(point: NSPoint) -> NSScreen? {
        NSScreen.screens.first { NSMouseInRect(point, $0.frame, false) }
    }
}
