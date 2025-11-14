//
//  WorkoutSession.swift
//  PersonalFitnessTracker
//

import Foundation
import Combine

class WorkoutSession: ObservableObject {
    let plan: ExercisePlan
    @Published var elapsedTime: TimeInterval
    @Published var currentInterval: WorkoutInterval
    @Published var isActive: Bool
    @Published var isPaused: Bool
    @Published var isCompleted: Bool
    
    init(plan: ExercisePlan) {
        self.plan = plan
        self.elapsedTime = 0
        self.currentInterval = plan.intervals.first ?? WorkoutInterval(timestamp: 0, speed: 0, incline: 0)
        self.isActive = false
        self.isPaused = false
        self.isCompleted = false
    }
}
