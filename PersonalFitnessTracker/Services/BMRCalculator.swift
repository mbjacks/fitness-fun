//
//  BMRCalculator.swift
//  PersonalFitnessTracker
//

import Foundation

protocol BMRCalculator {
    func calculate(profile: UserProfile) -> Double
}
