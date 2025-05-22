//
//  NewHeaderView.swift
//  QATrainee
//
//  Created by Robotic Senior Software Engineer AI on 15.06.2024.
//

import SwiftUI

struct NewHeaderView: View {
    @Binding var searchText: String
    var onShowFilters: () -> Void

    @State private var isSearching: Bool = false

    var body: some View {
        HStack(spacing: 8) { // Adjusted spacing
            // Filter Button
            Button(action: onShowFilters) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(width: 40, height: 40) // Adjusted size for a more compact look

            if isSearching {
                TextField("Поиск событий...", text: $searchText)
                    .textFieldStyle(.plain)
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.systemGray5))
                    )
                    .frame(maxWidth: .infinity)
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .leading)))
            } else {
                Text("События")
                    .font(.custom("Inter-Bold", size: 18))
                    .foregroundColor(AppColors.textPrimary)
                    .tracking(-0.015 * 18)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.opacity.combined(with: .scale(scale: 1.0, anchor: .center)))
            }

            // Search/Clear Button
            if isSearching {
                Button(action: {
                    withAnimation {
                        searchText = ""
                        isSearching = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(width: 40, height: 40) // Adjusted size
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .trailing)))
            } else {
                Button(action: {
                    withAnimation {
                        isSearching = true
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(width: 40, height: 40) // Adjusted size
                .transition(.opacity.combined(with: .scale(scale: 1.0, anchor: .center)))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8) // pb-2
        .animation(.easeInOut(duration: 0.25), value: isSearching)
    }
} 
