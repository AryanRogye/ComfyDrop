//
//  ComfyDropMenuBarViewModel.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import Foundation

@Observable
@MainActor
class ComfyDropMenuBarViewModel {
    
    var started : Bool {
        mouseWatcher.monitor != nil
    }
    
    let mouseWatcher : MouseWatcher
    let folderStore  : FolderStore
    
    init(mouseWatcher: MouseWatcher, folderStore: FolderStore) {
        self.mouseWatcher = mouseWatcher
        self.folderStore = folderStore
    }
    
    public func toggle() {
        if started {
            stop()
        } else {
            start()
        }
    }
    
    public func start() {
        mouseWatcher.start()
    }
    
    public func stop() {
        mouseWatcher.stop()
    }
}
