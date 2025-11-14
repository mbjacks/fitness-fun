//
//  ProfileViewModel.swift
//  PersonalFitnessTracker
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile
    @Published var validationErrors: [String: String] = [:]
    
    private let repository: UserProfileRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: UserProfileRepository = UserDefaultsProfileRepository()) {
        self.repository = repository
        
        // Load existing profile or create default
        if let existingProfile = repository.load() {
            self.profile = existingProfile
        } else {
            // Create default profile
            self.profile = UserProfile(
                age: 30,
                sex: .male,
                height: Height(centimeters: 170),
                weight: Weight(kilograms: 70),
                restingHeartRate: nil,
                desiredExerciseTime: nil,
                exerciseGoals: nil,
                unitSystem: .metric,
                bmrFormula: .mifflinStJeor
            )
        }
    }
    
    func saveProfile() {
        // Clear previous validation errors
        validationErrors.removeAll()
        
        // Validate all fields
        let isAgeValid = validateAge()
        let isHeightValid = validateHeight()
        let isWeightValid = validateWeight()
        
        // Only save if all validations pass
        if isAgeValid && isHeightValid && isWeightValid {
            do {
                try repository.save(profile: profile)
            } catch {
                let appError = AppError.profileSaveFailed(error)
                validationErrors["save"] = appError.errorDescription
            }
        }
    }
    
    func validateAge() -> Bool {
        if profile.age < 10 || profile.age > 120 {
            validationErrors["age"] = AppError.invalidAge.errorDescription
            return false
        }
        validationErrors.removeValue(forKey: "age")
        return true
    }
    
    func validateHeight() -> Bool {
        switch profile.unitSystem {
        case .metric:
            // Validate height in centimeters (50-300 cm)
            if profile.height.centimeters < 50 || profile.height.centimeters > 300 {
                validationErrors["height"] = "Height must be between 50 and 300 centimeters"
                return false
            }
        case .imperial:
            // Validate height in feet and inches (1'8" to 9'10")
            // 1'8" = 50.8 cm, 9'10" = 299.72 cm
            let minHeightCm = 50.8  // 1 foot 8 inches
            let maxHeightCm = 299.72  // 9 feet 10 inches
            
            if profile.height.centimeters < minHeightCm || profile.height.centimeters > maxHeightCm {
                validationErrors["height"] = "Height must be between 1'8\" and 9'10\""
                return false
            }
        }
        validationErrors.removeValue(forKey: "height")
        return true
    }
    
    func validateWeight() -> Bool {
        switch profile.unitSystem {
        case .metric:
            // Validate weight in kilograms (20-500 kg)
            if profile.weight.kilograms < 20 || profile.weight.kilograms > 500 {
                validationErrors["weight"] = "Weight must be between 20 and 500 kilograms"
                return false
            }
        case .imperial:
            // Validate weight in pounds (44-1100 lbs)
            let pounds = profile.weight.inPounds
            if pounds < 44 || pounds > 1100 {
                validationErrors["weight"] = "Weight must be between 44 and 1100 pounds"
                return false
            }
        }
        validationErrors.removeValue(forKey: "weight")
        return true
    }
    
    func toggleUnitSystem() {
        // Store current values
        let currentHeightCm = profile.height.centimeters
        let currentWeightKg = profile.weight.kilograms
        
        // Toggle unit system
        profile.unitSystem = profile.unitSystem == .metric ? .imperial : .metric
        
        // Preserve the actual measurements (they're already stored in base units)
        // Height and Weight structs already handle conversions internally
        profile.height = Height(centimeters: currentHeightCm)
        profile.weight = Weight(kilograms: currentWeightKg)
        
        // Revalidate with new unit system
        validateHeight()
        validateWeight()
    }
}
