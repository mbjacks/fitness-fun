//
//  PersonalFitnessTrackerApp.swift
//  PersonalFitnessTracker
//
//  Created by Matthew Jackson on 11/14/25.
//

import SwiftUI

@main
struct PersonalFitnessTrackerApp: App {
    // MARK: - Dependencies
    
    private let profileRepository: UserProfileRepository
    private let planRepository: ExercisePlanRepository
    private let bmrCalculatorService: BMRCalculatorService
    private let planParserService: PlanParserService
    private let workoutTimerService: WorkoutTimerService
    private let audioNotificationService: AudioNotificationService
    private let prebuiltPlansService: PrebuiltPlansService
    
    // MARK: - Initialization
    
    init() {
        // Initialize repositories
        self.profileRepository = UserDefaultsProfileRepository()
        
        do {
            self.planRepository = try FileManagerPlanRepository()
        } catch {
            fatalError("Failed to initialize plan repository: \(error)")
        }
        
        // Initialize services
        self.bmrCalculatorService = BMRCalculatorService()
        self.planParserService = PlanParserService()
        self.workoutTimerService = WorkoutTimerService()
        self.audioNotificationService = AudioNotificationService()
        self.prebuiltPlansService = PrebuiltPlansService(
            planParser: planParserService,
            planRepository: planRepository
        )
        
        // Load pre-built workout plans on first launch
        loadPrebuiltPlansIfNeeded()
    }
    
    // MARK: - Private Methods
    
    private func loadPrebuiltPlansIfNeeded() {
        let hasLoadedPrebuiltPlans = UserDefaults.standard.bool(forKey: "hasLoadedPrebuiltPlans")
        
        print("🚀 App initialization - hasLoadedPrebuiltPlans: \(hasLoadedPrebuiltPlans)")
        
        if !hasLoadedPrebuiltPlans {
            print("📥 Loading pre-built plans for the first time...")
            prebuiltPlansService.loadPrebuiltPlans()
            UserDefaults.standard.set(true, forKey: "hasLoadedPrebuiltPlans")
            print("✅ Pre-built plans loading complete")
        } else {
            print("⏭️ Pre-built plans already loaded, skipping")
        }
    }
    
    // MARK: - Scene
    
    var body: some Scene {
        WindowGroup {
            MainTabView(
                profileRepository: profileRepository,
                planRepository: planRepository,
                bmrCalculatorService: bmrCalculatorService,
                planParserService: planParserService,
                workoutTimerService: workoutTimerService,
                audioNotificationService: audioNotificationService
            )
        }
    }
}
