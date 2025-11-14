//
//  HarrisBenedictCalculator.swift
//  PersonalFitnessTracker
//

import Foundation

class HarrisBenedictCalculator: BMRCalculator {
    func calculate(profile: UserProfile) -> Double {
        let weight = profile.weight.kilograms
        let height = profile.height.centimeters
        let age = Double(profile.age)
        
        switch profile.sex {
        case .male:
            // Male formula: 88.362 + 13.397 * weight + 4.799 * height - 5.677 * age
            return 88.362 + 13.397 * weight + 4.799 * height - 5.677 * age
        case .female:
            // Female formula: 447.593 + 9.247 * weight + 3.098 * height - 4.330 * age
            return 447.593 + 9.247 * weight + 3.098 * height - 4.330 * age
        }
    }
}
