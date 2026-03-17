//
//  ComfyDropOverlayCard.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import AppKit
import SwiftUI

struct ComfyDropOverlayCard: View {
    @Bindable var vm: ComfyDropOverlayViewModel
    let selectedFolderName: String
    let hasSelectedFolder: Bool
    @Binding var hoveredID: URL?
    let onClose: () -> Void
    let dragProvider: (OverlayFolderItem) -> NSItemProvider
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ComfyDropOverlayHeader(
                selectedFolderName: selectedFolderName,
                itemCount: vm.folderItems.count,
                onClose: onClose
            )
            
            if !hasSelectedFolder {
                ComfyDropOverlayStateMessage(text: "Pick a folder from the menu bar.", color: .secondary)
            } else if let loadError = vm.loadError {
                ComfyDropOverlayStateMessage(text: loadError, color: .red)
            } else if vm.folderItems.isEmpty {
                ComfyDropOverlayStateMessage(text: "This folder is empty.", color: .secondary)
            } else {
                ComfyDropOverlayFilmStrip(
                    items: vm.folderItems,
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
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ComfyDropOverlayStateMessage: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(color.opacity(0.7))
            .padding(.vertical, 8)
    }
}
