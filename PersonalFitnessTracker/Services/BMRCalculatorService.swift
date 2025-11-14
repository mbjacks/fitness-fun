//
//  BMRCalculatorService.swift
//  PersonalFitnessTracker
//

import Foundation

class BMRCalculatorService {
    func getCalculator(for formula: BMRFormula) -> BMRCalculator {
        switch formula {
        case .mifflinStJeor:
            return MifflinStJeorCalculator()
        case .harrisBenedict:
            return HarrisBenedictCalculator()
        case .katchMcArdle:
            return KatchMcArdleCalculator()
        }
    }
}
