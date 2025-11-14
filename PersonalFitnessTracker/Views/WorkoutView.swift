//
//  WorkoutView.swift
//  PersonalFitnessTracker
//

import SwiftUI

struct WorkoutView: View {
    // MARK: - Properties
    
    @StateObject var viewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var showingStopConfirmation = false
    @State private var showingSettings = false
    @State private var showIntervalChangeBanner = false
    @State private var showingErrorAlert = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            mainContent
                .navigationTitle("Workout")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    settingsSheet
                }
                .alert("Stop Workout?", isPresented: $showingStopConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Stop", role: .destructive) {
                        viewModel.stopWorkout()
                        dismiss()
                    }
                } message: {
                    Text("Are you sure you want to stop this workout? Your progress will not be saved.")
                }
                .alert("Workout Error", isPresented: $showingErrorAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(viewModel.errorMessage ?? "An unknown error occurred.")
                }
                .onChange(of: viewModel.errorMessage) {
                    if viewModel.errorMessage != nil {
                        showingErrorAlert = true
                    }
                }
                .onAppear {
                    if !viewModel.session.isActive {
                        viewModel.startWorkout()
                    }
                }
                .onChange(of: viewModel.session.currentInterval) {
                    handleIntervalChange()
                }
                .onChange(of: viewModel.session.isCompleted) {
                    handleWorkoutCompletion()
                }
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        ZStack {
            workoutContent
            
            if showIntervalChangeBanner {
                intervalChangeBanner
            }
        }
    }
    
    private var workoutContent: some View {
        VStack(spacing: 0) {
            progressBar
            
            ScrollView {
                VStack(spacing: 24) {
                    timerSection
                    currentIntervalSection
                    
                    if viewModel.nextInterval != nil {
                        upcomingIntervalSection
                    }
                    
                    controlButtons
                }
                .padding()
            }
        }
    }
    
    private func handleIntervalChange() {
        if viewModel.session.isActive {
            showIntervalChangeBanner = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showIntervalChangeBanner = false
            }
        }
    }
    
    private func handleWorkoutCompletion() {
        if viewModel.session.isCompleted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: geometry.size.width * progress, height: 8)
                    .animation(.linear(duration: 0.1), value: progress)
            }
        }
        .frame(height: 8)
    }
    
    private var progress: CGFloat {
        guard viewModel.session.plan.totalDuration > 0 else { return 0 }
        return CGFloat(viewModel.session.elapsedTime / viewModel.session.plan.totalDuration)
    }
    
    // MARK: - Timer Section
    
    private var timerSection: some View {
        VStack(spacing: 16) {
            // Elapsed time
            VStack(spacing: 4) {
                Text("Elapsed Time")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(formatTime(viewModel.session.elapsedTime))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            
            // Time remaining
            VStack(spacing: 4) {
                Text("Time Remaining")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(formatTime(viewModel.timeRemaining))
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.orange)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - Current Interval Section
    
    private var currentIntervalSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Current Settings")
                    .font(.headline)
                
                Spacer()
                
                // Speed unit toggle
                Button(action: {
                    viewModel.toggleSpeedUnit()
                }) {
                    Text(viewModel.speedUnit == .milesPerHour ? "MPH" : "KPH")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
            
            HStack(spacing: 20) {
                // Speed
                VStack(spacing: 12) {
                    Image(systemName: "speedometer")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                    
                    Text(String(format: "%.1f", viewModel.displaySpeed(for: viewModel.session.currentInterval)))
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    Text(viewModel.speedUnit == .milesPerHour ? "mph" : "km/h")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(16)
                
                // Incline
                VStack(spacing: 12) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 32))
                        .foregroundColor(.orange)
                    
                    Text(String(format: "%.1f", viewModel.session.currentInterval.incline))
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    Text("% incline")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(16)
            }
        }
    }
    
    // MARK: - Upcoming Interval Section
    
    private var upcomingIntervalSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.yellow)
                Text("Upcoming Change")
                    .font(.headline)
                Spacer()
            }
            
            if let nextInterval = viewModel.nextInterval {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Speed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            Image(systemName: "speedometer")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(String(format: "%.1f \(viewModel.speedUnit == .milesPerHour ? "mph" : "km/h")", viewModel.displaySpeed(for: nextInterval)))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Incline")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text(String(format: "%.1f%%", nextInterval.incline))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.15))
        .cornerRadius(12)
    }
    
    // MARK: - Control Buttons
    
    private var controlButtons: some View {
        VStack(spacing: 16) {
            // Pause/Resume button
            if viewModel.session.isActive && !viewModel.session.isCompleted {
                Button(action: {
                    if viewModel.session.isPaused {
                        viewModel.resumeWorkout()
                    } else {
                        viewModel.pauseWorkout()
                    }
                }) {
                    Label(
                        viewModel.session.isPaused ? "Resume" : "Pause",
                        systemImage: viewModel.session.isPaused ? "play.fill" : "pause.fill"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.session.isPaused ? Color.green : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            
            // Stop button
            if !viewModel.session.isCompleted {
                Button(action: {
                    showingStopConfirmation = true
                }) {
                    Label("Stop Workout", systemImage: "stop.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            
            // Completion message
            if viewModel.session.isCompleted {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.green)
                    
                    Text("Workout Complete!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Great job!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
    }
    
    // MARK: - Interval Change Banner
    
    private var intervalChangeBanner: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.title2)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Interval Changed")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "speedometer")
                                .font(.caption)
                            Text(String(format: "%.1f \(viewModel.speedUnit == .milesPerHour ? "mph" : "km/h")", viewModel.displaySpeed(for: viewModel.session.currentInterval)))
                                .font(.subheadline)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                            Text(String(format: "%.1f%%", viewModel.session.currentInterval.incline))
                                .font(.subheadline)
                        }
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
            }
            .padding()
            .background(Color.accentColor)
            .cornerRadius(12)
            .shadow(radius: 8)
            .padding()
            
            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showIntervalChangeBanner)
    }
    
    // MARK: - Settings Sheet
    
    private var settingsSheet: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Notification Sound", selection: $viewModel.audioService.notificationSound) {
                        Text("Beep").tag(NotificationSound.beep)
                        Text("Voice").tag(NotificationSound.voice)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Audio Notifications")
                } footer: {
                    Text("Choose between a simple beep or voice announcements for interval changes.")
                }
            }
            .navigationTitle("Workout Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingSettings = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview {
    let plan = ExercisePlan(
        name: "Test Workout",
        totalDuration: 1800,
        intervals: [
            WorkoutInterval(timestamp: 0, speed: 5.0, incline: 0.0),
            WorkoutInterval(timestamp: 300, speed: 6.5, incline: 2.0),
            WorkoutInterval(timestamp: 600, speed: 7.0, incline: 3.0)
        ]
    )
    
    let timerService = WorkoutTimerService()
    let audioService = AudioNotificationService()
    let profileRepository = UserDefaultsProfileRepository()
    let viewModel = WorkoutViewModel(plan: plan, timerService: timerService, audioService: audioService, profileRepository: profileRepository)
    
    return WorkoutView(viewModel: viewModel)
}
