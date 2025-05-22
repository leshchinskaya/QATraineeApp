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
    @State private var selectedContentTab: ContentTab = .upcoming
    @State private var searchTextForFiltering: String = ""

    // This dateFormatter is for the "Current Filters" display.
    // NewEventRowView has its own internal date formatting.
    private var dateFormatterWithLocaleBug: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy 'в' hh:mm a" // Adjusted 'at' to 'в'
        // formatter.locale = Locale(identifier: "ru_RU") // Optionally force Russian locale for testing this specific formatter
        return formatter
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                NewHeaderView(
                    searchText: $searchTextForFiltering,
                    onShowFilters: { self.showingFilterSheet = true }
                )
                    .padding(.top, 16) // p-4 from original HeaderView example
                    .background(AppColors.background) // Ensure header has correct background

                NewContentTabsView(selectedTab: $selectedContentTab)
                    .padding(.bottom, 12) // pb-3 from original ContentTabsView example
                    .background(AppColors.background)
                    .onChange(of: selectedContentTab) { _ in
                        applyFilters()
                    }
                    .onChange(of: searchTextForFiltering) { _ in
                        applyFilters()
                    }

                if isLoading && filteredEvents.isEmpty {
                    ProgressView { // Added label for font and color styling
                        Text("Загрузка событий...")
                            .font(AppFonts.bodyRegular)
                            .foregroundColor(AppColors.textSecondary)
                    }
                        .padding()
                        .tint(AppColors.accent)
                        .accessibilityIdentifier(AccessibilityID.eventListLoadingIndicator)
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Center it
                } else if let errorMessage = errorMessage {
                    Text("Ошибка: \(errorMessage)")
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.destructive)
                        .padding()
                } else if !isLoading && filteredEvents.isEmpty && errorMessage == nil {
                    Text("События не найдены или не соответствуют критериям.")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(AppColors.textSecondary)
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredEvents.indices, id: \.self) { index in
                                NavigationLink(destination: EventDetailView(event: $filteredEvents[index])) {
                                    NewEventRowView(event: filteredEvents[index])
                                }
                                .buttonStyle(PlainButtonStyle()) // To remove default NavigationLink styling if any
                                .accessibilityIdentifier(AccessibilityID.eventRow(eventId: filteredEvents[index].id))
                            }
                        }
                    }
                }
            }
            .background(AppColors.background.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true) // NewHeaderView provides the title area
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
        let todayStart = calendar.startOfDay(for: Date())
        let adjustedEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate

        // Simulate a slight delay for filtering to make isLoading more noticeable
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            filteredEvents = allEvents.filter { event in
                let searchLowercased = searchTextForFiltering.lowercased()

                // ContentTab (Upcoming/Past) filter
                let contentTabMatch: Bool
                switch selectedContentTab {
                case .upcoming:
                    contentTabMatch = event.date >= todayStart
                case .past:
                    contentTabMatch = event.date < todayStart
                }

                let categoryMatch = (selectedCategory == "Все" || event.category == selectedCategory) // Was "All"
                let cityMatch = (selectedCity == "Все" || event.city.localizedCaseInsensitiveContains(selectedCity)) // Was "All"
                
                var dateMatch = true
                if startDate > adjustedEndDate {
                    print("Ошибка фильтра: Дата начала позже даты окончания в applyFilters. Совпадение по дате невозможно.") // Was "Filter bug: Start date is after end date..."
                    dateMatch = false // Explicitly make it not match if dates are inverted
                } else {
                     dateMatch = event.date >= startDate && event.date <= adjustedEndDate
                }

                // Search filter
                let searchMatch: Bool
                if searchLowercased.isEmpty {
                    searchMatch = true
                } else {
                    searchMatch = event.name.lowercased().contains(searchLowercased) ||
                                  event.description.lowercased().contains(searchLowercased) ||
                                  event.city.lowercased().contains(searchLowercased)
                }

                return contentTabMatch && categoryMatch && cityMatch && dateMatch && searchMatch
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
    ContentView() // Preview with ContentView to see it in context of TabView
} 