//
//  OnboardingCoordinator.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/16/26.
//

import SwiftUI
import AppKit

final class OnboardingCoordinator {

    private var panel: NSPanel?
    private let panelSize = NSSize(width: 420, height: 360)
    private var isDestroyed = false

    public func show() {
        guard !isDestroyed else { return }
        guard panel == nil else {
            panel?.orderFront(nil)
            return
        }

        setupPanel()
        panel?.orderFront(nil)
    }

    private func setupPanel() {
        let newPanel = FocusablePanel(
            contentRect: NSRect(origin: .zero, size: panelSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        let overlayRaw = CGWindowLevelForKey(.overlayWindow)
        newPanel.level = NSWindow.Level(rawValue: Int(overlayRaw))

        newPanel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .fullScreenDisallowsTiling,
            .ignoresCycle,
            .transient
        ]

        newPanel.isMovableByWindowBackground = false
        newPanel.backgroundColor = .clear
        newPanel.isOpaque = false
        newPanel.hasShadow = false
        newPanel.ignoresMouseEvents = true
        newPanel.setContentSize(panelSize)
        newPanel.center()

        let hostingView = NSHostingView(rootView: OnboardingView())
        newPanel.contentView = hostingView

        panel = newPanel
    }

    public func destroy() {
        guard !isDestroyed else { return }
        isDestroyed = true

        panel?.orderOut(nil)
        panel?.contentView = nil
        panel = nil
    }
}
