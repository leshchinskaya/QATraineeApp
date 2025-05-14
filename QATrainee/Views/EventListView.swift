import SwiftUI

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
                         .foregroundColor(.gray)
                         .padding()
                         .multilineTextAlignment(.center)
                }
                
                List {
                    Section {
                        VStack(alignment: .leading) {
                            Text("Текущие фильтры") // Was "Current Filters"
                                .font(.caption)
                                .foregroundColor(.secondary) // MODIFIED: Changed from .gray
                            Text("Категория: \(selectedCategory), Город: \(selectedCity)") // Was "Category: ..., City: ..."
                            Text("Даты: \(startDate, formatter: dateFormatterWithLocaleBug) - \(endDate, formatter: dateFormatterWithLocaleBug)") // Was "Dates: ..."
                        }
                        Button { // MODIFIED: Changed to Button with Label
                            showingFilterSheet = true
                        } label: {
                            Label("Изменить фильтры", systemImage: "slider.horizontal.3") // MODIFIED: New label and icon
                        }
                        .accessibilityIdentifier("showFiltersButton")
                        // REMOVED: .foregroundColor(Color.blue)
                    }

                    // Only show this section if there are events and no error, and not loading initial data
                    if !filteredEvents.isEmpty && errorMessage == nil {
                        Section(header: Text("События").font(.headline)) { // Was "Events"
                            ForEach($filteredEvents) { $event in
                                NavigationLink(destination: EventDetailView(event: $event)) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(event.name)
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                            Text("\(event.date, formatter: dateFormatterWithLocaleBug)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary) // MODIFIED: Changed from .gray
                                            Text(event.city)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary) // MODIFIED: Changed from .gray
                                        }
                                        Spacer()
                                        if event.isRegistered {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding() // ADDED: Inner padding for card content
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemGroupedBackground))) // ADDED: Card background
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // ADDED: Card shadow
                                    // REMOVED: .padding(.vertical, 4)
                                }
                                .listRowInsets(EdgeInsets()) // ADDED: Remove default list row insets
                                .listRowBackground(Color.clear) // ADDED: Ensure list row background doesn't interfere
                                .listRowSeparator(.hidden) // ADDED: Hide default separators
                                .padding(.horizontal) // ADDED: Horizontal padding for the card from screen edges
                                .padding(.vertical, 8) // ADDED: Vertical spacing between cards
                                .accessibilityIdentifier("eventRow_\(event.id.uuidString)")
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle()) // Using GroupedListStyle to better manage sections
            }
            .navigationTitle("Eventer") // App name, likely fine as is or could be "События" or specific app name if localized
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
            }
        }
    }
}

#Preview {
    EventListView()
} 