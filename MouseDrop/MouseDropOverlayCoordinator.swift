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
    private let panelSize = NSSize(width: 424, height: 210)
    private let edgePadding: CGFloat = 12
    
    private var isOpen = false
    private var keyboardMonitor: Any?
    
    init(mouseWatcher: MouseWatcher, folderStore: FolderStore) {
        self.mouseWatcher = mouseWatcher
        self.folderStore  = folderStore
    }
    
    public func setup() {
        panel = FocusablePanel(
            contentRect: NSRect(origin: .zero, size: panelSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.registerForDraggedTypes([.fileURL])
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
        panel.setContentSize(panelSize)
        
        let view: NSView = NSHostingView(
            rootView: MouseDropOverlay(
                folderStore: folderStore,
                onClose: hide,
            )
        )
        panel.contentView = view
        positionPanel(around: mouseWatcher.center)
        panel.makeKeyAndOrderFront(nil)
    }
    
    public func show() {
        if panel == nil {
            setup()
        }
        positionPanel(around: mouseWatcher.center)
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        
        /// make sure the flag for isOpen is set before we call the attach
        isOpen = true
        attachKeyboardListener()
    }
    
    public func hide() {
        if let keyboardMonitor {
            NSEvent.removeMonitor(keyboardMonitor)
        }
        keyboardMonitor = nil
        panel?.orderOut(nil)
        isOpen = false
    }

    private func attachKeyboardListener() {
        guard panel != nil else {
            print("Cant Attach Keyboard Listener: Panel is nil")
            return
        }
        guard isOpen else {
            print("Cant Attach Keyboard Listener: Is Not Open")
            return
        }
        keyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown], handler: { [weak self] e in
            guard let self else { return e }
            if e.keyCode == 53 {
                self.hide()
            }
            return e
        })
        
        print("Keyboard Listener Attached")
    }

    private func positionPanel(around point: NSPoint) {
        guard let panel else { return }
        let fallbackScreen = NSScreen.main?.visibleFrame ?? .zero
        let screenFrame = screenContaining(point: point)?.visibleFrame ?? fallbackScreen
        guard !screenFrame.isEmpty else { return }
        
        let minX = screenFrame.minX + edgePadding
        let minY = screenFrame.minY + edgePadding
        let maxX = max(minX, screenFrame.maxX - panelSize.width - edgePadding)
        let maxY = max(minY, screenFrame.maxY - panelSize.height - edgePadding)
        
        let proposedX = point.x - panelSize.width / 2
        let proposedY = point.y - panelSize.height / 2
        
        let origin = NSPoint(
            x: min(max(proposedX, minX), maxX),
            y: min(max(proposedY, minY), maxY)
        )
        panel.setFrameOrigin(origin)
    }
    
    private func screenContaining(point: NSPoint) -> NSScreen? {
        NSScreen.screens.first { NSMouseInRect(point, $0.frame, false) }
    }
}
