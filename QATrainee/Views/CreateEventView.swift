import SwiftUI

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
    private let accentColor = Color(red: 0.353, green: 0.404, blue: 0.847) // #5A67D8

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Детали события").font(.system(size: 16, weight: .medium))) { // Was "Event Details" // Font updated
                    TextField("Название события", text: $eventName) // Was "Event Name"
                        .font(.system(size: 16))
                        .accessibilityIdentifier("createEventNameField")
                    DatePicker("Дата", selection: $eventDate, displayedComponents: .date) // Was "Date"
                        .font(.system(size: 16))
                        .accessibilityIdentifier("createEventDateField")
                    TextField("Город", text: $eventCity) // Was "City"
                        .font(.system(size: 16))
                        .accessibilityIdentifier("createEventCityField")
                    
                    Picker("Категория", selection: $eventCategory) { // Was "Category"
                        ForEach(categories, id: \.self) {
                            Text($0).font(.system(size: 16)) // Font updated
                        }
                    }
                    .font(.system(size: 16)) // Font for Picker label
                    .accessibilityIdentifier("createEventCategoryPicker")
                    .onAppear {
                        if eventCategory.isEmpty {
                            eventCategory = categories.first ?? "Другое" // Was "Other"
                        }
                    }

                    TextField("Организатор (Ваше имя)", text: $organizerName) // Was "Organizer (Your Name)"
                        .disabled(true)
                        .font(.system(size: 16))
                        .accessibilityIdentifier("createEventOrganizerField")
                }

                Section(header: Text("Описание").font(.system(size: 16, weight: .medium))) { // Was "Description" // Font updated
                    TextField("Расскажите больше о событии...", text: $eventDescription, axis: .vertical) // Was "Tell us more about the event..."
                        .frame(minHeight: 100, alignment: .topLeading) 
                        .font(.system(size: 16))
                        .accessibilityIdentifier("createEventDescriptionField")
                }
                
                Button(action: submitEvent) {
                    HStack {
                        Spacer()
                        if isSubmitting {
                            Text("Отправка...") // Was "Submitting..."
                                .font(.system(size: 18, weight: .semibold))
                            ProgressView()
                                .padding(.leading, 8)
                                .tint(.white) // Ensure progress view is visible
                        } else {
                            Text("Создать событие") // Was "Create Event"
                                .font(.system(size: 18, weight: .semibold))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(isSubmitting ? Color.gray.opacity(0.7) : accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(color: accentColor.opacity(isSubmitting ? 0 : 0.3), radius: 5, x: 0, y: 3) // Conditional shadow
                }
                .disabled(isSubmitting) 
                .listRowInsets(EdgeInsets()) // Make button full width in form
                .accessibilityIdentifier("createEventSubmitButton")
            }
            .navigationTitle("Новое событие") // Was "New Event"
            .font(.system(size: 16)) // Default font for Form content not explicitly set
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
                alertMessage = "Событие '\(newEvent.name)' было отправлено (симуляция)." // Was "'...' has been submitted (simulated)."
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