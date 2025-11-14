//
//  WorkoutViewModel.swift
//  PersonalFitnessTracker
//

import Foundation
import Combine

class WorkoutViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var session: WorkoutSession
    @Published var timeRemaining: TimeInterval
    @Published var nextInterval: WorkoutInterval?
    @Published var errorMessage: String?
    @Published var speedUnit: SpeedUnit
    
    // MARK: - Private Properties
    
    private let timerService: WorkoutTimerService
    var audioService: AudioNotificationService
    private let profileRepository: UserProfileRepository
    private var cancellables = Set<AnyCancellable>()
    private var hasPlayedWarning = false
    private var lastIntervalTimestamp: TimeInterval = 0
    
    // MARK: - Initialization
    
    init(plan: ExercisePlan, timerService: WorkoutTimerService, audioService: AudioNotificationService, profileRepository: UserProfileRepository) {
        self.session = WorkoutSession(plan: plan)
        self.timeRemaining = plan.totalDuration
        self.timerService = timerService
        self.audioService = audioService
        self.profileRepository = profileRepository
        
        // Load speed unit preference from profile
        if let profile = profileRepository.load() {
            self.speedUnit = profile.speedUnit
        } else {
            self.speedUnit = .milesPerHour
        }
        
        setupTimerSubscription()
    }
    
    // MARK: - Workout Control Methods
    
    func startWorkout() {
        // Clear any previous errors
        errorMessage = nil
        
        // Validate that the plan has intervals
        guard !session.plan.intervals.isEmpty else {
            let error = AppError.invalidPlanData
            errorMessage = error.errorDescription
            return
        }
        
        session.isActive = true
        session.isPaused = false
        session.isCompleted = false
        timerService.start()
        
        // Initialize current interval
        if let firstInterval = session.plan.intervals.first {
            session.currentInterval = firstInterval
            lastIntervalTimestamp = firstInterval.timestamp
        }
    }
    
    func pauseWorkout() {
        guard session.isActive else {
            let error = AppError.workoutNotStarted
            errorMessage = error.errorDescription
            return
        }
        
        guard !session.isPaused else { return }
        
        session.isPaused = true
        timerService.pause()
    }
    
    func resumeWorkout() {
        guard session.isActive else {
            let error = AppError.workoutNotStarted
            errorMessage = error.errorDescription
            return
        }
        
        guard session.isPaused else { return }
        
        session.isPaused = false
        timerService.resume()
    }
    
    func stopWorkout() {
        session.isActive = false
        session.isPaused = false
        timerService.stop()
    }
    
    // MARK: - Speed Unit Methods
    
    func toggleSpeedUnit() {
        // Toggle the speed unit
        speedUnit = speedUnit == .milesPerHour ? .kilometersPerHour : .milesPerHour
        
        // Update and persist the preference
        if var profile = profileRepository.load() {
            profile.speedUnit = speedUnit
            try? profileRepository.save(profile: profile)
        }
        
        // Update audio service with new speed unit
        audioService.speedUnit = speedUnit
    }
    
    func displaySpeed(for interval: WorkoutInterval) -> Double {
        switch speedUnit {
        case .milesPerHour:
            return interval.speedInMPH()
        case .kilometersPerHour:
            return interval.speedInKPH()
        }
    }
    
    // MARK: - Private Setup Methods
    
    private func setupTimerSubscription() {
        // Subscribe to timer updates
        timerService.$elapsedTime
            .sink { [weak self] elapsedTime in
                guard let self = self else { return }
                
                // Update session elapsed time
                self.session.elapsedTime = elapsedTime
                
                // Update time remaining
                self.timeRemaining = max(0, self.session.plan.totalDuration - elapsedTime)
                
                // Check for interval changes
                self.handleIntervalChange()
                
                // Check for upcoming intervals
                self.handleUpcomingInterval()
                
                // Check for workout completion
                if elapsedTime >= self.session.plan.totalDuration && self.session.isActive {
                    self.completeWorkout()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Interval Monitoring Methods
    
    private func handleIntervalChange() {
        guard let currentInterval = timerService.getCurrentInterval(for: session.plan) else { return }
        
        // Check if we've moved to a new interval
        if currentInterval.timestamp != lastIntervalTimestamp {
            // Update the current interval
            session.currentInterval = currentInterval
            lastIntervalTimestamp = currentInterval.timestamp
            
            // Play change notification
            audioService.playChangeNotification(for: currentInterval)
            
            // Reset warning flag for the next interval
            hasPlayedWarning = false
        }
    }
    
    private func handleUpcomingInterval() {
        // Check for upcoming interval within 5 seconds
        if let upcomingInterval = timerService.getUpcomingInterval(for: session.plan, within: 5.0) {
            nextInterval = upcomingInterval
            
            // Play warning notification if we haven't already
            if !hasPlayedWarning {
                audioService.playWarningNotification(for: upcomingInterval)
                hasPlayedWarning = true
            }
        } else {
            nextInterval = nil
        }
    }
    
    private func completeWorkout() {
        session.isCompleted = true
        session.isActive = false
        timerService.stop()
        audioService.playCompletionNotification()
    }
}
