//
//  Height.swift
//  PersonalFitnessTracker
//

import Foundation

struct Height: Codable {
    var centimeters: Double
    
    init(centimeters: Double) {
        self.centimeters = centimeters
    }
    
    init(feet: Int, inches: Int) {
        // Convert feet and inches to centimeters
        // 1 foot = 30.48 cm, 1 inch = 2.54 cm
        self.centimeters = Double(feet) * 30.48 + Double(inches) * 2.54
    }
    
    var inFeetAndInches: (feet: Int, inches: Int) {
        // Convert centimeters to feet and inches
        let totalInches = centimeters / 2.54
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return (feet, inches)
    }
}
