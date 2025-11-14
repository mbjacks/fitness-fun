//
//  BMRViewModel.swift
//  PersonalFitnessTracker
//

import Foundation
import Combine

class BMRViewModel: ObservableObject {
    @Published var bmrValue: Int = 0
    @Published var selectedFormula: BMRFormula = .mifflinStJeor
    
    private let calculatorService: BMRCalculatorService
    private let profileRepository: UserProfileRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(calculatorService: BMRCalculatorService = BMRCalculatorService(),
         profileRepository: UserProfileRepository = UserDefaultsProfileRepository()) {
        self.calculatorService = calculatorService
        self.profileRepository = profileRepository
        
        // Load the user's preferred formula from their profile
        if let profile = profileRepository.load() {
            self.selectedFormula = profile.bmrFormula
        }
        
        // Calculate BMR on initialization
        calculateBMR()
        
        // Set up subscription to recalculate when formula changes
        $selectedFormula
            .sink { [weak self] _ in
                self?.calculateBMR()
            }
            .store(in: &cancellables)
    }
    
    func calculateBMR() {
        guard let profile = profileRepository.load() else {
            bmrValue = 0
            return
        }
        
        let calculator = calculatorService.getCalculator(for: selectedFormula)
        let rawBMR = calculator.calculate(profile: profile)
        
        // Round to zero decimal places
        bmrValue = Int(round(rawBMR))
    }
    
    func updateFormula(_ formula: BMRFormula) {
        selectedFormula = formula
        
        // Update the formula in the user's profile
        if var profile = profileRepository.load() {
            profile.bmrFormula = formula
            try? profileRepository.save(profile: profile)
        }
    }
}
