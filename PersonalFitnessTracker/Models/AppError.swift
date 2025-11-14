//
//  AppError.swift
//  PersonalFitnessTracker
//

import Foundation

enum AppError: LocalizedError {
    // Profile validation errors
    case invalidAge
    case invalidHeight
    case invalidWeight
    case profileSaveFailed(Error)
    case profileLoadFailed(Error)
    
    // Plan import errors
    case jsonParsingFailed
    case duplicatePlanName(String)
    case invalidPlanData
    case fileAccessDenied
    case planSaveFailed(Error)
    case planDeleteFailed(Error)
    
    // Workout errors
    case workoutNotStarted
    case workoutAlreadyActive
    case audioNotAvailable
    case timerFailed
    
    // General errors
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        // Profile validation errors
        case .invalidAge:
            return "Age must be between 10 and 120 years."
        case .invalidHeight:
            return "Height is outside the valid range for the selected unit system."
        case .invalidWeight:
            return "Weight is outside the valid range for the selected unit system."
        case .profileSaveFailed(let error):
            return "Failed to save profile: \(error.localizedDescription)"
        case .profileLoadFailed(let error):
            return "Failed to load profile: \(error.localizedDescription)"
            
        // Plan import errors
        case .jsonParsingFailed:
            return "The JSON data is malformed or cannot be parsed. Please check the format and try again."
        case .duplicatePlanName(let name):
            return "A plan with the name '\(name)' already exists. Please use a different name."
        case .invalidPlanData:
            return "The exercise plan contains invalid data. Please verify all intervals have valid timestamps, speed, and incline values."
        case .fileAccessDenied:
            return "Unable to access the selected file. Please check file permissions and try again."
        case .planSaveFailed(let error):
            return "Failed to save exercise plan: \(error.localizedDescription)"
        case .planDeleteFailed(let error):
            return "Failed to delete exercise plan: \(error.localizedDescription)"
            
        // Workout errors
        case .workoutNotStarted:
            return "No active workout session. Please start a workout first."
        case .workoutAlreadyActive:
            return "A workout is already in progress. Please complete or stop the current workout before starting a new one."
        case .audioNotAvailable:
            return "Audio notifications are not available. Please check your device settings."
        case .timerFailed:
            return "The workout timer encountered an error. Please restart the workout."
            
        // General errors
        case .unknownError(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidAge:
            return "Please enter an age between 10 and 120 years."
        case .invalidHeight:
            return "For metric: enter height between 50-300 cm. For imperial: enter height between 1'8\" and 9'10\"."
        case .invalidWeight:
            return "For metric: enter weight between 20-500 kg. For imperial: enter weight between 44-1100 lbs."
        case .profileSaveFailed, .profileLoadFailed:
            return "Try restarting the app. If the problem persists, you may need to reset your profile."
        case .jsonParsingFailed:
            return "Ensure your JSON follows the correct format with 'name', 'totalDuration', and 'intervals' fields."
        case .duplicatePlanName:
            return "Rename the plan in the JSON file before importing, or delete the existing plan first."
        case .invalidPlanData:
            return "Check that all intervals have positive timestamps, speed, and incline values, and that timestamps are in ascending order."
        case .fileAccessDenied:
            return "Make sure the file is accessible and not protected by system restrictions."
        case .planSaveFailed, .planDeleteFailed:
            return "Check available storage space and try again."
        case .workoutNotStarted:
            return "Select an exercise plan and tap 'Start Workout' to begin."
        case .workoutAlreadyActive:
            return "Stop or complete your current workout before starting a new one."
        case .audioNotAvailable:
            return "Check that notifications are enabled for this app in Settings."
        case .timerFailed:
            return "Stop the current workout and start again. If the issue persists, restart the app."
        case .unknownError:
            return "Please try again. If the problem continues, restart the app."
        }
    }
}
