import SwiftUI
import Combine

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    // Total session length — used to calculate how full the ring should be
    let totalSeconds = 25 * 60

    // Track how many seconds are left and whether the timer is running
    @State private var secondsRemaining = 25 * 60
    @State private var isRunning = false

    // Fires every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // 1.0 when full, shrinks toward 0.0 as time runs out
    var progress: Double {
        Double(secondsRemaining) / Double(totalSeconds)
    }

    // Format seconds into MM:SS
    var timeString: String {
        String(format: "%02d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }

    var body: some View {
        // Outer ZStack so the dark purple background sits behind everything
        ZStack {
            // Dark purple background
            Color(red: 0.1, green: 0.05, blue: 0.2)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                // Inner ZStack layers the two rings and the countdown on top of each other
                ZStack {
                    // Faint full circle acting as the ring track
                    Circle()
                        .stroke(Color.purple.opacity(0.2), lineWidth: 14)

                    // Light purple arc, trimmed by progress so it drains as time passes
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color(red: 0.7, green: 0.5, blue: 1.0),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        // Rotate so the arc starts at the top instead of the right
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
                        // Timer is paused — show start on the left, reset on the right
                        Button("Start") {
                            isRunning = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0.5, green: 0.3, blue: 0.9))

                        // Stops the timer and resets to 25 minutes
                        Button("Reset") {
                            isRunning = false
                            secondsRemaining = totalSeconds
                        }
                        .buttonStyle(.bordered)
                        .tint(Color(red: 0.7, green: 0.5, blue: 1.0))
                    }
                }
                .font(.title2)
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
