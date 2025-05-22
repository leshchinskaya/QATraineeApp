import SwiftUI
import SharedAccessibilityIDs

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
                        LazyVStack(alignment: .leading, spacing: 12) { // Increased spacing
                            ForEach(messages) { message in
                                ChatMessageView(message: message)
                                    .id(message.id)
                                    .accessibilityIdentifier(AccessibilityID.chatMessage(id: message.id))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .accessibilityIdentifier(AccessibilityID.chatMessagesScrollView)
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
                HStack(spacing: 12) { // Added spacing
                    TextField("Введите сообщение...", text: $newMessageText)
                        .accessibilityIdentifier(AccessibilityID.chatMessageTextField)
                        .font(AppFonts.bodyRegular)
                        .textFieldStyle(.plain) // Use plain style for more custom look
                        .padding(10) // Add padding inside textfield
                        .background(AppColors.fillGray6.cornerRadius(10)) // Background for textfield
                        // Bug: No character limit, potential for very long messages
                        .padding(.leading)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32) // Increased size
                            .foregroundColor(newMessageText.isEmpty ? AppColors.textSecondary : AppColors.accent)
                    }
                    .accessibilityIdentifier(AccessibilityID.chatSendMessageButton)
                    .padding(.trailing)
                    // Bug: Button has no padding around the image itself, icon is flush with button edges
                    .disabled(newMessageText.isEmpty) // Basic validation
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 10) // Increased vertical padding for input area
                .background(AppColors.background) // Background for input area
            }
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.bottom)) // Ensure background covers under input area
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
    // Adding avatar placeholder idea - could be an actual image URL later
    var avatarName: String { isCurrentUser ? "person.fill" : "person" }
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) { // Align to bottom, add spacing for avatar
            if !message.isCurrentUser {
                Image(systemName: message.avatarName) // Placeholder avatar
                    .font(.system(size: 28))
                    .foregroundColor(AppColors.textSecondary)
                    .clipShape(Circle())
                Spacer().frame(width: 0) // Ensure avatar is to the left of the bubble
            }
            
            if message.isCurrentUser {
                Spacer() // Push user's messages to the right
            }
            
            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.user)
                    .font(AppFonts.captionBold)
                    .foregroundColor(AppColors.textSecondary)
                Text(message.text)
                    .font(AppFonts.bodyRegular)
                    .padding(12) // Increased padding
                    .background(message.isCurrentUser ? AppColors.accent : AppColors.fillGray5)
                    .foregroundColor(message.isCurrentUser ? AppColors.textWhite : AppColors.textPrimary)
                    .cornerRadius(16) // Increased corner radius for softer bubbles
                    // Bug: Text color on systemGray4 might have low contrast in dark mode / light mode for some users (Now systemGray5 and adaptive text)
            }
            
            if message.isCurrentUser {
                 Spacer().frame(width: 0)
                 Image(systemName: message.avatarName) // Placeholder avatar
                    .font(.system(size: 28))
                    .foregroundColor(AppColors.accent)
                    .clipShape(Circle())
            }
            
            if !message.isCurrentUser && !message.isCurrentUser { // This condition seems wrong, original was Spacer for non-current user
                 Spacer() // Push other users' messages to the left (original logic was this pushes to left)
            } else if message.isCurrentUser { 
                // No spacer here if current user, it's handled by the main Spacer above VStack
            } else { // This is for non-current user, to ensure their bubble isn't full width if there is no avatar on the right
                Spacer()
            }

        }
        .padding(.horizontal, message.isCurrentUser ? 0 : 4) // Slight indent for non-user avatar if needed
    }
}

#Preview {
    ChatView(eventName: "Пример чата события")
} 