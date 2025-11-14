//
//  PrebuiltPlansService.swift
//  PersonalFitnessTracker
//

import Foundation

class PrebuiltPlansService {
    private let planParser: PlanParserService
    private let planRepository: ExercisePlanRepository
    
    init(planParser: PlanParserService, planRepository: ExercisePlanRepository) {
        self.planParser = planParser
        self.planRepository = planRepository
    }
    
    /// Loads all pre-built workout plans from the Resources/WorkoutPlans directory
    /// and imports them into the repository if they don't already exist
    func loadPrebuiltPlans() {
        print("🔍 Starting to load pre-built plans...")
        
        // Try to find the WorkoutPlans directory in the bundle
        guard let resourceURL = Bundle.main.url(forResource: "WorkoutPlans", withExtension: nil) else {
            print("⚠️ WorkoutPlans directory not found in bundle")
            print("📦 Attempting to load individual JSON files...")
            loadIndividualJSONFiles()
            return
        }
        
        print("✅ Found WorkoutPlans directory at: \(resourceURL.path)")
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: resourceURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            
            print("📁 Found \(fileURLs.count) files in WorkoutPlans directory")
            
            let jsonFiles = fileURLs.filter { $0.pathExtension == "json" }
            print("📄 Found \(jsonFiles.count) JSON files")
            
            for fileURL in jsonFiles {
                print("🔄 Processing: \(fileURL.lastPathComponent)")
                do {
                    let plan = try planParser.parse(fileURL: fileURL)
                    
                    // Only import if a plan with this name doesn't already exist
                    if !planRepository.exists(name: plan.name) {
                        try planRepository.save(plan: plan)
                        print("✅ Imported pre-built plan: \(plan.name)")
                    } else {
                        print("⏭️ Plan '\(plan.name)' already exists, skipping")
                    }
                } catch {
                    print("❌ Failed to import plan from \(fileURL.lastPathComponent): \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Failed to read WorkoutPlans directory: \(error.localizedDescription)")
        }
    }
    
    /// Fallback method to load individual JSON files if directory reference doesn't work
    private func loadIndividualJSONFiles() {
        let jsonFileNames = [
            "40min_incline_walk_exercise_example"
        ]
        
        for fileName in jsonFileNames {
            print("🔍 Looking for: \(fileName).json")
            
            guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                print("⚠️ File not found in bundle: \(fileName).json")
                continue
            }
            
            print("✅ Found file at: \(fileURL.path)")
            
            do {
                let plan = try planParser.parse(fileURL: fileURL)
                
                if !planRepository.exists(name: plan.name) {
                    try planRepository.save(plan: plan)
                    print("✅ Imported pre-built plan: \(plan.name)")
                } else {
                    print("⏭️ Plan '\(plan.name)' already exists, skipping")
                }
            } catch {
                print("❌ Failed to import plan from \(fileName).json: \(error.localizedDescription)")
            }
        }
    }
}
