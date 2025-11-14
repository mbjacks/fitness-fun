//
//  PlanParserService.swift
//  PersonalFitnessTracker
//

import Foundation

enum PlanParserError: Error, LocalizedError {
    case invalidJSON
    case missingRequiredFields
    case invalidIntervalData
    
    var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return "The JSON data is malformed or cannot be parsed."
        case .missingRequiredFields:
            return "Required fields are missing from the exercise plan."
        case .invalidIntervalData:
            return "One or more intervals contain invalid data."
        }
    }
}

struct PlanParserService {
    
    // MARK: - Parsing Methods
    
    /// Parse an exercise plan from a JSON string
    func parse(jsonString: String) throws -> ExercisePlan {
        guard let data = jsonString.data(using: .utf8) else {
            throw PlanParserError.invalidJSON
        }
        
        return try parseData(data)
    }
    
    /// Parse an exercise plan from a file URL
    func parse(fileURL: URL) throws -> ExercisePlan {
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            throw PlanParserError.invalidJSON
        }
        
        return try parseData(data)
    }
    
    // MARK: - Private Parsing Helper
    
    private func parseData(_ data: Data) throws -> ExercisePlan {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Try to detect which format we're dealing with
        // First, try to decode as a generic dictionary to check for format indicators
        if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // Check if this is the complex format (has "steps" array)
            if jsonObject["steps"] != nil {
                return try parseComplexFormat(data: data, decoder: decoder)
            }
        }
        
        // Otherwise, parse as simple format
        return try parseSimpleFormat(data: data, decoder: decoder)
    }
    
    /// Parse simple format with intervals array
    private func parseSimpleFormat(data: Data, decoder: JSONDecoder) throws -> ExercisePlan {
        let jsonPlan: JSONExercisePlan
        do {
            jsonPlan = try decoder.decode(JSONExercisePlan.self, from: data)
        } catch {
            throw PlanParserError.invalidJSON
        }
        
        // Validate required fields
        guard !jsonPlan.name.isEmpty else {
            throw PlanParserError.missingRequiredFields
        }
        
        guard let intervals = jsonPlan.intervals, !intervals.isEmpty else {
            throw PlanParserError.missingRequiredFields
        }
        
        // Convert JSON intervals to WorkoutInterval
        let workoutIntervals = try intervals.map { jsonInterval -> WorkoutInterval in
            guard let timestamp = jsonInterval.timestamp,
                  let speed = jsonInterval.speed,
                  let incline = jsonInterval.incline else {
                throw PlanParserError.invalidIntervalData
            }
            
            // Validate interval data
            guard timestamp >= 0, speed >= 0, incline >= 0 else {
                throw PlanParserError.invalidIntervalData
            }
            
            return WorkoutInterval(timestamp: timestamp, speed: speed, incline: incline)
        }
        
        // Calculate total duration from intervals or use provided value
        let totalDuration: TimeInterval
        if let providedDuration = jsonPlan.totalDuration {
            totalDuration = providedDuration
        } else {
            // Use the last interval's timestamp as total duration
            totalDuration = workoutIntervals.last?.timestamp ?? 0
        }
        
        let plan = ExercisePlan(
            name: jsonPlan.name,
            totalDuration: totalDuration,
            intervals: workoutIntervals
        )
        
        // Validate the complete plan
        guard validate(plan: plan) else {
            throw PlanParserError.invalidIntervalData
        }
        
        return plan
    }
    
    /// Parse complex format with steps array
    private func parseComplexFormat(data: Data, decoder: JSONDecoder) throws -> ExercisePlan {
        let jsonPlan: JSONComplexExercisePlan
        do {
            jsonPlan = try decoder.decode(JSONComplexExercisePlan.self, from: data)
        } catch {
            throw PlanParserError.invalidJSON
        }
        
        // Validate required fields
        guard !jsonPlan.name.isEmpty else {
            throw PlanParserError.missingRequiredFields
        }
        
        guard let steps = jsonPlan.steps, !steps.isEmpty else {
            throw PlanParserError.missingRequiredFields
        }
        
        // Convert steps to intervals
        var workoutIntervals: [WorkoutInterval] = []
        
        for step in steps {
            guard let startMin = step.startMin else {
                throw PlanParserError.invalidIntervalData
            }
            
            // Convert minutes to seconds for timestamp
            let timestamp = startMin * 60.0
            
            // Handle speed (can be single value or array)
            let speed: Double
            if let singleSpeed = step.speedMph {
                speed = singleSpeed
            } else if let speedArray = step.speedMphArray, !speedArray.isEmpty {
                // Use first value from array
                speed = speedArray[0]
            } else {
                throw PlanParserError.invalidIntervalData
            }
            
            // Handle incline (can be single value or array)
            let incline: Double
            if let singleIncline = step.inclinePercent {
                incline = singleIncline
            } else if let inclineArray = step.inclinePercentArray, !inclineArray.isEmpty {
                // Use first value from array
                incline = inclineArray[0]
            } else {
                throw PlanParserError.invalidIntervalData
            }
            
            // Convert mph to km/h (1 mph = 1.60934 km/h)
            let speedKmh = speed * 1.60934
            
            // Validate interval data
            guard timestamp >= 0, speedKmh >= 0, incline >= 0 else {
                throw PlanParserError.invalidIntervalData
            }
            
            workoutIntervals.append(WorkoutInterval(
                timestamp: timestamp,
                speed: speedKmh,
                incline: incline
            ))
        }
        
        // Sort intervals by timestamp (should already be sorted, but ensure it)
        workoutIntervals.sort { $0.timestamp < $1.timestamp }
        
        // Calculate total duration from total_duration_minutes or last step's end time
        let totalDuration: TimeInterval
        if let durationMinutes = jsonPlan.totalDurationMinutes {
            totalDuration = durationMinutes * 60.0
        } else if let lastStep = steps.last, let endMin = lastStep.endMin {
            totalDuration = endMin * 60.0
        } else {
            // Fallback to last interval timestamp
            totalDuration = workoutIntervals.last?.timestamp ?? 0
        }
        
        let plan = ExercisePlan(
            name: jsonPlan.name,
            totalDuration: totalDuration,
            intervals: workoutIntervals
        )
        
        // Validate the complete plan
        guard validate(plan: plan) else {
            throw PlanParserError.invalidIntervalData
        }
        
        return plan
    }
    
    // MARK: - Validation
    
    /// Validate an exercise plan for correctness
    func validate(plan: ExercisePlan) -> Bool {
        // Check that plan has a name
        guard !plan.name.isEmpty else {
            return false
        }
        
        // Check that plan has at least one interval
        guard !plan.intervals.isEmpty else {
            return false
        }
        
        // Check that total duration is positive
        guard plan.totalDuration > 0 else {
            return false
        }
        
        // Check that intervals are sorted by timestamp
        for i in 1..<plan.intervals.count {
            if plan.intervals[i].timestamp < plan.intervals[i-1].timestamp {
                return false
            }
        }
        
        // Check that first interval starts at 0
        guard plan.intervals.first?.timestamp == 0 else {
            return false
        }
        
        // Check that all intervals have valid values
        for interval in plan.intervals {
            guard interval.timestamp >= 0,
                  interval.speed >= 0,
                  interval.incline >= 0 else {
                return false
            }
        }
        
        return true
    }
}

