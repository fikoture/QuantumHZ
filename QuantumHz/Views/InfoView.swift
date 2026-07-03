import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        Text("About QuantumHz")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color("PrimaryColor"))
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                    }
                    
                    // What is QuantumHz?
                    InfoCard(
                        icon: "waveform.path.ecg",
                        title: "What is QuantumHz?",
                        description: "QuantumHz is a sound therapy application designed to help you achieve mental, emotional, and physical well-being through the power of sound frequencies. Explore a library of Solfeggio frequencies, white noise, and guided meditations to enhance your focus, relaxation, and overall health."
                    )
                    
                    // How does it help?
                    InfoCard(
                        icon: "sparkles",
                        title: "How Can It Help?",
                        description: "Sound frequencies can have a profound impact on your body and mind. By listening to specific tones, you can stimulate cell regeneration, relieve pain, reduce stress, release emotional blockages, and enhance your spiritual connection. Our app provides a curated collection of sounds to support your personal growth and wellness journey."
                    )
                    
                    // Features
                    InfoCard(
                        icon: "headphones",
                        title: "App Features",
                        description: "• Solfeggio Frequencies: A full range of healing tones.\n• Meditation Timer: Customizable sessions for mindfulness.\n• White Noise: A library of ambient sounds for relaxation.\n• Sound Sessions: Record and listen to your own affirmations.\n• Premium Content: Unlock exclusive sounds and features with a premium subscription."
                    )
                }
                .padding()
            }
        }
    }
}

#Preview {
    InfoView()
} 