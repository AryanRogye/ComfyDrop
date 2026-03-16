//
//  AlertMaker.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/16/26.
//

import AppKit

struct AlertMaker {
    public static func makeAlert(
        messageText: String,
        informativeText: String,
        style: NSAlert.Style,
        buttons: [String]
    ) -> NSAlert {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.alertStyle = style
        
        for button in buttons {
            alert.addButton(withTitle: button)
        }
        
        return alert
    }
}
