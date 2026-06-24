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
    @State private var secondsRemaining = 25 * 60
    @State private var isRunning = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var timeString: String {
        String(format: "%02d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }

    var body: some View {
        VStack(spacing: 40) {
            Text(timeString)
                .font(.system(size: 72, weight: .thin, design: .monospaced))

            HStack(spacing: 24) {
                Button(isRunning ? "Stop" : "Start") {
                    isRunning.toggle()
                }
                .buttonStyle(.borderedProminent)

                Button("Reset") {
                    isRunning = false
                    secondsRemaining = 25 * 60
                }
                .buttonStyle(.bordered)
            }
            .font(.title2)
        }
        .onReceive(timer) { _ in
            guard isRunning, secondsRemaining > 0 else {
                if secondsRemaining == 0 { isRunning = false }
                return
            }
            secondsRemaining -= 1
        }
    }
}
