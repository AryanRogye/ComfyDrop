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
    lazy var vm = ComfyDropOverlayViewModel(folderStore: folderStore)
    
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
    
    
    @Test("Verify Content Size")
    func TextContentSize() async throws {
        let url = FileManager.default.homeDirectoryForCurrentUser
        
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .contentModificationDateKey]
        let urls = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsHiddenFiles]
        )
        folderStore.setWatchFolder(url)
        
        vm.reloadFolderItems()
        /// Big Issue Here sometimes it comes to 0 right after
        #expect(vm.folderItems.count != 0)
        #expect(vm.folderItems.count == urls.count)
    }
}
