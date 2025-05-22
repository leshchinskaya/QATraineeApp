//
//  NewEventRowView.swift
//  QATrainee
//
//  Created by Robotic Senior Software Engineer AI on 15.06.2024.
//

import SwiftUI

struct NewEventRowView: View {
    let event: Event

    private var eventDetails: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d" // e.g., Oct 26
        return "\(dateFormatter.string(from: event.date)) · \(event.city)"
    }

    var body: some View {
        HStack(spacing: 16) { // gap-4
            // Placeholder for AsyncImage as imageUrl is not in the current Event model
//            Image(systemName: "photo") // Placeholder icon
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 56, height: 56) // size-14
//                .padding(8) // Add some padding to the icon itself
//                .background(Color.gray.opacity(0.3)) // Placeholder background
//                .clipShape(RoundedRectangle(cornerRadius: 8)) // rounded-lg

            VStack(alignment: .leading, spacing: 2) { // Adjusted spacing
                Text(event.name) // Mapped from event.title
                    .font(.custom("Inter-Medium", size: 16)) // text-base font-medium
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1) // line-clamp-1

                Text(eventDetails) // Mapped from event.details
                    .font(.custom("Inter-Regular", size: 14)) // text-sm font-normal
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2) // line-clamp-2
            }
            
            Spacer() // Push content to left
            
            if event.isRegistered {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 20))
            }
        }
        .padding(.horizontal) // px-4
        .frame(minHeight: 72) // min-h-[72px]
        .padding(.vertical, 8) // py-2
        .background(AppColors.background) // bg-slate-50
    }
}

#Preview {
    NewEventRowView(event: Event(id: UUID(), name: "Tech Conference 2024", date: Date(), city: "New York", category: "Tech", description: "A great conference", isRegistered: true, organizer: "Org Inc"))
        .padding()
        .background(Color.gray.opacity(0.1))
} 
