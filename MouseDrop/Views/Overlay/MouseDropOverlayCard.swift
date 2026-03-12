//
//  MouseDropOverlayCard.swift
//  MouseDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import AppKit
import SwiftUI

struct MouseDropOverlayCard: View {
    let selectedFolderName: String
    let hasSelectedFolder: Bool
    let loadError: String?
    let folderItems: [OverlayFolderItem]
    @Binding var hoveredID: URL?
    let onClose: () -> Void
    let dragProvider: (OverlayFolderItem) -> NSItemProvider
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MouseDropOverlayHeader(
                selectedFolderName: selectedFolderName,
                itemCount: folderItems.count,
                onClose: onClose
            )
            
            if !hasSelectedFolder {
                MouseDropOverlayStateMessage(text: "Pick a folder from the menu bar.", color: .secondary)
            } else if let loadError {
                MouseDropOverlayStateMessage(text: loadError, color: .red)
            } else if folderItems.isEmpty {
                MouseDropOverlayStateMessage(text: "This folder is empty.", color: .secondary)
            } else {
                MouseDropOverlayFilmStrip(
                    items: folderItems,
                    hoveredID: $hoveredID,
                    dragProvider: dragProvider
                )
            }
        }
        .padding(12)
        .frame(width: 400, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.black.opacity(0.72))
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.5), radius: 20, y: 8)
    }
}

private struct MouseDropOverlayStateMessage: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(color.opacity(0.7))
            .padding(.vertical, 8)
    }
}
