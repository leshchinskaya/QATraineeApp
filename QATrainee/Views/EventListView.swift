import SwiftUI
import SharedAccessibilityIDs

struct EventListView: View {
    @State private var allEvents: [Event] = [] // Store all events, fetched from service
    @State private var filteredEvents: [Event] = [] // Events to display after filtering

    @State private var showingFilterSheet = false
    @State private var isLoading = false // To be used later for a proper loader
    @State private var errorMessage: String? = nil

    // Filter criteria
    @State private var selectedCategory: String = "Все" // Was "All"
    @State private var startDate: Date = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
    @State private var selectedCity: String = "Все" // Was "All"

    // Bug: Date formatting susceptible to locale issues.
    // Using a fixed format string that might not be ideal for all locales.
    // Or, using a style that behaves unexpectedly in some regions.
    private let accentColor = Color(red: 0.353, green: 0.404, blue: 0.847) // #5A67D8

    private var dateFormatterWithLocaleBug: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy 'в' hh:mm a" // Adjusted 'at' to 'в'
        // formatter.locale = Locale(identifier: "ru_RU") // Optionally force Russian locale for testing this specific formatter
        return formatter
    }

    var body: some View {
        NavigationView {
            VStack { // Wrap List in VStack to show loader/error message above/instead of it
                // Bug: isLoading is true during network call, but no visual loader is shown yet.
                // This is the "missing loader" bug. We'll add a visual loader later if requested.
                if isLoading && filteredEvents.isEmpty { // Show a simple text loader if events are empty
                    ProgressView("Загрузка событий...") // Was "Fetching events, please wait..." // MODIFIED
                        .padding()
                        .tint(accentColor)
                        .accessibilityIdentifier(AccessibilityID.eventListLoadingIndicator)
                        // REMOVED: .foregroundColor(.gray)
                }
                
                if let errorMessage = errorMessage {
                    Text("Ошибка: \(errorMessage)") // Was "Error: ..."
                        .foregroundColor(.red)
                        .padding()
                }

                if !isLoading && filteredEvents.isEmpty && errorMessage == nil {
                     // This message shows if not loading, no errors, but still no events after filtering or initially.
                     Text("События не найдены или не соответствуют критериям.") // Was "No events match your criteria or none found."
                         .foregroundColor(.secondary)
                         .padding()
                         .multilineTextAlignment(.center)
                         .font(.system(size: 16))
                }
                
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 4) { // Added spacing
                            Text("Текущие фильтры") // Was "Current Filters"
                                .font(.system(size: 14, weight: .medium)) // Adjusted font
                                .foregroundColor(.secondary) // MODIFIED: Changed from .gray
                            Text("Категория: \(selectedCategory), Город: \(selectedCity)") // Was "Category: ..., City: ..."
                                .font(.system(size: 16))
                            Text("Даты: \(startDate, formatter: dateFormatterWithLocaleBug) - \(endDate, formatter: dateFormatterWithLocaleBug)") // Was "Dates: ..."
                                .font(.system(size: 16))
                        }
                        .padding(.vertical, 4) // Added padding for filter info block
                        Button { // MODIFIED: Changed to Button with Label
                            showingFilterSheet = true
                        } label: {
                            Label("Изменить фильтры", systemImage: "slider.horizontal.3") // MODIFIED: New label and icon
                                .font(.system(size: 16, weight: .medium))
                        }
                        .tint(accentColor) // Use accent color for the button
                        .accessibilityIdentifier(AccessibilityID.showFiltersButton)
                        // REMOVED: .foregroundColor(Color.blue)
                    }

                    // Only show this section if there are events and no error, and not loading initial data
                    if !filteredEvents.isEmpty && errorMessage == nil {
                        Section(header: Text("События").font(.system(size: 22, weight: .bold))) { // Was "Events" // Adjusted font
                            ForEach($filteredEvents) { $event in
                                NavigationLink(destination: EventDetailView(event: $event)) {
                                    HStack(spacing: 0) { // Set spacing to 0, manage with padding
                                        VStack(alignment: .leading, spacing: 8) { // Added spacing
                                            Text(event.name)
                                                .font(.system(size: 20, weight: .bold)) // Adjusted font
                                                .foregroundColor(.primary)
                                            
                                            HStack(spacing: 6) {
                                                Image(systemName: "calendar")
                                                    .foregroundColor(accentColor)
                                                Text("\(event.date, formatter: dateFormatterWithLocaleBug)")
                                                    .font(.system(size: 15)) // Adjusted font
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            HStack(spacing: 6) {
                                                Image(systemName: "mappin.and.ellipse")
                                                    .foregroundColor(accentColor)
                                                Text(event.city)
                                                    .font(.system(size: 15)) // Adjusted font
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                        if event.isRegistered {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green) // Green is fine for registration status
                                                .font(.system(size: 20)) // Adjusted size
                                        }
                                    }
                                    .padding() // ADDED: Inner padding for card content
                                    .background(Color(UIColor.secondarySystemGroupedBackground)) // Ensure adaptive background
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4) // Softer shadow
                                    // REMOVED: .padding(.vertical, 4)
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)) // Consistent padding around cards
                                .listRowBackground(Color.clear) // ADDED: Ensure list row background doesn't interfere
                                .listRowSeparator(.hidden) // ADDED: Hide default separators
                                // REMOVED .padding(.horizontal)
                                // REMOVED .padding(.vertical, 8)
                                .accessibilityIdentifier(AccessibilityID.eventRow(eventId: event.id))
                            }
                        }
                    }
                }
                .listStyle(.plain) // Changed to PlainListStyle for cleaner card look
            }
            .navigationTitle("Eventer") // App name, likely fine as is or could be "События" or specific app name if localized
            .navigationBarTitleDisplayMode(.automatic) // For dynamic large title
            .onAppear {
                // Initial fetch when view appears
                // Bug: This is called every time the view appears, could be optimized.
                fetchEventsFromService()
            }
            .sheet(isPresented: $showingFilterSheet, onDismiss: applyFilters) {
                EventFilterView(
                    selectedCategory: $selectedCategory,
                    startDate: $startDate,
                    endDate: $endDate,
                    selectedCity: $selectedCity
                )
            }
        }
    }

    func fetchEventsFromService() {
        isLoading = true
        errorMessage = nil
        // Bug: No visual loader is prominent here. The UI might seem stuck.
        print("UI: Инициация загрузки событий...") // Was "UI: Initiating event fetch..."
        NetworkService.shared.fetchEvents { result in
            isLoading = false
            switch result {
            case .success(let fetchedEvents):
                print("UI: Успешно загружено \(fetchedEvents.count) событий.") // Was "UI: Successfully fetched ... events."
                allEvents = fetchedEvents
                applyFilters() // Apply current filters to the newly fetched data
            case .failure(let error):
                print("UI: Ошибка загрузки событий: \(error.localizedDescription)") // Was "UI: Error fetching events: ..."
                errorMessage = error.localizedDescription
                allEvents = [] // Clear events on error
                filteredEvents = [] // Clear filtered events too
            }
        }
    }

    func applyFilters() {
        isLoading = true // Show loading state during filtering as well, though it should be fast
        errorMessage = nil // Clear previous errors when re-filtering
        
        let calendar = Calendar.current
        let adjustedEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate

        // Simulate a slight delay for filtering to make isLoading more noticeable
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            filteredEvents = allEvents.filter { event in
                let categoryMatch = (selectedCategory == "Все" || event.category == selectedCategory) // Was "All"
                let cityMatch = (selectedCity == "Все" || event.city.localizedCaseInsensitiveContains(selectedCity)) // Was "All"
                
                var dateMatch = true
                if startDate > adjustedEndDate {
                    print("Ошибка фильтра: Дата начала позже даты окончания в applyFilters. Совпадение по дате невозможно.") // Was "Filter bug: Start date is after end date..."
                    dateMatch = false // Explicitly make it not match if dates are inverted
                } else {
                     dateMatch = event.date >= startDate && event.date <= adjustedEndDate
                }

                return categoryMatch && cityMatch && dateMatch
            }
            isLoading = false
            print("Фильтры применены. Найдено \(filteredEvents.count) событий.") // Was "Filters applied. Found ... events."
            if filteredEvents.isEmpty && allEvents.isEmpty && errorMessage == nil {
                // This means fetch was successful but returned 0 events
                errorMessage = "На данный момент нет доступных событий от сервера." // Was "No events available from the server at the moment."
            } else if filteredEvents.isEmpty && !allEvents.isEmpty && errorMessage == nil {
                // This means fetch was successful, there are events, but filters match none
                // The general "No events match your criteria" in the List view will cover this.
                // Setting an error message here might be redundant if the list itself shows a "no results" message.
                // We already have: Text("События не найдены или не соответствуют критериям.")
            }
        }
    }
}

#Preview {
    EventListView()
} 