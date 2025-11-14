//
//  PlanDetailView.swift
//  PersonalFitnessTracker
//

import SwiftUI

struct PlanDetailView: View {
    // MARK: - Properties
    
    let plan: ExercisePlan
    
    // MARK: - State
    
    @State private var showingWorkout = false
    @State private var speedUnit: SpeedUnit = .milesPerHour
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Plan header
                VStack(alignment: .leading, spacing: 8) {
                    Text(plan.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label(formatDuration(plan.totalDuration), systemImage: "clock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(plan.intervals.count) intervals")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Intervals list
                VStack(alignment: .leading, spacing: 12) {
                    Text("Intervals")
                        .font(.headline)
                    
                    ForEach(Array(plan.intervals.enumerated()), id: \.offset) { index, interval in
                        IntervalRow(interval: interval, index: index + 1, speedUnit: speedUnit)
                    }
                }
                
                // Start workout button
                Button(action: {
                    showingWorkout = true
                }) {
                    Label("Start Workout", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("Plan Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSpeedUnitPreference()
        }
        .fullScreenCover(isPresented: $showingWorkout) {
            let timerService = WorkoutTimerService()
            let audioService = AudioNotificationService()
            let profileRepository = UserDefaultsProfileRepository()
            let viewModel = WorkoutViewModel(plan: plan, timerService: timerService, audioService: audioService, profileRepository: profileRepository)
            WorkoutView(viewModel: viewModel)
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadSpeedUnitPreference() {
        let profileRepository = UserDefaultsProfileRepository()
        if let profile = profileRepository.load() {
            speedUnit = profile.speedUnit
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        if seconds == 0 {
            return "\(minutes) min"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }
    
    private func formatTime(_ timestamp: TimeInterval) -> String {
        let minutes = Int(timestamp) / 60
        let seconds = Int(timestamp) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

// MARK: - Interval Row

struct IntervalRow: View {
    let interval: WorkoutInterval
    let index: Int
    let speedUnit: SpeedUnit
    
    private var displaySpeed: Double {
        switch speedUnit {
        case .milesPerHour:
            return interval.speedInMPH()
        case .kilometersPerHour:
            return interval.speedInKPH()
        }
    }
    
    private var speedUnitLabel: String {
        speedUnit == .milesPerHour ? "mph" : "km/h"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Interval number
            Text("\(index)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color.accentColor))
            
            // Timestamp
            VStack(alignment: .leading, spacing: 4) {
                Text(formatTime(interval.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Start")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60, alignment: .leading)
            
            // Speed
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "speedometer")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(String(format: "%.1f", displaySpeed))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                Text(speedUnitLabel)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Incline
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f", interval.incline))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                Text("% incline")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func formatTime(_ timestamp: TimeInterval) -> String {
        let minutes = Int(timestamp) / 60
        let seconds = Int(timestamp) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        PlanDetailView(plan: ExercisePlan(
            name: "Beginner Cardio",
            totalDuration: 1800,
            intervals: [
                WorkoutInterval(timestamp: 0, speed: 5.0, incline: 0.0),
                WorkoutInterval(timestamp: 300, speed: 6.5, incline: 2.0),
                WorkoutInterval(timestamp: 600, speed: 7.0, incline: 3.0),
                WorkoutInterval(timestamp: 900, speed: 6.0, incline: 1.5),
                WorkoutInterval(timestamp: 1200, speed: 5.0, incline: 0.0)
            ]
        ))
    }
}
