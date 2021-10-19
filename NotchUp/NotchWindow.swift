//
//  NotchWindow.swift
//  NotchUp
//
//  Created by Maxim Ananov on 19.10.21.
//  © 2021 Maxim Ananov. All rights reserved.
//

import AppKit

enum NotchWindow {

    static var window: NSWindow!

    static func show() {
        updateMetrics()
        window = createWindow(with: frame)
        let contentRect = window.contentRect(forFrameRect: window.frame)
        let contentView = NotchView(frame: contentRect)
        window.contentView = contentView

        window.makeKeyAndOrderFront(nil)
    }

    private static func createWindow(with frame: NSRect) -> NSWindow {
        let window = NSWindow(contentRect: frame, styleMask: .borderless,
                             backing: .buffered, defer: false, screen: .main)
        [window].forEach {
            $0.isMovable = false
            $0.collectionBehavior = [.stationary, .ignoresCycle, .canJoinAllSpaces, .fullScreenPrimary]
            $0.level = .screenSaver
            $0.ignoresMouseEvents = true
            $0.isOpaque = false
            $0.hasShadow = false
            $0.backgroundColor = .clear
        }

        return window
    }

    fileprivate private(set) static var radius = 0.0
    private static var frame = NSRect()

    private static let ptRadius = 8.0
    private static let ptSize = NSSize(width: 200, height: 32)

    // 16" ppi / 2 / (mm per inch)
    private static let notchPointsPerMm = 254 / 2 / 25.4

    private static func updateMetrics() {
        let screenFrame = NSScreen.main?.frame ?? .zero
        let mmSize = CGDisplayScreenSize(CGMainDisplayID())
        let screenPointsPerMm = screenFrame.width / mmSize.width
        let scale = screenPointsPerMm / notchPointsPerMm

        radius = ptRadius * scale
        let width = ptSize.width * scale
        let height = ptSize.height * scale

        frame = NSRect(x: (screenFrame.width - width) / 2,
                       y: screenFrame.height - height,
                       width: width, height: height)
    }

    static func updateFrame() {
        updateMetrics()
        window?.setFrame(frame, display: true)
    }

    private static var opacity = 1.0 {
        didSet {
            guard opacity != oldValue else { return }
            window?.alphaValue = opacity
        }
    }

    static func updateForMouse() {
        let pt = NSEvent.mouseLocation
        let dx = max(frame.minX - pt.x, 0, pt.x - frame.maxX)
        let dy = max(frame.minY - pt.y, 0, pt.y - frame.maxY)
        let distance = sqrt(dx*dx + dy*dy)

        opacity = min(distance / 30, 0.7) + 0.3
    }
}

private class NotchView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        let r = NotchWindow.radius

        let path = NSBezierPath()
        path.appendArc(withCenter: NSPoint(x: bounds.minX, y: bounds.maxY - r),
                       radius: r, startAngle: 90, endAngle: 0, clockwise: true)
        path.appendArc(withCenter: NSPoint(x: bounds.minX + 2 * r, y: bounds.minY + r),
                       radius: r, startAngle: 180, endAngle: 270)
        path.appendArc(withCenter: NSPoint(x: bounds.maxX - 2 * r, y: bounds.minY + r),
                       radius: r, startAngle: 270, endAngle: 0)
        path.appendArc(withCenter: NSPoint(x: bounds.maxX, y: bounds.maxY - r),
                       radius: r, startAngle: 180, endAngle: 90, clockwise: true)

        NSColor.black.set()
        path.fill()
    }
}
