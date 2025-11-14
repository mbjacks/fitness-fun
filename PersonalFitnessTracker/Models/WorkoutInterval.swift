//
//  WorkoutInterval.swift
//  PersonalFitnessTracker
//

import Foundation

struct WorkoutInterval: Codable, Equatable {
    var timestamp: TimeInterval
    var speed: Double // stored in km/h
    var incline: Double // percentage
    
    func speedInMPH() -> Double {
        return speed * 0.621371
    }
    
    func speedInKPH() -> Double {
        return speed
    }
}
