import SwiftUI
import SharedAccessibilityIDs

struct CreateEventView: View {
    @State private var eventName: String = ""
    @State private var eventDate: Date = Date()
    @State private var eventCity: String = ""
    @State private var eventCategory: String = ""
    @State private var eventDescription: String = ""
    @State private var organizerName: String = "Вы" // Was "CurrentUser"

    let categories = ["Музыка", "Спорт", "Конференция", "Семинар", "Еда", "Благотворительность", "Другое"] // Was ["Music", "Sports", ..., "Other"]

    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var isSubmitting = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Детали события").font(AppFonts.formSectionHeader).foregroundColor(AppColors.textPrimary)) {
                    TextField("Название события", text: $eventName) // Was "Event Name"
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.textPrimary)
                        .accessibilityIdentifier(AccessibilityID.createEventNameField)
                    DatePicker("Дата", selection: $eventDate, displayedComponents: .date) // Was "Date"
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.textPrimary)
                        .accessibilityIdentifier(AccessibilityID.createEventDateField)
                    TextField("Город", text: $eventCity) // Was "City"
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.textPrimary)
                        .accessibilityIdentifier(AccessibilityID.createEventCityField)
                    
                    Picker("Категория", selection: $eventCategory) { // Was "Category"
                        ForEach(categories, id: \.self) {
                            Text($0).font(AppFonts.bodyRegular)
                        }
                    }
                    .font(AppFonts.bodyRegular) // Font for Picker label
                    .foregroundColor(AppColors.textPrimary)
                    .accessibilityIdentifier(AccessibilityID.createEventCategoryPicker)
                    .onAppear {
                        if eventCategory.isEmpty {
                            eventCategory = categories.first ?? "Другое" // Was "Other"
                        }
                    }

                    TextField("Организатор (Ваше имя)", text: $organizerName) // Was "Organizer (Your Name)"
                        .disabled(true)
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.textSecondary) // Disabled text color
                        .accessibilityIdentifier(AccessibilityID.createEventOrganizerField)
                }

                Section(header: Text("Описание").font(AppFonts.formSectionHeader).foregroundColor(AppColors.textPrimary)) { // Was "Description" // Font updated
                    TextField("Расскажите больше о событии...", text: $eventDescription, axis: .vertical) // Was "Tell us more about the event..."
                        .frame(minHeight: 100, alignment: .topLeading) 
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.textPrimary)
                        .accessibilityIdentifier(AccessibilityID.createEventDescriptionField)
                }
                
                Button(action: submitEvent) {
                    HStack {
                        Spacer()
                        if isSubmitting {
                            Text("Отправка...") // Was "Submitting..."
                                .font(AppFonts.button)
                            ProgressView()
                                .padding(.leading, 8)
                                .tint(.white) // Ensure progress view is visible
                        } else {
                            Text("Создать событие") // Was "Create Event"
                                .font(AppFonts.button)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(isSubmitting ? AppColors.textSecondary.opacity(0.5) : AppColors.accent)
                    .foregroundColor(AppColors.textWhite)
                    .cornerRadius(10)
                    .shadow(color: AppColors.accent.opacity(isSubmitting ? 0 : 0.3), radius: 5, x: 0, y: 3) // Conditional shadow
                }
                .disabled(isSubmitting) 
                .listRowInsets(EdgeInsets()) // Make button full width in form
                .accessibilityIdentifier(AccessibilityID.createEventSubmitButton)
            }
            .navigationTitle("Новое событие") // Was "New Event"
            .font(.system(size: 16)) // Default font for Form content not explicitly set
            // This default font will be overridden by specific AppFonts settings on elements.
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    func submitEvent() {
        isSubmitting = true
        
        NetworkService.shared.createEvent(
            name: eventName,
            date: eventDate,
            city: eventCity,
            category: eventCategory,
            description: eventDescription,
            organizer: organizerName
        ) { result in
            isSubmitting = false
            switch result {
            case .success(let newEvent):
                alertTitle = "Успех!" // Was "Success!"
                alertMessage = "Событие '\(newEvent.name)' было отправлено."
                clearForm()
            case .failure(let error):
                alertTitle = "Ошибка отправки" // Was "Submission Failed"
                alertMessage = error.localizedDescription 
            }
            showingAlert = true
        }
    }

    func clearForm() {
        eventName = ""
        eventDate = Date()
        eventCity = ""
        eventCategory = categories.first ?? "Другое" // Was "Other"
        eventDescription = ""
    }
}

#Preview {
    CreateEventView()
} 
