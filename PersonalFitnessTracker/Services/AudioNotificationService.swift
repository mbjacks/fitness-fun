//
//  AudioNotificationService.swift
//  PersonalFitnessTracker
//

import Foundation
import AVFoundation
import Combine

enum NotificationSound: String, Codable {
    case beep
    case voice
}

class AudioNotificationService: ObservableObject {
    @Published var notificationSound: NotificationSound = .beep
    var speedUnit: SpeedUnit = .milesPerHour
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        configureAudioSession()
    }
    
    // MARK: - Public Notification Methods
    
    /// Plays a warning notification 5 seconds before an interval change
    func playWarningNotification(for interval: WorkoutInterval) {
        switch notificationSound {
        case .beep:
            playBeep()
        case .voice:
            let message = "Get ready. In 5 seconds, change speed to \(formatSpeed(interval.speed)) and incline to \(formatIncline(interval.incline))"
            speak(text: message)
        }
    }
    
    /// Plays a notification when an interval change occurs
    func playChangeNotification(for interval: WorkoutInterval) {
        switch notificationSound {
        case .beep:
            playBeep()
        case .voice:
            let message = "Change now. Speed \(formatSpeed(interval.speed)), incline \(formatIncline(interval.incline))"
            speak(text: message)
        }
    }
    
    /// Plays a notification when the workout is completed
    func playCompletionNotification() {
        switch notificationSound {
        case .beep:
            // Play a double beep for completion
            playBeep()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.playBeep()
            }
        case .voice:
            speak(text: "Workout complete. Great job!")
        }
    }
    
    // MARK: - Private Audio Methods
    
    /// Speaks the given text using AVSpeechSynthesizer
    private func speak(text: String) {
        // Stop any ongoing speech
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
    }
    
    /// Plays a beep sound using system sound
    private func playBeep() {
        // Use system sound for beep
        // Sound ID 1057 is a short beep sound
        AudioServicesPlaySystemSound(1057)
    }
    
    // MARK: - Audio Session Configuration
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Formatting Helpers
    
    private func formatSpeed(_ speed: Double) -> String {
        let interval = WorkoutInterval(timestamp: 0, speed: speed, incline: 0)
        let displaySpeed: Double
        let unit: String
        
        switch speedUnit {
        case .milesPerHour:
            displaySpeed = interval.speedInMPH()
            unit = "miles per hour"
        case .kilometersPerHour:
            displaySpeed = interval.speedInKPH()
            unit = "kilometers per hour"
        }
        
        return String(format: "%.1f \(unit)", displaySpeed)
    }
    
    private func formatIncline(_ incline: Double) -> String {
        return String(format: "%.1f percent", incline)
    }
}
