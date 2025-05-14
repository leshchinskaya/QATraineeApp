import SwiftUI

struct EventDetailView: View {
    @Binding var event: Event
    @State private var showRegistrationAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Статус регистрации"
    
    @State private var isRegistering = false 

    // Bug: Date formatting susceptible to locale issues.
    private var dateFormatterWithLocaleBug: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy 'в' H:mm a zzz"
        // formatter.locale = Locale(identifier: "ru_RU") // Optionally force Russian locale
        return formatter
    }

    var isEventOver: Bool {
        return event.date < Date()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(event.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .accessibilityIdentifier("eventDetailTitle_\(event.name)")

                Text("Организатор: \(event.organizer)")
                    .font(.title3)
                    .foregroundColor(Color.orange) 
                    .accessibilityIdentifier("eventDetailOrganizer_\(event.organizer)")

                HStack {
                    Image(systemName: "calendar")
                    Text("\(event.date, formatter: dateFormatterWithLocaleBug)")
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("eventDetailDate")

                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(event.city)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("eventDetailCity_\(event.city)")

                HStack {
                    Image(systemName: "tag.fill")
                    Text(event.category)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("eventDetailCategory_\(event.category)")

                Text("Об этом событии:")
                    .font(.title2)
                    .padding(.top)
                
                Text(event.description)
                    .font(.body)
                    .foregroundColor(Color(UIColor.darkGray)) 
                    .padding(.bottom)
                    .accessibilityIdentifier("eventDetailDescription")
                
                Text("Участники: \(event.attendees.count)")
                    .font(.headline)
                    .accessibilityIdentifier("eventDetailAttendeesCount")

                Spacer()

                Button(action: processRegistration) {
                    HStack {
                        if isRegistering {
                            ProgressView()
                                .padding(.trailing, 5)
                            Text(event.isRegistered ? "Отменяем регистрацию..." : "Регистрация...")
                        } else {
                            Text(event.isRegistered ? "Зарегистрирован (Отмена - НР)" : "Зарегистрироваться")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)) 
                    .frame(maxWidth: .infinity)
                    .background(isRegistering ? Color.gray.opacity(0.5) : (event.isRegistered ? Color.gray : Color.blue))
                    .cornerRadius(5)
                }
                .accessibilityIdentifier("registerButton_\(event.name)")
                .disabled(isRegistering || (event.isRegistered && isEventOver)) 
            }
            .padding()
            .accessibilityIdentifier("eventDetailMainVStack")
        }
        .navigationTitle(event.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showRegistrationAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ChatView(eventName: event.name)) {
                    Image(systemName: "message.fill")
                }
                .accessibilityIdentifier("chatButton_\(event.name)")
            }
        }
    }
    
    func processRegistration() {
        if event.isRegistered {
            alertTitle = "Функция недоступна"
            alertMessage = "Отмена регистрации на события еще не реализована."
            showRegistrationAlert = true
            return
        }
        
        isRegistering = true
        NetworkService.shared.registerForEvent(eventId: event.id, userId: "CurrentUser") { result in
            isRegistering = false
            switch result {
            case .success(_):
                event.isRegistered = true
                if !event.attendees.contains("CurrentUser") { 
                    event.attendees.append("CurrentUser")
                }
                alertTitle = "Регистрация успешна"
                alertMessage = "Вы успешно зарегистрировались на \(event.name)!"
            case .failure(let error):
                alertTitle = "Ошибка регистрации"
                alertMessage = "Не удалось зарегистрироваться на событие: \(error.localizedDescription)"
            }
            showRegistrationAlert = true
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Для предварительного просмотра создадим несколько событий на русском
        // Это не повлияет на основную логику sampleEvents, но сделает превью более релевантным
        let sampleRussianEventPast = Event(id: UUID(), name: "Прошедший Рок Концерт", date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, city: "Москва", category: "Музыка", description: "Легендарный рок концерт, который уже прошел.", organizer: "Рок Продакшн")
        let sampleRussianEventFuture = Event(id: UUID(), name: "Тех Конференция 2025", date: Calendar.current.date(byAdding: .month, value: 3, to: Date())!, city: "Санкт-Петербург", category: "Конференция", description: "Главная тех конференция года.", isRegistered: false, organizer: "Тех Гуру")
        let sampleRussianEventRegistered = Event(id: UUID(), name: "Местный Благотворительный Забег", date: Calendar.current.date(byAdding: .weekOfYear, value: 2, to: Date())!, city: "Казань", category: "Спорт", description: "Пробегитесь ради доброго дела!", isRegistered: true, organizer: "Клуб Бегунов Казани", attendees: ["CurrentUser"])


        NavigationView {
            EventDetailView(event: .constant(sampleRussianEventPast))
                .previewDisplayName("Детали Прошедшего События")
        }
        NavigationView {
            EventDetailView(event: .constant(sampleRussianEventFuture))
                .previewDisplayName("Детали Текущего События")
        }
        NavigationView {
             EventDetailView(event: .constant(sampleRussianEventRegistered))
                .previewDisplayName("Детали Зарегистрированного События")
        }
    }
} 