//
//  PlanListViewModel.swift
//  PersonalFitnessTracker
//

import Foundation
import Combine

class PlanListViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var plans: [ExercisePlan] = []
    @Published var importError: String?
    @Published var showingImportSheet: Bool = false
    
    // MARK: - Dependencies
    
    private let repository: ExercisePlanRepository
    private let parser: PlanParserService
    
    // MARK: - Initialization
    
    init(repository: ExercisePlanRepository, parser: PlanParserService = PlanParserService()) {
        self.repository = repository
        self.parser = parser
        loadPlans()
    }
    
    // MARK: - Plan Management Methods
    
    /// Load all exercise plans from the repository
    func loadPlans() {
        plans = repository.loadAll()
            .sorted { $0.createdAt > $1.createdAt } // Sort by most recent first
    }
    
    /// Import an exercise plan from a file URL
    func importFromFile(url: URL) {
        do {
            let plan = try parser.parse(fileURL: url)
            try importPlan(plan)
        } catch let error as PlanParserError {
            importError = error.localizedDescription
        } catch {
            let appError = AppError.fileAccessDenied
            importError = appError.errorDescription
        }
    }
    
    /// Import an exercise plan from a JSON string
    func importFromJSON(string: String) {
        do {
            let plan = try parser.parse(jsonString: string)
            try importPlan(plan)
        } catch let error as PlanParserError {
            importError = error.localizedDescription
        } catch {
            let appError = AppError.jsonParsingFailed
            importError = appError.errorDescription
        }
    }
    
    /// Delete an exercise plan by ID
    func deletePlan(id: UUID) {
        do {
            try repository.delete(id: id)
            loadPlans() // Reload plans after deletion
        } catch {
            let appError = AppError.planDeleteFailed(error)
            importError = appError.errorDescription
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Import a plan after checking for duplicates
    private func importPlan(_ plan: ExercisePlan) throws {
        // Check for duplicate names
        if repository.exists(name: plan.name) {
            let appError = AppError.duplicatePlanName(plan.name)
            importError = appError.errorDescription
            return
        }
        
        // Save the plan
        do {
            try repository.save(plan: plan)
        } catch {
            let appError = AppError.planSaveFailed(error)
            importError = appError.errorDescription
            throw appError
        }
        
        // Clear any previous errors
        importError = nil
        
        // Reload plans to include the new one
        loadPlans()
        
        // Close the import sheet
        showingImportSheet = false
    }
}
