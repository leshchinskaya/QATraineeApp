import SwiftUI
import SharedAccessibilityIDs

struct EventDetailView: View {
    @Binding var event: Event
    @State private var showRegistrationAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Статус регистрации"
    
    @State private var isRegistering = false 

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
                    .font(AppFonts.largeTitleBold)
                    .foregroundColor(AppColors.textPrimary)
                    .accessibilityIdentifier(AccessibilityID.eventDetailTitle(eventName: event.name))

                Text("Организатор: \(event.organizer)")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.accent)
                    .accessibilityIdentifier(AccessibilityID.eventDetailOrganizer(organizerName: event.organizer))

                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(AppColors.accent)
                    Text("\(event.date, formatter: dateFormatterWithLocaleBug)")
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.textPrimary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier(AccessibilityID.eventDetailDate)

                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(AppColors.accent)
                    Text(event.city)
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.textPrimary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier(AccessibilityID.eventDetailCity(cityName: event.city))

                HStack(spacing: 8) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(AppColors.accent)
                    Text(event.category)
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.textPrimary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier(AccessibilityID.eventDetailCategory(categoryName: event.category))

                Text("Об этом событии:")
                    .font(AppFonts.largeTitleBold)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.top)
                
                Text(event.description)
                    .font(AppFonts.bodyRegular)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.bottom)
                    .accessibilityIdentifier(AccessibilityID.eventDetailDescription)
                
                Text("Участники: \(event.attendees.count)")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textPrimary)
                    .accessibilityIdentifier(AccessibilityID.eventDetailAttendeesCount)

                Spacer()

                Button(action: processRegistration) {
                    HStack {
                        if isRegistering {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 5)
                            Text(event.isRegistered ? "Отменяем регистрацию..." : "Регистрация...")
                                .font(AppFonts.button)
                        } else {
                            Text(event.isRegistered ? "Вы зарегистрированы" : "Зарегистрироваться")
                                .font(AppFonts.button)
                        }
                    }
                    .foregroundColor(AppColors.textWhite)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isRegistering ? AppColors.textSecondary.opacity(0.5) : (event.isRegistered ? AppColors.positive.opacity(0.8) : AppColors.accent))
                    .cornerRadius(10)
                    .shadow(color: AppColors.accent.opacity(event.isRegistered || isRegistering ? 0 : 0.3), radius: 5, x: 0, y: 3)
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
                        .foregroundColor(AppColors.accent)
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