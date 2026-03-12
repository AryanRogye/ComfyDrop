//
//  MouseDropOverlayHeader.swift
//  MouseDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import SwiftUI

struct MouseDropOverlayHeader: View {
    let selectedFolderName: String
    let itemCount: Int
    let onClose: () -> Void
    
    var body: some View {
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
            
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(.white.opacity(0.08)))
            }
            .buttonStyle(.plain)
        }
    }
}
