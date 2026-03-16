//
//  SettingsStore.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import SwiftUI
import Defaults

@Observable
@MainActor
class SettingsStore {
    
    var onStartOnLaunchIsOn:  (() -> Void)?
    var onStartOnLaunchIsOff:  (() -> Void)?
    
    var strictGestures: Bool = Defaults[.strictGestures] {
        didSet {
            Defaults[.strictGestures] = strictGestures
        }
    }
    
    var startOnLaunch: Bool = Defaults[.startOnLaunch] {
        didSet {
            Defaults[.startOnLaunch] = startOnLaunch
            handleStartOnLaunchChange()
        }
    }
    
    /// Public API to trigger actions that should occur after persistence changes
    public func sync() {
        handleStartOnLaunchChange()
    }
    
    /// Turning off after clicking the setting, is the intended logic
    private func handleStartOnLaunchChange() {
        if startOnLaunch {
            onStartOnLaunchIsOn?()
        } else {
            onStartOnLaunchIsOff?()
        }
    }
}

extension Defaults.Keys {
    static let strictGestures = Key<Bool>("strictGesturesKey", default: true)
    static let startOnLaunch = Key<Bool>("startOnLaunchKey", default: false)
}
