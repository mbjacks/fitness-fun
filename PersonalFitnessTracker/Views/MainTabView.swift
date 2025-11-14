//
//  MainTabView.swift
//  PersonalFitnessTracker
//

import SwiftUI

struct MainTabView: View {
    // MARK: - Dependencies
    
    private let profileRepository: UserProfileRepository
    private let planRepository: ExercisePlanRepository
    private let bmrCalculatorService: BMRCalculatorService
    private let planParserService: PlanParserService
    private let workoutTimerService: WorkoutTimerService
    private let audioNotificationService: AudioNotificationService
    
    // MARK: - State
    
    @State private var selectedTab = 0
    @StateObject private var planListViewModel: PlanListViewModel
    
    // MARK: - Initialization
    
    init(
        profileRepository: UserProfileRepository,
        planRepository: ExercisePlanRepository,
        bmrCalculatorService: BMRCalculatorService,
        planParserService: PlanParserService,
        workoutTimerService: WorkoutTimerService,
        audioNotificationService: AudioNotificationService
    ) {
        self.profileRepository = profileRepository
        self.planRepository = planRepository
        self.bmrCalculatorService = bmrCalculatorService
        self.planParserService = planParserService
        self.workoutTimerService = workoutTimerService
        self.audioNotificationService = audioNotificationService
        
        // Initialize PlanListViewModel as StateObject
        _planListViewModel = StateObject(wrappedValue: PlanListViewModel(
            repository: planRepository,
            parser: planParserService
        ))
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Plans Tab
            PlanListView(viewModel: planListViewModel)
                .tabItem {
                    Label("Plans", systemImage: "list.bullet.clipboard")
                }
                .tag(0)
            
            // BMR Tab
            BMRView()
                .tabItem {
                    Label("BMR", systemImage: "flame.fill")
                }
                .tag(1)
            
            // Profile Tab
            ProfileView(viewModel: ProfileViewModel(repository: profileRepository))
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
    }
}

// MARK: - Preview

#Preview {
    let profileRepo = UserDefaultsProfileRepository()
    let planRepo = try! FileManagerPlanRepository()
    let bmrService = BMRCalculatorService()
    let parserService = PlanParserService()
    let timerService = WorkoutTimerService()
    let audioService = AudioNotificationService()
    
    return MainTabView(
        profileRepository: profileRepo,
        planRepository: planRepo,
        bmrCalculatorService: bmrService,
        planParserService: parserService,
        workoutTimerService: timerService,
        audioNotificationService: audioService
    )
}
