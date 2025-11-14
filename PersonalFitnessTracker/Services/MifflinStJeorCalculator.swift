//
//  MifflinStJeorCalculator.swift
//  PersonalFitnessTracker
//

import Foundation

class MifflinStJeorCalculator: BMRCalculator {
    func calculate(profile: UserProfile) -> Double {
        let weight = profile.weight.kilograms
        let height = profile.height.centimeters
        let age = Double(profile.age)
        
        switch profile.sex {
        case .male:
            // Male formula: 10 * weight + 6.25 * height - 5 * age + 5
            return 10 * weight + 6.25 * height - 5 * age + 5
        case .female:
            // Female formula: 10 * weight + 6.25 * height - 5 * age - 161
            return 10 * weight + 6.25 * height - 5 * age - 161
        }
    }
}
