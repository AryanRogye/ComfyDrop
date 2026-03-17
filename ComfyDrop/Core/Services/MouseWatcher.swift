//
//  MouseWatcher.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import AppKit

@Observable
@MainActor
class MouseWatcher {
    
    private var settingsStore : SettingsStore
    
    public var monitor: Any?
    /// We Wont be showing this anyhwere so we dont need to "observe it" its more for a internal flag
    @ObservationIgnored
    private var isMouseDown: Bool = false
    
    /// We Wanna show this off cool
    public var mouseLocations: [NSPoint] = []
    public var center: NSPoint = .zero
    
    /// have it do nothing for now
    @ObservationIgnored
    public var onMouseActivation: (() -> Void) = {
        
    }
    
    /// Nothing for now
    @ObservationIgnored
    public var onFirstLaunchDemo: (() -> Void) = {
        
    }
    
    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore
    }
    
    @ObservationIgnored
    var mouseTask: Task<Void, Never>? = nil
    
    public func start() {
        guard monitor == nil else { return }
        monitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown ,.leftMouseUp, .leftMouseDragged],
            handler: { [weak self] e in
                guard let self else { return }
                
                /// Activation
                if (e.type == .leftMouseDown && !isMouseDown) {
                    isMouseDown = true
                    /// Clear Mouse Locations
                    self.mouseLocations.removeAll(keepingCapacity: true)
                }
                /// Took Mouse Up
                if (e.type == .leftMouseUp && isMouseDown) {
                    if mouseTask != nil { return }
                    mouseTask = Task {
                        defer {
                            self.mouseTask = nil
                            self.mouseTask?.cancel()
                        }
                        
                        self.isMouseDown = false
                        await self.evaluateMouseLocationsAndClear()
                    }
                }
                
                /// If Mouse is Down Store Mouse Locations
                if (isMouseDown) {
                    let currentLocation = NSEvent.mouseLocation
                    
                    // Throttle: Only append if it moved more than 5 pixels
                    if let lastLocation = self.mouseLocations.last {
                        let distance = hypot(currentLocation.x - lastLocation.x, currentLocation.y - lastLocation.y)
                        if distance > 5.0 {
                            self.mouseLocations.append(currentLocation)
                        }
                    } else {
                        self.mouseLocations.append(currentLocation)
                    }
                }
            }
        )
    }
    
    /**
     * DISCLAIMER: Algorithm was handwritten by me,
     * though Algorithm was provided by ChatGPT
     */
    private func evaluateMouseLocationsAndClear() async {
        
        let points = self.mouseLocations
        let checkSidebySide : Task<Bool, Never> = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return false }
            guard points.count >= 2 else { return false }
            
            let xs = points.map(\.x)
            let ys = points.map(\.y)
            
            guard let minX = xs.min(),
                  let maxX = xs.max(),
                  let minY = ys.min(),
                  let maxY = ys.max() else {
                return false
            }
            
            let width = maxX - minX
            let height = maxY - minY
            
            // avoid garbage tiny movements
            let minMovement: CGFloat = 20
            if max(width, height) < minMovement {
                return false
            }
            
            let ratio: CGFloat = 2.0
            
            // horizontal line
            if width > height * ratio {
                return true
            }
            
            // vertical line
            if height > width * ratio {
                return true
            }
            
            // otherwise more balanced = circle/curve/diagonal/mixed
            return false
        }
        
        guard mouseLocations.count >= 3 else {
            mouseLocations.removeAll(keepingCapacity: true)
            return
        }
        
        /// Direction of Motion
        var parameterVector: [CGFloat] = []
        /// Parameter Vector is determined by atan2(y_i+1 −y_i ,x_i+1 −x_i)
        for i in 0..<(mouseLocations.count - 1) {
            let currentPoint = mouseLocations[i]
            let nextPoint = mouseLocations[i + 1]
            
            let x = nextPoint.x - currentPoint.x
            let y = nextPoint.y - currentPoint.y
            
            /// Skip duplicate points so atan2 doesn't get garbage
            if x == 0 && y == 0 { continue }
            
            let tangent = atan2(y, x)
            parameterVector.append(tangent)
        }
        
        guard parameterVector.count >= 2 else {
            self.mouseLocations.removeAll(keepingCapacity: true)
            return
        }
        
        /// Compute how direction Changes
        /// Δθ_i​=θ_i+1​−θ_i
        var directionChanges : [CGFloat] = []
        for i in 0..<parameterVector.count-1 {
            let currentAngle = parameterVector[i]
            let nextAngle = parameterVector[i + 1]
            
            var change = nextAngle - currentAngle
            
            /// Normalize to stay between -π and π
            if change > .pi {
                change -= 2 * .pi
            } else if change < -.pi {
                change += 2 * .pi
            }
            
            directionChanges.append(change)
        }
        
        var turning: CGFloat = 0
        for directionChange in directionChanges {
            turning += directionChange
        }
        
        let startPoint = mouseLocations.first!
        let endPoint = mouseLocations.last!
        let distanceFromStartToEnd = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y)
        
        print("Turning: \(turning)")
        print("Distance From Start To End: \(distanceFromStartToEnd)")
        
        // strict mode: tight circle, well closed
        let strictChecker = abs(turning) > 1.5 * .pi && distanceFromStartToEnd < 80
        // lenient mode: big loose circle, doesn't need to close
        let lenientChecker = abs(turning) > 1.4 * .pi && distanceFromStartToEnd < 120
        
        let checker = settingsStore.strictGestures ? strictChecker : lenientChecker

        if checker {
            calcCenter()
            onMouseActivation()
        } else {
//            print("This does not look like a circle")
        }
    }
    
    public func stop() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
    }
    
    private func calcCenter() {
        if mouseLocations.isEmpty { center = .zero; return }
        
        let sumX = mouseLocations.map(\.x).reduce(0, +)
        let sumY = mouseLocations.map(\.y).reduce(0, +)
        let count = CGFloat(mouseLocations.count)
        
        center = NSPoint(x: sumX / count, y: sumY / count)
    }
}