// MARK: - JSON Decodable Models

// Simple format models
private struct JSONExercisePlan: Decodable {
    let name: String
    let totalDuration: TimeInterval?
    let intervals: [JSONWorkoutInterval]?
}

private struct JSONWorkoutInterval: Decodable {
    let timestamp: TimeInterval?
    let speed: Double?
    let incline: Double?
}

// Complex format models
private struct JSONComplexExercisePlan: Decodable {
    let name: String
    let totalDurationMinutes: Double?
    let steps: [JSONWorkoutStep]?
}

private struct JSONWorkoutStep: Decodable {
    let startMin: Double?
    let endMin: Double?
    let speedMph: Double?
    let speedMphArray: [Double]?
    let inclinePercent: Double?
    let inclinePercentArray: [Double]?
    
    enum CodingKeys: String, CodingKey {
        case startMin
        case endMin
        case speedMph
        case inclinePercent
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        startMin = try container.decodeIfPresent(Double.self, forKey: .startMin)
        endMin = try container.decodeIfPresent(Double.self, forKey: .endMin)
        
        // Try to decode speed as single value or array
        if let singleSpeed = try? container.decode(Double.self, forKey: .speedMph) {
            speedMph = singleSpeed
            speedMphArray = nil
        } else if let arraySpeed = try? container.decode([Double].self, forKey: .speedMph) {
            speedMph = nil
            speedMphArray = arraySpeed
        } else {
            speedMph = nil
            speedMphArray = nil
        }
        
        // Try to decode incline as single value or array
        if let singleIncline = try? container.decode(Double.self, forKey: .inclinePercent) {
            inclinePercent = singleIncline
            inclinePercentArray = nil
        } else if let arrayIncline = try? container.decode([Double].self, forKey: .inclinePercent) {
            inclinePercent = nil
            inclinePercentArray = arrayIncline
        } else {
            inclinePercent = nil
            inclinePercentArray = nil
        }
    }
}
