//
//  OverlayFolderItem.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import AppKit
import UniformTypeIdentifiers

struct OverlayFolderItem: Identifiable {
    let id: URL
    let url: URL
    let isDirectory: Bool
    let previewImage: NSImage?
    
    var displayName: String {
        url.lastPathComponent
    }
    
    var iconName: String {
        isDirectory ? "folder.fill" : "doc.richtext.fill"
    }
    
    var kindLabel: String {
        if isDirectory { return "Folder" }
        if previewImage != nil { return "Image" }
        return "File"
    }
    
    static func isImageFile(_ url: URL) -> Bool {
        guard let type = UTType(filenameExtension: url.pathExtension) else { return false }
        return type.conforms(to: .image)
    }
}

extension URL {
    func toOverlayFolderItem(keys: Set<URLResourceKey>) -> OverlayFolderItem? {
        guard let values = try? self.resourceValues(forKeys: keys) else { return nil }
        
        let isDirectory = values.isDirectory ?? false
        
        let previewImage = (
            (!isDirectory && OverlayFolderItem.isImageFile(self))
            ? NSImage(contentsOf: self)
            : nil
        )
        
        return OverlayFolderItem(
            id: self,
            url: self,
            isDirectory: isDirectory,
            previewImage: previewImage
        )
    }
}
