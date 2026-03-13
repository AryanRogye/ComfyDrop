//
//  NSPoint+toSwiftUICoords.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/13/26.
//

import AppKit


extension NSPoint {
    func toSwiftUIPosition() -> CGPoint {
        let screenHeight = NSScreen.main?.frame.height ?? 0
        return CGPoint(
            x: self.x,
            y: screenHeight - self.y
        )
    }
}
