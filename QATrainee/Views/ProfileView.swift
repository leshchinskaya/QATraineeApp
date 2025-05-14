import SwiftUI

// UserProfile struct is now in Models/UserProfile.swift

struct ProfileView: View {
    @State private var userProfile: UserProfile?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Загрузка профиля...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("Ошибка: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                } else if let profile = userProfile {
                    Form {
                        Section(header: Text("Основная информация")) {
                            ProfileRow(label: "ID", value: profile.id)
                            ProfileRow(label: "Имя", value: profile.firstName ?? "Не указано")
                            ProfileRow(label: "Фамилия", value: profile.lastName ?? "Не указано")
                        }
                        
                        Section(header: Text("Контактная информация")) {
                            ProfileRow(label: "Email", value: profile.email ?? "Не указан")
                            ProfileRow(label: "Телефон", value: profile.phone ?? "Не указан")
                        }
                        
                        Section(header: Text("Дополнительная информация")) {
                            ProfileRow(label: "Дата рождения", value: profile.displayBirthday)
                            ProfileRow(label: "Пол", value: profile.displaySex)
                        }
                    }
                } else {
                    Text("Профиль не загружен.")
                        .padding()
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
                    }
                    .disabled(isLoading)
                    .accessibilityIdentifier("refreshProfileButton")
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

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

#Preview {
    ProfileView()
} 