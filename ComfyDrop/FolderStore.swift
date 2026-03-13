//
//  FolderStore.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import Combine
import Foundation
import SwiftUI

/**
 * Handles Persistance of selected folder
 */
@MainActor
public final class FolderStore: ObservableObject {
    
    @AppStorage("WatchFolderPath")
    private var watchFolderPath: String?
    
    @Published public var watchFolder: URL?
    
    public init() {
        if let path = watchFolderPath {
            watchFolder = URL(fileURLWithPath: path)
        }
    }
    
    public func setWatchFolder(_ url: URL) {
        watchFolder = url
        watchFolderPath = url.path
    }
    
    public func clear() {
        watchFolder = nil
        watchFolderPath = nil
    }
}
