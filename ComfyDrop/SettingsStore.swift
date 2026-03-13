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
    var strictGestures: Bool = Defaults[.strictGestures] {
        didSet {
            Defaults[.strictGestures] = strictGestures
        }
    }
}

extension Defaults.Keys {
    static let strictGestures = Key<Bool>("strictGesturesKey", default: true)
}
