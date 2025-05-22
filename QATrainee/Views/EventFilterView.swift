import SwiftUI
import SharedAccessibilityIDs

struct EventFilterView: View {
    @Binding var selectedCategory: String
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var selectedCity: String // This will now be the ID of the city

    let categories = ["Все", "Музыка", "Спорт", "Конференция", "Семинар", "Еда", "Благотворительность", "Другое"]
    
    @State private var availableCities: [City] = []
    @State private var isLoadingCities = false
    @State private var cityErrorMessage: String?
    // Default city option representing "All"
    private let allCitiesOption = City(id: "Все", name: "Все города", position: CityPosition(lat: "", long: ""))

    @State private var localStartDate: Date
    @State private var localEndDate: Date
    
    @Environment(\.dismiss) var dismiss

    init(selectedCategory: Binding<String>, startDate: Binding<Date>, endDate: Binding<Date>, selectedCity: Binding<String>) {
        self._selectedCategory = selectedCategory
        self._startDate = startDate
        self._endDate = endDate
        self._selectedCity = selectedCity
        self._localStartDate = State(initialValue: startDate.wrappedValue)
        self._localEndDate = State(initialValue: endDate.wrappedValue)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Фильтр по категории").font(AppFonts.formSectionHeader).foregroundColor(AppColors.textPrimary)) {
                    Picker("Категория", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).font(AppFonts.bodyRegular)
                        }
                    }
                    .font(AppFonts.bodyRegular) // For Picker label
                    .foregroundColor(AppColors.textPrimary)
                    .pickerStyle(.menu)
                    .accessibilityIdentifier(AccessibilityID.filterCategoryPicker)
                }

                Section(header: Text("Фильтр по дате").font(AppFonts.formSectionHeader).foregroundColor(AppColors.textPrimary)) {
                    DatePicker("Дата начала", selection: $localStartDate, displayedComponents: .date)
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.textPrimary)
                        .accessibilityIdentifier(AccessibilityID.filterStartDatePicker)
                    DatePicker("Дата окончания", selection: $localEndDate, displayedComponents: .date)
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.textPrimary)
                        .accessibilityIdentifier(AccessibilityID.filterEndDatePicker)
                }

                Section(header: Text("Фильтр по городу").font(AppFonts.formSectionHeader).foregroundColor(AppColors.textPrimary)) {
                    if isLoadingCities {
                        HStack {
                            Text("Загрузка городов...")
                                .font(AppFonts.bodyRegular)
                                .foregroundColor(AppColors.textSecondary)
                            ProgressView().tint(AppColors.accent)
                        }
                    } else if let cityErrorMessage = cityErrorMessage {
                        Text("Ошибка: \(cityErrorMessage)")
                            .font(AppFonts.bodyRegular)
                            .foregroundColor(AppColors.destructive)
                    } else {
                        Picker("Город", selection: $selectedCity) {
                            // Add "All" option manually at the beginning
                            Text(allCitiesOption.name).tag(allCitiesOption.id).font(AppFonts.bodyRegular)
                            
                            ForEach(availableCities) { city in
                                Text(city.name).tag(city.id).font(AppFonts.bodyRegular)
                            }
                        }
                        .font(AppFonts.bodyRegular) // For Picker label
                        .foregroundColor(AppColors.textPrimary)
                        .pickerStyle(.menu)
                        .accessibilityIdentifier(AccessibilityID.filterCityPicker)
                    }
                }
                
                Button("Применить фильтры") {
                    if localEndDate < localStartDate {
                        print("Предупреждение: Дата окончания раньше даты начала - фильтр может работать некорректно!")
                    }
                    startDate = localStartDate
                    endDate = localEndDate
                    print("Фильтры применены: Категория - \(selectedCategory), Город ID - \(selectedCity), Начало - \(startDate), Конец - \(endDate)")
                    dismiss()
                }
                .font(AppFonts.button)
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppColors.accent)
                .foregroundColor(AppColors.textWhite)
                .cornerRadius(10)
                .shadow(color: AppColors.accent.opacity(0.3), radius: 5, x: 0, y: 3)
                .listRowInsets(EdgeInsets()) // Make button full width
                .accessibilityIdentifier(AccessibilityID.filterApplyButton)

                Button("Сбросить фильтры") {
                    selectedCategory = "Все"
                    localStartDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
                    localEndDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
                    startDate = localStartDate
                    endDate = localEndDate
                    selectedCity = allCitiesOption.id // Reset to "All" ID
                    print("Фильтры сброшены.")
                    dismiss()
                }
                .font(AppFonts.button)
                .padding() 
                .frame(maxWidth: .infinity)
                .foregroundColor(AppColors.destructive) 
                .background(AppColors.destructive.opacity(0.1)) 
                .cornerRadius(10)
                .listRowInsets(EdgeInsets()) // Make button full width
                .accessibilityIdentifier(AccessibilityID.filterResetButton)
            }
            .navigationTitle("Фильтр событий")
            .navigationBarItems(trailing: Button("Готово") {
                if localEndDate < localStartDate {
                    print("Предупреждение из Готово: Дата окончания раньше даты начала - фильтр может работать некорректно!")
                }
                startDate = localStartDate
                endDate = localEndDate
                // selectedCity is already bound
                dismiss()
            }
            .font(AppFonts.bodyMedium) // Font for Done button
            .tint(AppColors.accent) // Accent color for Done button
            .accessibilityIdentifier(AccessibilityID.filterDoneButton))
            .onAppear {
                fetchCityData()
            }
        }
    }

    func fetchCityData() {
        isLoadingCities = true
        cityErrorMessage = nil
        NetworkService.shared.fetchCities { result in
            isLoadingCities = false
            switch result {
            case .success(let cities):
                self.availableCities = cities
                // Ensure "All" is selected if the current selection is not among the fetched cities or is empty
                if !cities.contains(where: { $0.id == selectedCity }) && selectedCity != allCitiesOption.id {
                     selectedCity = allCitiesOption.id
                } else if selectedCity.isEmpty { // If it was empty, default to All
                    selectedCity = allCitiesOption.id
                }
            case .failure(let error):
                self.cityErrorMessage = error.localizedDescription
                self.availableCities = [] // Clear cities on error
                 selectedCity = allCitiesOption.id // Default to All on error
            }
        }
    }
}

struct EventFilterView_Previews: PreviewProvider {
    static var previews: some View {
        EventFilterView(
            selectedCategory: .constant("Все"),
            startDate: .constant(Date()), 
            endDate: .constant(Date().addingTimeInterval(86400*7)),
            selectedCity: .constant("Все") // Preview with "All" city ID
        )
        .environment(\.colorScheme, .dark) // Example dark mode preview
    }
} 