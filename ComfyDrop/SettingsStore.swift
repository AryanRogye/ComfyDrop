//
//  SettingsStore.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import SwiftUI
import Defaults
import ServiceManagement

extension Defaults.Keys {
    static let strictGestures = Key<Bool>("strictGesturesKey", default: true)
    static let startOnLaunch = Key<Bool>("startOnLaunchKey", default: false)
    static let launchAtLogin = Key<Bool>("launchAtLoginKey", default: false)
}

@Observable
@MainActor
class SettingsStore {
    
    var onStartOnLaunchIsOn:  (() -> Void)?
    var onStartOnLaunchIsOff:  (() -> Void)?
    
    /// Handles Strict Gestures, ``MouseWatcher`` uses this on calculations
    var strictGestures: Bool = Defaults[.strictGestures] {
        didSet {
            Defaults[.strictGestures] = strictGestures
        }
    }
    
    /// "Run on Launch" Handles starting the ``MouseWatcher`` when the app runs
    var startOnLaunch: Bool = Defaults[.startOnLaunch] {
        didSet {
            Defaults[.startOnLaunch] = startOnLaunch
            handleStartOnLaunchChange()
        }
    }
    
    var launchAtLogin: Bool = Defaults[.launchAtLogin] {
        didSet {
            Defaults[.launchAtLogin] = launchAtLogin
            handleLaunchAtLoginChange()
        }
    }
    
    /// Public API to trigger actions that should occur after persistence changes
    /// This would be called instead of init
    public func sync() {
        handleStartOnLaunchChange()
        handleLaunchAtLoginChange()
    }
}

extension SettingsStore {
    
    /// Turning off after clicking the setting, is the intended logic
    internal func handleStartOnLaunchChange() {
        if startOnLaunch {
            onStartOnLaunchIsOn?()
        } else {
            onStartOnLaunchIsOff?()
        }
    }
    
    internal func handleLaunchAtLoginChange() {
        if launchAtLogin {
            if SMAppService.mainApp.status == .enabled { return }
            do {
                try SMAppService.mainApp.register()
            } catch {
                print("Couldnt Register ComfyTab to Launch At Login \(error.localizedDescription)")
                /// Toggle it Off
                self.launchAtLogin = false
            }
        }
        /// If Launch At Logic is Turned off
        else {
            /// ONLY go through if the status is enabled
            if SMAppService.mainApp.status != .enabled { return }
            do {
                try SMAppService.mainApp.unregister()
            } catch {
                print("Couldnt Turn Off Launch At Logic for ComfyTab \(error.localizedDescription)")
                self.launchAtLogin = true
            }
        }
    }
}
