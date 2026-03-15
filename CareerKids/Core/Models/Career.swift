//
//  Career.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 19.12.2025.
//

import Foundation
import SwiftUI

struct Career: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let category: CareerCategory?
}
