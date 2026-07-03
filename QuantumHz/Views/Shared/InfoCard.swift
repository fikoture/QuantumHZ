import SwiftUI

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(Color("AccentColor"))
                
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color("PrimaryColor"))
            }
            
            Text(description)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding()
        .glassCard()
    }
}

#Preview {
    InfoCard(icon: "info.circle", title: "Test Title", description: "This is a test description for the info card.")
        .padding()
        .background(Color("BackgroundColor"))
} 