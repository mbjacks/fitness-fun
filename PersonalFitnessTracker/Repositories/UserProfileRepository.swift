//
//  UserProfileRepository.swift
//  PersonalFitnessTracker
//

import Foundation

protocol UserProfileRepository {
    func save(profile: UserProfile) throws
    func load() -> UserProfile?
    func delete() throws
}

class UserDefaultsProfileRepository: UserProfileRepository {
    private let userDefaults: UserDefaults
    private let key = "userProfile"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func save(profile: UserProfile) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(profile)
        userDefaults.set(data, forKey: key)
    }
    
    func load() -> UserProfile? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(UserProfile.self, from: data)
    }
    
    func delete() throws {
        userDefaults.removeObject(forKey: key)
    }
}
