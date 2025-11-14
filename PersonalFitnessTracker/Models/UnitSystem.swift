//
//  UnitSystem.swift
//  PersonalFitnessTracker
//

import Foundation

enum UnitSystem: String, Codable {
    case metric
    case imperial
}

enum SpeedUnit: String, Codable {
    case milesPerHour
    case kilometersPerHour
}
