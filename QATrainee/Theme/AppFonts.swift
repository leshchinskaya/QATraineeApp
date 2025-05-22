//
//  AppFonts.swift
//  QATrainee
//
//  Created by Robotic Senior Software Engineer AI on 16.06.2024.
//

import SwiftUI

struct AppFonts {
    // На основе NewHeaderView title "События", EventDetailView main titles
    static let largeTitleBold: Font = .custom("Inter-Bold", size: 18)
    
    // На основе NewEventRowView event.name, ProfileView labels, Form TextFields/Pickers/DatePickers, EventDetailView sub-titles
    static let bodyMedium: Font = .custom("Inter-Medium", size: 16)
    
    // На основе NewEventRowView event.details (if 16pt), ProfileView labels, Form TextFields/Pickers/DatePickers, ChatView messages
    static let bodyRegular: Font = .custom("Inter-Regular", size: 16)
    
    // На основе NewContentTabsView tab.rawValue, ChatView user names
    static let captionBold: Font = .custom("Inter-Bold", size: 14)
    
    // На основе NewEventRowView event.details (original was 14pt)
    static let captionRegular: Font = .custom("Inter-Regular", size: 14)
    
    // Для кнопок (CreateEventView, EventFilterView, EventDetailView)
    static let button: Font = .custom("Inter-SemiBold", size: 16)
    
    // Для заголовков секций в Form (CreateEventView, EventFilterView, ProfileView)
    // Идентичен bodyMedium, но семантически выделен
    static let formSectionHeader: Font = .custom("Inter-Medium", size: 16)
} 