//
//  OnboardingView.swift
//  ComfyDrop
//
//  Created by Claude on 3/16/26.
//

import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View {

    // ── Animation state ──────────────────────────────────────

    /// Phase cycles 0 → 1 → 2 → 0 …  (press → draw → release)
    @State private var phase: Int = 0

    /// How far the "drawing" arc has progressed (0 … 1)
    @State private var drawProgress: CGFloat = 0

    /// Whether the simulated cursor dot is "pressed"
    @State private var cursorPressed: Bool = false

    /// Angle of the cursor dot along the circle path (radians)
    @State private var cursorAngle: CGFloat = -.pi / 2   // start at top

    /// Controls the breathing ring
    @State private var breathes: Bool = false

    /// Opacity for the step labels
    @State private var stepOpacity: CGFloat = 1

    // ── Layout constants ────────────────────────────────────
    private let ringRadius: CGFloat = 52
    private let ringLineWidth: CGFloat = 4
    private let cursorSize: CGFloat = 16
    private let phaseDurations: [Double] = [1.2, 2.0, 1.2]   // press, draw, release

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // ── Title ─────────────────────────────────
                Text("How to Open ComfyDrop")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
                    .textCase(.uppercase)
                    .tracking(1.2)

                // ── Interactive ring area ─────────────────
                ZStack {
                    // Faint guide ring (always visible)
                    Circle()
                        .stroke(.white.opacity(0.12), lineWidth: ringLineWidth)
                        .frame(width: ringRadius * 2, height: ringRadius * 2)
                        .scaleEffect(breathes ? 1.06 : 0.96)
                        .animation(
                            .easeInOut(duration: 1.3)
                            .repeatForever(autoreverses: true),
                            value: breathes
                        )

                    // Dashed guide ring (always visible, shows "path to follow")
                    Circle()
                        .stroke(
                            .white.opacity(0.18),
                            style: StrokeStyle(lineWidth: 2, dash: [4, 6])
                        )
                        .frame(width: ringRadius * 2, height: ringRadius * 2)

                    // Progress arc – drawn as the simulated cursor moves
                    Circle()
                        .trim(from: 0, to: drawProgress)
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color(hue: 0.58, saturation: 0.7, brightness: 1.0).opacity(0.4),
                                    Color(hue: 0.58, saturation: 0.7, brightness: 1.0)
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                        )
                        .frame(width: ringRadius * 2, height: ringRadius * 2)
                        .rotationEffect(.degrees(-90))

                    // ── Cursor dot ──────────────────────
                    Circle()
                        .fill(cursorPressed ? Color.white : Color.white.opacity(0.6))
                        .frame(width: cursorSize, height: cursorSize)
                        .shadow(
                            color: cursorPressed
                                ? Color(hue: 0.58, saturation: 0.8, brightness: 1).opacity(0.7)
                                : .clear,
                            radius: cursorPressed ? 10 : 0
                        )
                        .scaleEffect(cursorPressed ? 1.2 : 0.85)
                        .offset(cursorOffset)
                        .animation(.easeInOut(duration: 0.25), value: cursorPressed)
                }
                .frame(width: ringRadius * 2 + 40, height: ringRadius * 2 + 40)

                // ── Step indicator ────────────────────────
                VStack(spacing: 8) {
                    Text(stepTitle)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .contentTransition(.numericText())

                    Text(stepSubtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .contentTransition(.numericText())
                }
                .opacity(stepOpacity)

                // ── Step dots ─────────────────────────────
                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Capsule()
                            .fill(phase == i ? .white : .white.opacity(0.25))
                            .frame(width: phase == i ? 20 : 6, height: 6)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: phase)
                    }
                }
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
        }
        .allowsHitTesting(false)
        .onAppear {
            breathes = true
            runLoop()
        }
    }

    // MARK: - Computed Helpers

    private var stepTitle: String {
        switch phase {
        case 0: return "Press & Hold"
        case 1: return "Draw a Circle"
        case 2: return "Release"
        default: return ""
        }
    }

    private var stepSubtitle: String {
        switch phase {
        case 0: return "Click anywhere on screen"
        case 1: return "Drag your mouse in a loop"
        case 2: return "Let go to activate"
        default: return ""
        }
    }

    private var cursorOffset: CGSize {
        CGSize(
            width: cos(cursorAngle) * ringRadius,
            height: sin(cursorAngle) * ringRadius
        )
    }

    // MARK: - Animation Loop

    private func runLoop() {
        Task {
            // Tiny initial delay
            try? await Task.sleep(for: .milliseconds(400))

            while !Task.isCancelled {
                // ── Phase 0: Press ─────────────────────
                await setPhase(0)
                // Reset to top of circle
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        drawProgress = 0
                        cursorAngle = -.pi / 2
                    }
                }
                try? await Task.sleep(for: .milliseconds(400))
                // Simulate press
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        cursorPressed = true
                    }
                }
                try? await Task.sleep(for: .milliseconds(Int(phaseDurations[0] * 1000)))

                // ── Phase 1: Draw ──────────────────────
                await setPhase(1)
                // Animate drawing the circle
                let drawDuration = phaseDurations[1]
                let steps = 60
                let interval = drawDuration / Double(steps)
                for step in 1...steps {
                    guard !Task.isCancelled else { return }
                    try? await Task.sleep(for: .milliseconds(Int(interval * 1000)))
                    let t = CGFloat(step) / CGFloat(steps)
                    await MainActor.run {
                        drawProgress = t
                        cursorAngle = -.pi / 2 + t * 2 * .pi
                    }
                }
                try? await Task.sleep(for: .milliseconds(200))

                // ── Phase 2: Release ───────────────────
                await setPhase(2)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        cursorPressed = false
                    }
                }
                try? await Task.sleep(for: .milliseconds(Int(phaseDurations[2] * 1000)))

                // Reset + brief pause before looping
                try? await Task.sleep(for: .milliseconds(600))
            }
        }
    }

    private func setPhase(_ p: Int) async {
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.15)) {
                stepOpacity = 0
            }
        }
        try? await Task.sleep(for: .milliseconds(150))
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.25)) {
                phase = p
                stepOpacity = 1
            }
        }
    }
}

#Preview {
    OnboardingView()
}
