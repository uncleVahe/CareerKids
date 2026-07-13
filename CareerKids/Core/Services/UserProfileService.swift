//
//  UserProfileService.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 05.01.2026.
//

import Foundation

protocol UserProfileProviding {
    func getProfile() -> UserProfile
    @discardableResult func saveProfile(name: String, age: Int) -> Bool
    func saveProfileImage(_ imageData: Data?)
    func getProfileImage() -> Data?
    func clearProfile()
    var hasCompletedOnboarding: Bool { get }
}

final class UserProfileService: UserProfileProviding {
    static let shared = UserProfileService()
    
    private let defaults: UserDefaults
    private let queue = DispatchQueue(label: "com.careerkids.userprofile", attributes: .concurrent)
    
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let userName = "userName"
        static let userAge = "userAge"
        static let profileImageData = "profileImageData"
    }
    
    // MARK: - Initialization
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - Public API
    
    var hasCompletedOnboarding: Bool {
        queue.sync {
            defaults.bool(forKey: Keys.hasCompletedOnboarding)
        }
    }
    
    func getProfile() -> UserProfile {
        queue.sync {
            let name = defaults.string(forKey: Keys.userName) ?? ""
            let ageValue = defaults.integer(forKey: Keys.userAge)
            let age = ageValue > 0 ? ageValue : nil
            
            return UserProfile(
                name: name,
                age: age,
                hasCompletedOnboarding: defaults.bool(forKey: Keys.hasCompletedOnboarding)
            )
        }
    }
    
    /// - Returns: `false` якщо дані невалідні і нічого не збережено. В Release білді
    ///   `assertionFailure` — no-op, тому caller мав отримувати мовчазний успіх на невалідних
    ///   даних; тепер caller (ViewModel) сам вирішує що показати юзеру.
    @discardableResult
    func saveProfile(name: String, age: Int) -> Bool {
        guard !name.isEmpty, age > 0 else {
            return false
        }

        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.defaults.set(name, forKey: Keys.userName)
            self.defaults.set(age, forKey: Keys.userAge)
            self.defaults.set(true, forKey: Keys.hasCompletedOnboarding)
        }
        return true
    }
    
    func clearProfile() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.defaults.removeObject(forKey: Keys.hasCompletedOnboarding)
            self.defaults.removeObject(forKey: Keys.userName)
            self.defaults.removeObject(forKey: Keys.userAge)
            self.defaults.removeObject(forKey: Keys.profileImageData)
        }
    }
    
    func saveProfileImage(_ imageData: Data?) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if let data = imageData {
                self.defaults.set(data, forKey: Keys.profileImageData)
            } else {
                self.defaults.removeObject(forKey: Keys.profileImageData)
            }
        }
    }
    
    func getProfileImage() -> Data? {
        queue.sync {
            defaults.data(forKey: Keys.profileImageData)
        }
    }
}
