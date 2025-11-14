//
//  WorkoutTimerService.swift
//  PersonalFitnessTracker
//

import Foundation
import Combine
import UIKit

class WorkoutTimerService: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    
    private var timer: AnyCancellable?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    private var backgroundTime: Date?
    
    init() {
        setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Timer Control Methods
    
    func start() {
        startTime = Date()
        pausedTime = 0
        elapsedTime = 0
        resumeTimer()
    }
    
    func pause() {
        timer?.cancel()
        timer = nil
        pausedTime = elapsedTime
    }
    
    func resume() {
        if pausedTime > 0 {
            startTime = Date().addingTimeInterval(-pausedTime)
        }
        resumeTimer()
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
        startTime = nil
        pausedTime = 0
        elapsedTime = 0
    }
    
    // MARK: - Interval Detection Methods
    
    func getCurrentInterval(for plan: ExercisePlan) -> WorkoutInterval? {
        guard !plan.intervals.isEmpty else { return nil }
        
        // Find the interval that applies to the current elapsed time
        // Intervals are sorted by timestamp, so we find the last interval
        // whose timestamp is less than or equal to the current elapsed time
        var currentInterval: WorkoutInterval?
        
        for interval in plan.intervals {
            if interval.timestamp <= elapsedTime {
                currentInterval = interval
            } else {
                break
            }
        }
        
        return currentInterval ?? plan.intervals.first
    }
    
    func getUpcomingInterval(for plan: ExercisePlan, within seconds: TimeInterval) -> WorkoutInterval? {
        let targetTime = elapsedTime + seconds
        
        // Find the next interval that will occur within the specified time window
        for interval in plan.intervals {
            if interval.timestamp > elapsedTime && interval.timestamp <= targetTime {
                return interval
            }
        }
        
        return nil
    }
    
    // MARK: - Private Methods
    
    private func resumeTimer() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let startTime = self.startTime else { return }
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
    }
    
    // MARK: - Background/Foreground Handling
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        // Record the time when app goes to background
        if timer != nil {
            backgroundTime = Date()
        }
    }
    
    @objc private func appWillEnterForeground() {
        // Adjust elapsed time based on time spent in background
        if let backgroundTime = backgroundTime, let startTime = startTime, timer != nil {
            let timeInBackground = Date().timeIntervalSince(backgroundTime)
            self.startTime = startTime.addingTimeInterval(-timeInBackground)
            self.backgroundTime = nil
        }
    }
}
