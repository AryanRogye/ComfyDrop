//
//  MouseDropOverlayFilmStrip.swift
//  MouseDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import AppKit
import SwiftUI

struct MouseDropOverlayFilmStrip: View {
    let items: [OverlayFolderItem]
    @Binding var hoveredID: URL?
    let dragProvider: (OverlayFolderItem) -> NSItemProvider
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                ForEach(items) { item in
                    OverlayFilmTile(
                        item: item,
                        isHovered: hoveredID == item.id
                    )
                    .overlay(
                        HoverTracker { hovering in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                hoveredID = hovering ? item.id : nil
                            }
                        }
                    )
                    .onDrag {
                        dragProvider(item)
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
        }
        .scrollIndicators(.never)
    }
}

private struct OverlayFilmTile: View {
    let item: OverlayFolderItem
    let isHovered: Bool
    
    private let size: CGFloat = 96
    
    var body: some View {
        VStack(spacing: 6) {
            thumbnail
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(
                            isHovered ? Color.white.opacity(0.6) : Color.white.opacity(0.1),
                            lineWidth: isHovered ? 1.5 : 0.5
                        )
                )
                .shadow(color: .black.opacity(isHovered ? 0.45 : 0.15), radius: isHovered ? 10 : 3, y: isHovered ? 5 : 1)
            
            Text(item.displayName)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(isHovered ? 0.9 : 0.5))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .truncationMode(.middle)
                .frame(width: size)
        }
        .scaleEffect(isHovered ? 1.06 : 1.0, anchor: .bottom)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .zIndex(isHovered ? 1 : 0)
    }
    
    @ViewBuilder
    private var thumbnail: some View {
        if let image = item.previewImage {
            Image(nsImage: image)
                .resizable()
                .scaledToFill()
                .background(Color.white.opacity(0.06))
        } else {
            ZStack {
                Color.white.opacity(0.06)
                Image(systemName: item.iconName)
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(item.isDirectory ? Color.accentColor.opacity(0.9) : .white.opacity(0.4))
            }
        }
    }
}
