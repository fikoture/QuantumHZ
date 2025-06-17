import Foundation
import SwiftUI

class UserService: ObservableObject {
    static let shared = UserService()
    
    @Published private(set) var currentUser: User
    
    private init() {
        self.currentUser = User()
    }
    
    func setUser(_ user: User) {
        currentUser = user
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
        objectWillChange.send()
    }
} 