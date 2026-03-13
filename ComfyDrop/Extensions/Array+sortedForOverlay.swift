//
//  Array+sortedForOverlay.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/13/26.
//

import Foundation

extension Array where Element == OverlayFolderItem {
    func sortedForOverlay() -> [OverlayFolderItem] {
        self.sorted { lhs, rhs in
            if lhs.isDirectory != rhs.isDirectory {
                return !lhs.isDirectory && rhs.isDirectory
            }
            
            let lDate = (try? lhs.url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            let rDate = (try? rhs.url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            
            return lDate > rDate
        }
    }
}
