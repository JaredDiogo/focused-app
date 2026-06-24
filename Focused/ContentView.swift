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

    // Subject list — starts with 4 premade options, grows if the user adds more
    @State private var subjects = ["Math", "History", "Science", "English"]

    // The subject the user tapped
    @State private var selectedSubject: String? = nil

    // Whether the new-subject text field is visible
    @State private var showingNewSubject = false

    // Text typed into the new subject field
    @State private var newSubjectName = ""

    // Fires every second on the main thread
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Shared spring used across all transitions
    let spring = Animation.spring(response: 0.5, dampingFraction: 0.8)

    // 1.0 when full, shrinks toward 0.0 as time runs out
    var progress: Double {
        Double(secondsRemaining) / Double(totalSeconds)
    }

    // Converts raw seconds into a MM:SS string
    var timeString: String {
        String(format: "%02d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }

    // Start is only allowed once a subject is selected
    var canStart: Bool { selectedSubject != nil }

    var body: some View {
        ZStack {
            // Dark purple background filling the whole screen
            Color(red: 0.1, green: 0.05, blue: 0.2)
                .ignoresSafeArea()

            if isSelecting {
                // ── SELECTION SCREEN ──────────────────────────
                ScrollView {
                    VStack(spacing: 32) {
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

                        // Subject selection section
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Subject")
                                .font(.system(size: 14, weight: .light, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                                .padding(.horizontal, 4)

                            // 2-column grid of subject chips
                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible())],
                                spacing: 10
                            ) {
                                ForEach(subjects, id: \.self) { subject in
                                    // Tapping a selected chip deselects it; tapping a new one selects it
                                    Button(action: {
                                        withAnimation(spring) {
                                            selectedSubject = selectedSubject == subject ? nil : subject
                                        }
                                    }) {
                                        Text(subject)
                                            .font(.system(size: 15, weight: .light, design: .rounded))
                                            .foregroundStyle(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                selectedSubject == subject
                                                    ? Color(red: 0.5, green: 0.3, blue: 0.9)
                                                    : Color.white.opacity(0.1)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }

                            // Button to show the new subject text field
                            Button(action: {
                                withAnimation(spring) { showingNewSubject.toggle() }
                            }) {
                                Label(
                                    showingNewSubject ? "Cancel" : "New Subject",
                                    systemImage: showingNewSubject ? "xmark" : "plus"
                                )
                                .font(.system(size: 15, weight: .light, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            // Text field that slides in when adding a new subject
                            if showingNewSubject {
                                HStack(spacing: 10) {
                                    TextField("Subject name", text: $newSubjectName)
                                        .font(.system(size: 15, weight: .light, design: .rounded))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .autocorrectionDisabled()

                                    // Adds the new subject to the list and selects it
                                    Button("Add") {
                                        let name = newSubjectName.trimmingCharacters(in: .whitespaces)
                                        guard !name.isEmpty else { return }
                                        withAnimation(spring) {
                                            subjects.append(name)
                                            selectedSubject = name
                                            newSubjectName = ""
                                            showingNewSubject = false
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Color(red: 0.5, green: 0.3, blue: 0.9))
                                    .font(.system(size: 15, weight: .light, design: .rounded))
                                    .disabled(newSubjectName.trimmingCharacters(in: .whitespaces).isEmpty)
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(.horizontal, 4)

                        // Locks in the chosen duration and subject and starts the timer
                        Button("Start") {
                            totalSeconds = selectedMinutes * 60
                            secondsRemaining = selectedMinutes * 60
                            isRunning = true
                            withAnimation(spring) { isSelecting = false }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0.5, green: 0.3, blue: 0.9))
                        .font(.system(size: 20, weight: .light, design: .rounded))
                        .disabled(!canStart)
                        .opacity(canStart ? 1 : 0.4)
                    }
                    .padding(28)
                }
                // Slide in from the left, slide out to the left
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))

            } else {
                // ── TIMER SCREEN ──────────────────────────────
                VStack(spacing: 40) {
                    // Subject shown as a frosted pill above the ring
                    if let subject = selectedSubject {
                        Text(subject.uppercased())
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.75))
                            .tracking(2)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 7)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Capsule())
                    }

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
                                withAnimation(spring) { isRunning = false }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(red: 0.5, green: 0.3, blue: 0.9))
                            .transition(.opacity.combined(with: .scale(scale: 0.85)))
                        } else {
                            // Timer is paused — show resume on the left
                            Button("Resume") {
                                withAnimation(spring) { isRunning = true }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(red: 0.5, green: 0.3, blue: 0.9))
                            .transition(.opacity.combined(with: .scale(scale: 0.85)))

                            // Cancel stops the timer and returns to time selection
                            Button("Cancel") {
                                isRunning = false
                                withAnimation(spring) { isSelecting = true }
                            }
                            .buttonStyle(.bordered)
                            .tint(Color(red: 0.7, green: 0.5, blue: 1.0))
                            .transition(.opacity.combined(with: .scale(scale: 0.85)))
                        }
                    }
                    .font(.title2)
                    // Animate the button swap when isRunning changes
                    .animation(spring, value: isRunning)
                }
                // Slide in from the right, slide out to the right
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .trailing).combined(with: .opacity)
                ))
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
