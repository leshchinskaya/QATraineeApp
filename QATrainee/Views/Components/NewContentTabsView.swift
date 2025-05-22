//
//  NewContentTabsView.swift
//  QATrainee
//
//  Created by Robotic Senior Software Engineer AI on 15.06.2024.
//

import SwiftUI

enum ContentTab: String, CaseIterable, Identifiable {
    case upcoming = "Предстоящие"
    case past = "Прошедшие"
    var id: String { self.rawValue }
}

struct NewContentTabsView: View {
    @Binding var selectedTab: ContentTab

    var body: some View {
        HStack(spacing: 32) { // gap-8
            ForEach(ContentTab.allCases) { tab in
                VStack(spacing: 0) {
                    Text(tab.rawValue)
                        .font(.custom("Inter-Bold", size: 14)) // text-sm font-bold
                        .foregroundColor(selectedTab == tab ? AppColors.textPrimary : AppColors.textSecondary)
                        .padding(.top, 16) // pt-4
                        .padding(.bottom, 13) // pb-[13px]
                    
                    Rectangle()
                        .frame(height: 3)
                        .foregroundColor(selectedTab == tab ? AppColors.accent : .clear) // border-b-[3px]
                }
                .contentShape(Rectangle()) // Make the whole area tappable
                .onTapGesture {
                    selectedTab = tab
                }
            }
            Spacer() // To push tabs to the left
        }
        .padding(.horizontal) // px-4
        .background(
            VStack { // For the bottom border of the whole tab container
                Spacer()
                AppColors.borderLight.frame(height: 1) // border-b border-[#cedbe8]
            }
        )
    }
} 
