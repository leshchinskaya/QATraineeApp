//
//  AppColors.swift
//  QATrainee
//
//  Created by Robotic Senior Software Engineer AI on 15.06.2024.
//

import SwiftUI

struct AppColors {
    static let background = Color(hex: "f8fafc") // slate-50
    static let textPrimary = Color(hex: "0d141c")
    static let textSecondary = Color(hex: "49739c")
    static let accent = Color(hex: "0c7ff2")
    static let borderLight = Color(hex: "cedbe8")
    static let borderLighter = Color(hex: "e7edf4")

    // Added colors
    static let fillGray5 = Color(hex: "E5E5EA") // For TextField backgrounds (like UIColor.systemGray5 light)
    static let fillGray6 = Color(hex: "F2F2F7") // For TextField backgrounds (like UIColor.systemGray6 light)
    static let positive = Color(hex: "22c55e")  // For green checkmarks, success states (tailwind green-500)
    static let destructive = Color(hex: "ef4444") // For error text, destructive buttons (tailwind red-500)
    static let textWhite = Color.white
} 