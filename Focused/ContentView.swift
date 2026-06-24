import SwiftUI
import Combine

// App entry point
@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    // Controls which screen is showing
    @State private var isSelecting = true

    // The duration the user picked on the selection screen
    @State private var selectedMinutes = 25

    // Total seconds for the session — set when the user taps Start
    @State private var totalSeconds = 25 * 60

    // How many seconds are left on the countdown
    @State private var secondsRemaining = 25 * 60

    // Whether the timer is actively ticking
    @State private var isRunning = false

    // Fires every second on the main thread
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // 1.0 when full, shrinks toward 0.0 as time runs out
    var progress: Double {
        Double(secondsRemaining) / Double(totalSeconds)
    }

    // Converts raw seconds into a MM:SS string
    var timeString: String {
        String(format: "%02d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }

    var body: some View {
        ZStack {
            // Dark purple background filling the whole screen
            Color(red: 0.1, green: 0.05, blue: 0.2)
                .ignoresSafeArea()

            if isSelecting {
                // ── SELECTION SCREEN ──────────────────────────
                VStack(spacing: 40) {
                    Text("Focused")
                        .font(.system(size: 36, weight: .light, design: .rounded))
                        .foregroundStyle(.white)

                    // Wheel picker for choosing the session length
                    Picker("Duration", selection: $selectedMinutes) {
                        ForEach([5, 10, 15, 20, 25, 30, 45, 60], id: \.self) { m in
                            Text(m == 60 ? "1 hour" : "\(m) min").tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                    .colorScheme(.dark)

                    // Locks in the chosen duration and starts the timer
                    Button("Start") {
                        totalSeconds = selectedMinutes * 60
                        secondsRemaining = selectedMinutes * 60
                        isRunning = true
                        isSelecting = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.5, green: 0.3, blue: 0.9))
                    .font(.system(size: 20, weight: .light, design: .rounded))
                }

            } else {
                // ── TIMER SCREEN ──────────────────────────────
                VStack(spacing: 40) {
                    // Inner ZStack layers the two rings and the countdown
                    ZStack {
                        // Faint track showing the full circle
                        Circle()
                            .stroke(Color.purple.opacity(0.2), lineWidth: 14)

                        // Light purple arc that drains as time passes
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                Color(red: 0.7, green: 0.5, blue: 1.0),
                                style: StrokeStyle(lineWidth: 14, lineCap: .round)
                            )
                            // Start the arc from the top of the circle
                            .rotationEffect(.degrees(-90))
                            // Smooth 1-second animation between each tick
                            .animation(.linear(duration: 1), value: progress)

                        // Countdown display
                        Text(timeString)
                            .font(.system(size: 56, weight: .light, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 260, height: 260)

                    HStack(spacing: 24) {
                        if isRunning {
                            // Timer is running — only show the pause button
                            Button("Pause") {
                                isRunning = false
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(red: 0.5, green: 0.3, blue: 0.9))
                        } else {
                            // Timer is paused — show resume on the left
                            Button("Resume") {
                                isRunning = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(red: 0.5, green: 0.3, blue: 0.9))

                            // Cancel stops the timer and returns to time selection
                            Button("Cancel") {
                                isRunning = false
                                isSelecting = true
                            }
                            .buttonStyle(.bordered)
                            .tint(Color(red: 0.7, green: 0.5, blue: 1.0))
                        }
                    }
                    .font(.title2)
                }
            }
        }
        // Every second, subtract one if the timer is running
        .onReceive(timer) { _ in
            guard isRunning, secondsRemaining > 0 else {
                if secondsRemaining == 0 { isRunning = false }
                return
            }
            secondsRemaining -= 1
        }
    }
}
