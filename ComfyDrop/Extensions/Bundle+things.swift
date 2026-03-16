//
//  Bundle+things.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/16/26.
//

import Foundation

extension Bundle {
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }
}
