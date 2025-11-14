//
//  KatchMcArdleCalculator.swift
//  PersonalFitnessTracker
//

import Foundation

class KatchMcArdleCalculator: BMRCalculator {
    func calculate(profile: UserProfile) -> Double {
        let weight = profile.weight.kilograms
        
        // Estimate lean body mass based on sex
        let leanBodyMass: Double
        switch profile.sex {
        case .male:
            // Estimate lean body mass: 0.9 * weight for male
            leanBodyMass = 0.9 * weight
        case .female:
            // Estimate lean body mass: 0.85 * weight for female
            leanBodyMass = 0.85 * weight
        }
        
        // Formula: 370 + 21.6 * lean body mass
        return 370 + 21.6 * leanBodyMass
    }
}
