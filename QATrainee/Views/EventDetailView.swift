import SwiftUI
import SharedAccessibilityIDs

struct EventDetailView: View {
    @Binding var event: Event
    @State private var showRegistrationAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Статус регистрации"
    
    @State private var isRegistering = false 

    // Bug: Date formatting susceptible to locale issues.
    private let accentColor = Color(red: 0.353, green: 0.404, blue: 0.847) // #5A67D8

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
            VStack(alignment: .leading, spacing: 18) {
                Text(event.name)
                    .font(.system(size: 28, weight: .bold))
                    .accessibilityIdentifier(AccessibilityID.eventDetailTitle(eventName: event.name))

                Text("Организатор: \(event.organizer)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(accentColor)
                    .accessibilityIdentifier(AccessibilityID.eventDetailOrganizer(organizerName: event.organizer))

                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(accentColor)
                    Text("\(event.date, formatter: dateFormatterWithLocaleBug)")
                        .font(.system(size: 16))
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier(AccessibilityID.eventDetailDate)

                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(accentColor)
                    Text(event.city)
                        .font(.system(size: 16))
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier(AccessibilityID.eventDetailCity(cityName: event.city))

                HStack(spacing: 8) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(accentColor)
                    Text(event.category)
                        .font(.system(size: 16))
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier(AccessibilityID.eventDetailCategory(categoryName: event.category))

                Text("Об этом событии:")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.top)
                
                Text(event.description)
                    .font(.system(size: 16))
                    .foregroundColor(Color(UIColor.label))
                    .padding(.bottom)
                    .accessibilityIdentifier(AccessibilityID.eventDetailDescription)
                
                Text("Участники: \(event.attendees.count)")
                    .font(.system(size: 16, weight: .medium))
                    .accessibilityIdentifier(AccessibilityID.eventDetailAttendeesCount)

                Spacer()

                Button(action: processRegistration) {
                    HStack {
                        if isRegistering {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 5)
                            Text(event.isRegistered ? "Отменяем регистрацию..." : "Регистрация...")
                                .font(.system(size: 18, weight: .semibold))
                        } else {
                            Text(event.isRegistered ? "Вы зарегистрированы" : "Зарегистрироваться")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isRegistering ? Color.gray.opacity(0.7) : (event.isRegistered ? Color.green.opacity(0.8) : accentColor))
                    .cornerRadius(10)
                    .shadow(color: accentColor.opacity(event.isRegistered || isRegistering ? 0 : 0.3), radius: 5, x: 0, y: 3)
                }
                .accessibilityIdentifier(AccessibilityID.registerButton(eventName: event.name))
                .disabled(isRegistering || (event.isRegistered && isEventOver)) 
            }
            .padding()
            .accessibilityIdentifier(AccessibilityID.eventDetailMainVStack)
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
                        .foregroundColor(accentColor)
                }
                .accessibilityIdentifier(AccessibilityID.chatButton(eventName: event.name))
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
        let accent = Color(red: 0.353, green: 0.404, blue: 0.847)
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
                .environment(\.colorScheme, .light)
        }
        NavigationView {
            EventDetailView(event: .constant(sampleRussianEventFuture))
                .previewDisplayName("Детали Текущего События (Темная)")
                .environment(\.colorScheme, .dark)
        }
        NavigationView {
             EventDetailView(event: .constant(sampleRussianEventRegistered))
                .previewDisplayName("Детали Зарегистрированного События")
        }
    }
} 