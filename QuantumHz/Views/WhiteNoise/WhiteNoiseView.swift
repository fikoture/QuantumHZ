import SwiftUI
import AVFoundation

struct WhiteNoiseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSound: String = "White Noise"
    @State private var isPlaying: Bool = false
    @State private var volume: Float = 0.5
    
    private let sounds = ["White Noise", "Rain", "Ocean Waves", "Forest", "Fireplace"]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("White Noise")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(sounds, id: \.self) { sound in
                            SoundButton(
                                title: sound,
                                isSelected: selectedSound == sound,
                                action: { selectedSound = sound }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                HStack {
                    Button(action: { isPlaying.toggle() }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Slider(value: $volume, in: 0...1)
                        .accentColor(.white)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct SoundButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .font(.headline)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
            .cornerRadius(10)
        }
    }
}

#Preview {
    WhiteNoiseView()
} 