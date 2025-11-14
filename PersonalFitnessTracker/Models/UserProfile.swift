//
//  UserProfile.swift
//  PersonalFitnessTracker
//

import Foundation

struct UserProfile: Codable {
    var age: Int
    var sex: Sex
    var height: Height
    var weight: Weight
    var restingHeartRate: Int?
    var desiredExerciseTime: Int?
    var exerciseGoals: String?
    var unitSystem: UnitSystem
    var bmrFormula: BMRFormula
    var speedUnit: SpeedUnit = .milesPerHour
}
