//
//  MouseVisualizer.swift
//  ComfyDrop
//
//  Created by Aryan Rogye on 3/12/26.
//

import SwiftUI

/// Disclaimer: UI Made with Claude

/// Struct to visualize points
struct MouseVisualizer: View {
    
    @Bindable var mouseWatcher: MouseWatcher
    
    var points: [NSPoint] {
        mouseWatcher.mouseLocations
    }
    
    // Normalize points to fit centered in the view with padding
    private func normalizedPoints(in size: CGSize, padding: CGFloat = 32) -> [CGPoint] {
        guard points.count > 1 else { return [] }
        
        let minX = points.map(\.x).min()!
        let maxX = points.map(\.x).max()!
        let minY = points.map(\.y).min()!
        let maxY = points.map(\.y).max()!
        
        let rangeX = maxX - minX
        let rangeY = maxY - minY
        let range = max(rangeX, rangeY, 1)
        
        let drawW = size.width - padding * 2
        let drawH = size.height - padding * 2
        let scale = min(drawW, drawH) / range
        
        let offsetX = padding + (drawW - rangeX * scale) / 2
        let offsetY = padding + (drawH - rangeY * scale) / 2
        
        return points.map { point in
            CGPoint(
                x: offsetX + (point.x - minX) * scale,
                y: offsetY + (maxY - point.y) * scale  // flip Y
            )
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let pts = normalizedPoints(in: geo.size)
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                if pts.count > 1 {
                    Path { path in
                        path.move(to: pts[0])
                        for point in pts.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(
                        LinearGradient(
                            colors: [.cyan.opacity(0.2), .cyan.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
                    )
                }
                
                ForEach(Array(pts.enumerated()), id: \.offset) { i, point in
                    let age = Double(i) / Double(max(pts.count - 1, 1))
                    Circle()
                        .fill(Color.cyan.opacity(0.2 + age * 0.8))
                        .frame(width: i == pts.count - 1 ? 10 : 4,
                               height: i == pts.count - 1 ? 10 : 4)
                        .position(point)
                }
                
                if let last = pts.last {
                    Circle()
                        .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                        .frame(width: 20, height: 20)
                        .position(last)
                }
            }
        }
        .overlay(alignment: .topLeading) {
            Text("\(points.count) points")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.cyan.opacity(0.6))
                .padding(10)
        }
    }
}
