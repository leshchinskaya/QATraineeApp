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

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Детали события")) { // Was "Event Details"
                    TextField("Название события", text: $eventName) // Was "Event Name"
                        .accessibilityIdentifier("createEventNameField")
                    DatePicker("Дата", selection: $eventDate, displayedComponents: .date) // Was "Date"
                        .accessibilityIdentifier("createEventDateField")
                    TextField("Город", text: $eventCity) // Was "City"
                        .accessibilityIdentifier("createEventCityField")
                    
                    Picker("Категория", selection: $eventCategory) { // Was "Category"
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                    .accessibilityIdentifier("createEventCategoryPicker")
                    .onAppear {
                        if eventCategory.isEmpty {
                            eventCategory = categories.first ?? "Другое" // Was "Other"
                        }
                    }

                    TextField("Организатор (Ваше имя)", text: $organizerName) // Was "Organizer (Your Name)"
                        .disabled(true)
                        .accessibilityIdentifier("createEventOrganizerField")
                }

                Section(header: Text("Описание")) { // Was "Description"
                    TextField("Расскажите больше о событии...", text: $eventDescription, axis: .vertical) // Was "Tell us more about the event..."
                        .frame(minHeight: 100, alignment: .topLeading) 
                        .accessibilityIdentifier("createEventDescriptionField")
                }
                
                Button(action: submitEvent) {
                    if isSubmitting {
                        HStack {
                            Text("Отправка...") // Was "Submitting..."
                            ProgressView()
                                .padding(.leading, 5)
                        }
                        .font(.headline)
                    } else {
                        Text("Создать событие") // Was "Create Event"
                            .font(.headline)
                    }
                }
                .disabled(isSubmitting) 
                .accessibilityIdentifier("createEventSubmitButton")
            }
            .navigationTitle("Новое событие") // Was "New Event"
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