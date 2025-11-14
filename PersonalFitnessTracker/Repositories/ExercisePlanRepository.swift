//
//  ExercisePlanRepository.swift
//  PersonalFitnessTracker
//

import Foundation

protocol ExercisePlanRepository {
    func save(plan: ExercisePlan) throws
    func loadAll() -> [ExercisePlan]
    func load(id: UUID) -> ExercisePlan?
    func delete(id: UUID) throws
    func exists(name: String) -> Bool
}

class FileManagerPlanRepository: ExercisePlanRepository {
    private let fileManager: FileManager
    private var plansDirectory: URL
    
    init(fileManager: FileManager = .default) throws {
        self.fileManager = fileManager
        
        // Get Documents directory
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw RepositoryError.directoryNotFound
        }
        
        // Create plans directory
        self.plansDirectory = documentsDirectory.appendingPathComponent("ExercisePlans", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: plansDirectory.path) {
            try fileManager.createDirectory(at: plansDirectory, withIntermediateDirectories: true)
        }
    }
    
    func save(plan: ExercisePlan) throws {
        let fileURL = plansDirectory.appendingPathComponent("\(plan.id.uuidString).json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(plan)
        try data.write(to: fileURL)
    }
    
    func loadAll() -> [ExercisePlan] {
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: plansDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return fileURLs.compactMap { url in
            guard url.pathExtension == "json",
                  let data = try? Data(contentsOf: url),
                  let plan = try? decoder.decode(ExercisePlan.self, from: data) else {
                return nil
            }
            return plan
        }
    }
    
    func load(id: UUID) -> ExercisePlan? {
        let fileURL = plansDirectory.appendingPathComponent("\(id.uuidString).json")
        
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(ExercisePlan.self, from: data)
    }
    
    func delete(id: UUID) throws {
        let fileURL = plansDirectory.appendingPathComponent("\(id.uuidString).json")
        try fileManager.removeItem(at: fileURL)
    }
    
    func exists(name: String) -> Bool {
        let allPlans = loadAll()
        return allPlans.contains { $0.name == name }
    }
}

enum RepositoryError: Error {
    case directoryNotFound
    case fileNotFound
    case encodingFailed
    case decodingFailed
}
