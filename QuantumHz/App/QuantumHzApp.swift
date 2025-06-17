import SwiftUI

@main
struct QuantumHzApp: App {
    @StateObject private var userService = UserService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userService)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserService.shared)
} 