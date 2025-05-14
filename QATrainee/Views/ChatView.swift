import SwiftUI

struct ChatView: View {
    var eventName: String?
    
    @State private var messages: [ChatMessage] = [
        ChatMessage(user: "Алиса", text: "Всем привет! Ждете это событие?"),
        ChatMessage(user: "Борис", text: "Конечно! Кто-нибудь знает, легко ли там с парковкой?"),
        ChatMessage(user: "Виктор", text: "В прошлом году пришлось немного пройтись, планируйте заранее!"),
        ChatMessage(user: "Алиса", text: "Спасибо за совет, Виктор!")
    ]
    @State private var newMessageText: String = ""
    
    // Bug: No loading indicator for messages if they were fetched from a server
    // Bug: No pagination or handling for a very large number of messages
    // Bug: Send button might be unresponsive or delayed on slow network (conceptual for now)
    // Bug: Accessibility - messages might not be read out correctly or in order by VoiceOver
    // Bug: UI - Input field and send button styling could be improved (e.g. padding, alignment)

    var body: some View {
        NavigationView {
            VStack {
                // List of messages
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(messages) { message in
                                ChatMessageView(message: message)
                                    .id(message.id)
                                    // Missing accessibility identifier for individual messages
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: messages.count) { _ in
                        // Auto-scroll to the newest message
                        // Bug: Might be janky or not work reliably in all cases
                        if let lastMessage = messages.last {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Message input area
                HStack {
                    TextField("Введите сообщение...", text: $newMessageText)
                        // Missing accessibility identifier
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        // Bug: No character limit, potential for very long messages
                        .padding(.leading)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28) // Slightly too small - design bug
                            .foregroundColor(.blue)
                    }
                    // Missing accessibility identifier
                    .padding(.trailing)
                    // Bug: Button has no padding around the image itself, icon is flush with button edges
                    .disabled(newMessageText.isEmpty) // Basic validation
                }
                .padding(.vertical, 8) // Insufficient padding - design bug
                .background(Color(UIColor.systemGray6)) // Background for input area
            }
            .navigationTitle(eventName != nil ? "Чат: \(eventName!)" : "Чат события")
            .navigationBarTitleDisplayMode(.inline)
        }
        // This view would typically be presented, not directly in a TabView for each event.
        // For the prototype, the tabItem Chat will be a generic chat.
        // The EventDetailView links to a conceptual chat for that specific event.
    }
    
    func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let currentUserMessage = ChatMessage(user: "Вы", text: newMessageText, isCurrentUser: true)
        messages.append(currentUserMessage)
        let capturedNewMessageText = newMessageText // Capture for potential bot context if needed later
        newMessageText = ""
        
        // Simulate sending to a server and receiving a response or echo
        // Bug: No error handling if message fails to send (for the user's own message)
        
        // Now, fetch the bot's response
        // Add a small delay before bot responds to make it feel more natural
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { // 0.75 second delay
            NetworkService.shared.fetchBotMessageResponse { [self] result in // Use weak self if needed for complex capture lists
                switch result {
                case .success(let botServerMessage):
                    let botChatMessage = ChatMessage(user: botServerMessage.user, text: botServerMessage.text, isCurrentUser: false)
                    messages.append(botChatMessage)
                    // Consider adding a UI update or animation if needed here
                case .failure(let error):
                    // Log the error or display a subtle error indicator in the chat, e.g. "Bot is unavailable"
                    print("ChatView: Ошибка при получении ответа от бота: \(error.localizedDescription)")
                    // Optionally, add a local message indicating the bot couldn't respond
                    // let errorBotMessage = ChatMessage(user: "Система", text: "Не удалось получить ответ от Марии.", isCurrentUser: false)
                    // messages.append(errorBotMessage)
                }
            }
        }
    }
}

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let user: String
    let text: String
    var isCurrentUser: Bool = false // To align messages left/right
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isCurrentUser {
                Spacer() // Push user's messages to the right
            }
            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.user)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(message.text)
                    .padding(10)
                    .background(message.isCurrentUser ? Color.blue.opacity(0.7) : Color(UIColor.systemGray4))
                    .foregroundColor(message.isCurrentUser ? .white : .black)
                    .cornerRadius(10)
                    // Bug: Text color on systemGray4 might have low contrast in dark mode / light mode for some users
            }
            if !message.isCurrentUser {
                Spacer() // Push other users' messages to the left
            }
        }
    }
}

#Preview {
    ChatView(eventName: "Пример чата события")
} 