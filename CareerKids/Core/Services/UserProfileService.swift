//
//  UserProfileService.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 05.01.2026.
//

import Foundation

class UserProfileService {
    static let shared = UserProfileService()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let userName = "userName"
        static let userAge = "userAge"
    }
    
    //MARK: - Onboarding
    
    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }
    
    // MARK: - User Profile
    var userName: String {
        get { defaults.string(forKey: Keys.userName) ?? "" }
        set { defaults.set(newValue, forKey: Keys.userName) }
    }
    
    var userAge: Int {
        get { defaults.integer(forKey: Keys.userAge) }
        set { defaults.set(newValue, forKey: Keys.userAge) }
    }
    
    //MARK: - Methods
    
    func saveProfile(name: String, age: Int) {
        userName = name
        userAge = age
        hasCompletedOnboarding = true
        
        print("✅ Profile saved: \(name), age: \(age)")
    }
    
    func clearProfile() {
            defaults.removeObject(forKey: Keys.hasCompletedOnboarding)
            defaults.removeObject(forKey: Keys.userName)
            defaults.removeObject(forKey: Keys.userAge)
            
            print("🗑️ Profile cleared")
        }
        
        func getProfile() -> UserProfile {
            return UserProfile(
                name: userName,
                age: userAge > 0 ? userAge : nil,
                hasCompletedOnboarding: hasCompletedOnboarding
            )
        }
}
