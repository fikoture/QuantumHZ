import Foundation

struct User: Identifiable, Codable {
    let id: String
    var isPremium: Bool
    var name: String
    
    init(id: String = UUID().uuidString, isPremium: Bool = false, name: String = "") {
        self.id = id
        self.isPremium = isPremium
        self.name = name
    }
} 