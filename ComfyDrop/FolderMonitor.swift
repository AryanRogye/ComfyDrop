//
//  FolderWatcher.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import Foundation

@MainActor
final class FolderMonitor {
    private var fileDescriptor: CInt = -1
    private var source: DispatchSourceFileSystemObject?
    
    var onChange: (() -> Void)?
    
    func startMonitoring(url: URL) {
        stopMonitoring()
        
        fileDescriptor = open(url.path, O_EVTONLY)
        guard fileDescriptor != -1 else {
            print("Failed to open folder for monitoring")
            return
        }
        
        let queue = DispatchQueue.global(qos: .background)
        
        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .rename, .delete],
            queue: queue
        )
        
        source?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.onChange?()
            }
        }
        
        source?.setCancelHandler { [weak self] in
            guard let self else { return }
            if self.fileDescriptor != -1 {
                close(self.fileDescriptor)
                self.fileDescriptor = -1
            }
        }
        
        source?.resume()
    }
    
    func stopMonitoring() {
        source?.cancel()
        source = nil
        
        if fileDescriptor != -1 {
            close(fileDescriptor)
            fileDescriptor = -1
        }
    }
    
    @MainActor
    deinit {
        stopMonitoring()
    }
}
