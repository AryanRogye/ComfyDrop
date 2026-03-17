//
//  HoverTracker.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import AppKit
import SwiftUI

struct HoverTracker: NSViewRepresentable {
    var onHover: (Bool) -> Void
    
    func makeNSView(context: Context) -> TrackerView {
        let view = TrackerView()
        view.onHover = onHover
        return view
    }
    
    func updateNSView(_ nsView: TrackerView, context: Context) {
        nsView.onHover = onHover
    }
    
    final class TrackerView: NSView {
        var onHover: ((Bool) -> Void)?
        private var trackingArea: NSTrackingArea?
        
        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            if let existingArea = trackingArea {
                removeTrackingArea(existingArea)
            }
            
            let area = NSTrackingArea(
                rect: bounds,
                options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                owner: self,
                userInfo: nil
            )
            addTrackingArea(area)
            trackingArea = area
        }
        
        override func mouseEntered(with event: NSEvent) {
            onHover?(true)
        }
        
        override func mouseExited(with event: NSEvent) {
            onHover?(false)
        }
    }
}
