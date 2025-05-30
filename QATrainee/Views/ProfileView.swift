import SwiftUI
import SharedAccessibilityIDs

// UserProfile struct is now in Models/UserProfile.swift

struct ProfileView: View {
    @State private var userProfile: UserProfile?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView {
                        Text("Загрузка профиля...")
                            .font(AppFonts.bodyRegular)
                            .foregroundColor(AppColors.textSecondary)
                    }
                        .tint(AppColors.accent)
                        .accessibilityIdentifier(AccessibilityID.profileLoadingIndicator)
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("Ошибка: \(errorMessage)")
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.destructive)
                        .accessibilityIdentifier(AccessibilityID.profileErrorMessageText)
                        .padding()
                        .multilineTextAlignment(.center)
                } else if let profile = userProfile {
                    Form {
                        Section(header: Text("Основная информация")
                                    .font(AppFonts.formSectionHeader)
                                    .foregroundColor(AppColors.textPrimary)) {
                            ProfileRow(label: "ID", value: profile.id, identifierLabel: "ID")
                            ProfileRow(label: "Имя", value: profile.firstName ?? "Не указано")
                            ProfileRow(label: "Фамилия", value: profile.lastName ?? "Не указано")
                        }
                        
                        Section(header: Text("Контактная информация")
                                    .font(AppFonts.formSectionHeader)
                                    .foregroundColor(AppColors.textPrimary)) {
                            ProfileRow(label: "Email", value: profile.email ?? "Не указан")
                            ProfileRow(label: "Телефон", value: profile.phone ?? "Не указан")
                        }
                        
                        Section(header: Text("Дополнительная информация")
                                    .font(AppFonts.formSectionHeader)
                                    .foregroundColor(AppColors.textPrimary)) {
                            ProfileRow(label: "Дата рождения", value: profile.displayBirthday)
                            ProfileRow(label: "Пол", value: profile.displaySex)
                        }
                    }
                    .accessibilityIdentifier(AccessibilityID.profileForm)
                } else {
                    Text("Профиль не загружен.")
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.textSecondary)
                        .padding()
                        .accessibilityIdentifier(AccessibilityID.profileNotLoadedText)
                }
            }
            .navigationTitle("Профиль")
            .onAppear {
                fetchUserProfileData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: fetchUserProfileData) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppColors.accent)
                    }
                    .disabled(isLoading)
                    .accessibilityIdentifier(AccessibilityID.refreshProfileButton)
                }
            }
        }
    }

    func fetchUserProfileData() {
        isLoading = true
        errorMessage = nil
        
        // Call the NetworkService (to be implemented/updated)
        NetworkService.shared.fetchUserProfile { result in
            isLoading = false
            switch result {
            case .success(let profile):
                self.userProfile = profile
            case .failure(let error):
                self.errorMessage = "Не удалось загрузить профиль: \(error.localizedDescription)"
                self.userProfile = nil // Clear old data on error
            }
        }
    }
}

struct ProfileRow: View {
    let label: String
    let value: String
    var identifierLabel: String? // For simpler identifiers if needed, defaults to label

    var body: some View {
        HStack {
            Text(label)
                .font(AppFonts.bodyRegular)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(AppFonts.bodyRegular)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
        // Use a sanitized version of the label for the identifier
        .accessibilityIdentifier(AccessibilityID.profileRow(label: identifierLabel ?? label))
    }
}

#Preview {
    ProfileView()
} 