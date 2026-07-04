import Foundation
import SwiftUI

class UserService: ObservableObject {
    static let shared = UserService()

    private static let userDefaultsKey = "com.quantumhz.currentUser"

    @Published private(set) var currentUser: User

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.userDefaultsKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = savedUser
        } else {
            self.currentUser = User()
        }
    }

    func setUser(_ user: User) {
        currentUser = user
        persist()
        objectWillChange.send()
    }

    func getCurrentUser() -> User {
        return currentUser
    }

    func isPremium() -> Bool {
        return currentUser.isPremium
    }

    func updatePremiumStatus(_ isPremium: Bool) {
        currentUser.isPremium = isPremium
        persist()
        objectWillChange.send()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        }
    }
}