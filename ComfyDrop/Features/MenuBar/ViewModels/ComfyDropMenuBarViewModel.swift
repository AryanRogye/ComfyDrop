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
    
    init(mouseWatcher: MouseWatcher) {
        self.mouseWatcher = mouseWatcher
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
