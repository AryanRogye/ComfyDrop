//
//  MouseDropViewModel.swift
//  MouseDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import Foundation

@Observable
@MainActor
class MouseDropViewModel {
    
    var started = false
    
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
        
        started.toggle()
    }
    
    public func start() {
        mouseWatcher.start()
    }
    
    public func stop() {
        mouseWatcher.stop()
    }
}
