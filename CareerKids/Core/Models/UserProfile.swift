//
//  UserProfile.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 19.12.2025.
//

import Foundation

struct UserProfile {
    var name: String
    var age: Int?
    var hasCompletedOnboarding: Bool
    
    static var empty: UserProfile {
        UserProfile(name: "", age: nil, hasCompletedOnboarding: false)
    }
}
