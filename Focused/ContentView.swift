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
    // Track how many seconds are left and whether the timer is running
    @State private var secondsRemaining = 25 * 60
    @State private var isRunning = false

    // Fires every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Format seconds into MM:SS
    var timeString: String {
        String(format: "%02d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }

    var body: some View {
        VStack(spacing: 40) {
            // Countdown display
            Text(timeString)
                .font(.system(size: 72, weight: .thin, design: .monospaced))

            HStack(spacing: 24) {
                // Toggles the timer on and off
                Button(isRunning ? "Stop" : "Start") {
                    isRunning.toggle()
                }
                .buttonStyle(.borderedProminent)

                // Stops the timer and resets to 25 minutes
                Button("Reset") {
                    isRunning = false
                    secondsRemaining = 25 * 60
                }
                .buttonStyle(.bordered)
            }
            .font(.title2)
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
