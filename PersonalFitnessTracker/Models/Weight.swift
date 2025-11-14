//
//  Weight.swift
//  PersonalFitnessTracker
//

import Foundation

struct Weight: Codable {
    var kilograms: Double
    
    init(kilograms: Double) {
        self.kilograms = kilograms
    }
    
    init(pounds: Double) {
        // Convert pounds to kilograms
        // 1 pound = 0.453592 kg
        self.kilograms = pounds * 0.453592
    }
    
    var inPounds: Double {
        // Convert kilograms to pounds
        return kilograms / 0.453592
    }
}
