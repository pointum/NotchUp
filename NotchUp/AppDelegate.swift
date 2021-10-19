//
//  AppDelegate.swift
//  NotchUp
//
//  Created by Maxim Ananov on 19.10.21.
//  © 2021 Maxim Ananov. All rights reserved.
//

import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var mouseMonitor: Any!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NotchWindow.show()

        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved)
            { _ in NotchWindow.updateForMouse() }
    }

    func applicationDidChangeScreenParameters(_ notification: Notification) {
        NotchWindow.updateFrame()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApp.terminate(nil)
        return true
    }
}

