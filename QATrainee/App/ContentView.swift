//
//  ContentView.swift
//  QATrainee
//
//  Created by Maria Leshchinskaya on 14.05.2025.
//

import SwiftUI
import SharedAccessibilityIDs

// Renaming the app to "Eventer" would typically be done in project settings.
// For now, we'll proceed with the code structure.

struct ContentView: View {
    var body: some View {
        TabView {
            EventListView()
                .tabItem {
                    Label("События", systemImage: "list.bullet")
                        .accessibilityIdentifier(AccessibilityID.eventListTabLabel)
                }

            CreateEventView()
                .tabItem {
                    Label("Создать", systemImage: "plus.circle.fill")
                        .accessibilityIdentifier(AccessibilityID.createEventTabLabel)
                }
            
            ChatView(eventName: nil) // Generic chat for the tab, no specific event
                .tabItem {
                    Label("Чат", systemImage: "message.fill")
                        .accessibilityIdentifier(AccessibilityID.chatTabLabel)
                }

            ProfileView() // Use the new ProfileView
                .tabItem {
                    Label("Профиль", systemImage: "person.crop.circle")
                        .accessibilityIdentifier(AccessibilityID.profileTabLabel)
                }
        }
        .accessibilityIdentifier(AccessibilityID.mainTabView)
    }
}

#Preview {
    ContentView()
} 