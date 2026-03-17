//
//  ComfyDropOverlayViewModel.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/13/26.
//

import Foundation
import AppKit

@Observable
@MainActor
public final class ComfyDropOverlayViewModel {
    
    /// Objects
    let monitor = FolderMonitor()
    let folderStore: FolderStore
    
    public var folderItems: [OverlayFolderItem] = []
    var loadError: String?

    public init(folderStore: FolderStore) {
        self.folderStore = folderStore
    }
    
    public func stop() {
        monitor.stopMonitoring()
    }
    
    
    // MARK: - Helpers
    public func startMonitoringFolder() {
        guard let folderURL = folderStore.watchFolder else { return }
        
        monitor.onChange = { [weak self] in
            guard let self else { return }
            self.reloadFolderItems()
        }
        
        monitor.startMonitoring(url: folderURL)
    }
    
    public func reloadFolderItems() {
        guard let folderURL = folderStore.watchFolder else {
            folderItems = []
            loadError = nil
            print("|ComfyDropOverlayViewModel:reloadFolderItems| No watch folder set.")
            return
        }
        
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .contentModificationDateKey]
        
        do {
            let urls = try FileManager.default.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: Array(keys),
                options: [.skipsHiddenFiles]
            )
            
            folderItems = urls
                .compactMap {
                    /// See OverlayFolderItem for the extension
                    $0.toOverlayFolderItem(keys: keys)
                }
                .sortedForOverlay()
            
            loadError = nil
        } catch {
            folderItems = []
            loadError = "Could not read folder: \(error.localizedDescription)"
        }
    }
}
