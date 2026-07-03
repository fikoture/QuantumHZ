import SwiftUI

struct FrequencyInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        Text("About Frequencies")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color("PrimaryColor"))
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                    }
                    
                    // What are Solfeggio Frequencies?
                    InfoCard(
                        icon: "music.note",
                        title: "What are Solfeggio Frequencies?",
                        description: "Solfeggio frequencies are a set of specific tones that are believed to have healing properties. Rooted in ancient history, these frequencies are said to correspond to specific energy centers in the body and can help to balance your mind, body, and spirit."
                    )
                    
                    // How to Use Them
                    InfoCard(
                        icon: "headphones",
                        title: "How to Use Them",
                        description: "For the best experience, listen to these frequencies with headphones in a quiet environment. You can use them during meditation, while relaxing, or even as background sound while working or studying. Consistency is key, so try to incorporate them into your daily routine."
                    )
                    
                    // Important Note
                    InfoCard(
                        icon: "exclamationmark.triangle.fill",
                        title: "Important Note",
                        description: "The benefits of Solfeggio frequencies are based on anecdotal evidence and are not a substitute for professional medical advice. If you have any health concerns, please consult with a healthcare provider."
                    )
                }
                .padding()
            }
        }
    }
}

#Preview {
    FrequencyInfoView()
} 