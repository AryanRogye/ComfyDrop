//
//  ComfyDropTests.swift
//  ComfyDropTests
//
//  Created by Aryan Rogye on 3/13/26.
//

import Testing
import ComfyDrop
import Foundation

@MainActor
class FolderStoreTests {
    
    var folderStore : FolderStore
    var watchFolder: URL?
    
    init() {
        self.folderStore = FolderStore()
        watchFolder = folderStore.watchFolder
        folderStore.clear()
    }
    
    @MainActor
    deinit {
        if let watchFolder {
            self.folderStore.setWatchFolder(watchFolder)
        }
    }
    
    @Test("Test Init")
    func TestInit() async throws {
        #expect(folderStore.watchFolder == nil)
    }
    
    @Test("Test Set WatchFolder")
    func TestWatchFolder() async throws {
        let url = FileManager.default.homeDirectoryForCurrentUser
        folderStore.setWatchFolder(url)
        let resolved = folderStore.watchFolder
        
        #expect(resolved != nil)
        #expect(resolved?.lastPathComponent == url.lastPathComponent)
    }
}
