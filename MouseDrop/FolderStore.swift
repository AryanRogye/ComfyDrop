//
//  FolderStore.swift
//  MouseDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class FolderStore: ObservableObject {
    @AppStorage("WatchFolderBookmark")
    private var watchFolderBookmarkData: Data?
    
    @Published var watchFolder: URL?
    
    init() {
        watchFolder = resolvedWatchFolderURL()
    }
    
    func setWatchFolder(_ url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
            watchFolderBookmarkData = bookmarkData
            watchFolder = url
        } catch {
            watchFolderBookmarkData = nil
            watchFolder = nil
            print("Bookmark creation failed: \(error.localizedDescription)")
        }
    }
    
    func resolvedWatchFolderURL() -> URL? {
        guard let watchFolderBookmarkData else {
            return nil
        }
        
        var isStale = false
        
        do {
            let url = try URL(
                resolvingBookmarkData: watchFolderBookmarkData,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
            if isStale {
                do {
                    let newBookmarkData = try url.bookmarkData(
                        options: .withSecurityScope,
                        includingResourceValuesForKeys: nil,
                        relativeTo: nil
                    )
                    self.watchFolderBookmarkData = newBookmarkData
                } catch {
                    print("Failed to refresh stale bookmark: \(error.localizedDescription)")
                }
            }
            
            return url
        } catch {
            print("Bookmark resolution failed: \(error.localizedDescription)")
            return nil
        }
    }
}
