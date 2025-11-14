//
//  ExercisePlan.swift
//  PersonalFitnessTracker
//

import Foundation

struct ExercisePlan: Codable, Identifiable {
    let id: UUID
    var name: String
    var totalDuration: TimeInterval
    var intervals: [WorkoutInterval]
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, totalDuration: TimeInterval, intervals: [WorkoutInterval], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.totalDuration = totalDuration
        self.intervals = intervals
        self.createdAt = createdAt
    }
}
