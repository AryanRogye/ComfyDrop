//
//  MouseDropOverlayHeader.swift
//  MouseDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import AppKit
import SwiftUI

struct MouseDropOverlayHeader: View {
    let selectedFolderName: String
    let itemCount: Int
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                
                Text(selectedFolderName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                Spacer(minLength: 0)
                
                Text("\(itemCount) items")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.35))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(HeaderWindowDragHandle())
            
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(.white.opacity(0.08)))
            }
            .buttonStyle(.plain)
        }
        .frame(minHeight: 24)
    }
}

private struct HeaderWindowDragHandle: NSViewRepresentable {
    func makeNSView(context: Context) -> DragHandleView {
        DragHandleView()
    }
    
    func updateNSView(_ nsView: DragHandleView, context: Context) {}
    
    final class DragHandleView: NSView {
        override func mouseDown(with event: NSEvent) {
            guard let window else {
                super.mouseDown(with: event)
                return
            }
            window.performDrag(with: event)
        }
    }
}
