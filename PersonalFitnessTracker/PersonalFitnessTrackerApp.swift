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
