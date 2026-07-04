import SwiftUI
import AVFoundation

struct WhiteNoiseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioManager = WhiteNoiseAudioManager()
    
    private let sounds: [WhiteNoiseSound] = [
        .init(name: "Rain", icon: "cloud.rain.fill", fileName: "rain"),
        .init(name: "Forest", icon: "leaf.fill", fileName: "forest"),
        .init(name: "Ocean", icon: "water.waves", fileName: "ocean"),
        .init(name: "Zen", icon: "yin.yang", fileName: "zen")
    ]
    
    private let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BackgroundColor"),
                    Color("BackgroundColor").opacity(0.8),
                    Color("AccentColor").opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                headerView
                
                // Sound Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(sounds) { sound in
                            SoundCard(
                                sound: sound,
                                isPlaying: audioManager.currentlyPlaying?.fileName == sound.fileName,
                                action: {
                                    audioManager.toggleSound(sound)
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                // Volume Control
                if audioManager.isPlaying {
                    volumeControlView
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
            .padding(.top, 20)
        }
        .onDisappear {
            audioManager.stopAllSounds()
        }
        .alert("Error", isPresented: Binding(
            get: { audioManager.errorMessage != nil },
            set: { isPresented in
                if !isPresented { audioManager.errorMessage = nil }
            }
        )) {
            Button("OK") { }
        } message: {
            Text(audioManager.errorMessage ?? "")
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .glassEffect()
            
            Spacer()
            
            Text("White Noise")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            // Placeholder for right-side button if needed
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal)
    }
    
    private var volumeControlView: some View {
        HStack(spacing: 15) {
            Image(systemName: "speaker.wave.2.fill")
                .foregroundColor(.white.opacity(0.8))
            
            Slider(value: $audioManager.volume, in: 0...1)
                .accentColor(Color("PrimaryColor"))
        }
        .padding()
        .glassCard()
    }
}

struct SoundCard: View {
    let sound: WhiteNoiseSound
    let isPlaying: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                Image(systemName: sound.icon)
                    .font(.system(size: 40))
                    .foregroundColor(isPlaying ? .white : Color("PrimaryColor"))
                
                Text(sound.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isPlaying ? .white : .white.opacity(0.8))
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 150)
            .background(
                Group {
                    if isPlaying {
                        Color("PrimaryColor")
                    } else {
                        Color.clear
                    }
                }
            )
            .glassCard()
        }
        .scaleEffect(isPlaying ? 1.05 : 1.0)
        .animation(.spring(), value: isPlaying)
    }
}

struct WhiteNoiseSound: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let fileName: String
}

class WhiteNoiseAudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var volume: Float = 0.5 {
        didSet {
            player?.volume = volume
        }
    }
    @Published var currentlyPlaying: WhiteNoiseSound?
    @Published var errorMessage: String?

    private var player: AVAudioPlayer?

    func toggleSound(_ sound: WhiteNoiseSound) {
        if currentlyPlaying?.id == sound.id {
            // Stop the currently playing sound
            stopAllSounds()
        } else {
            // Play the new sound
            playSound(sound)
        }
    }

    private func playSound(_ sound: WhiteNoiseSound) {
        guard let url = AudioResourceLocator.url(forResource: sound.fileName, withExtension: "mp3") else {
            errorMessage = "Could not find sound file: \(sound.fileName).mp3"
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = volume
            player?.play()

            isPlaying = true
            currentlyPlaying = sound
        } catch {
            errorMessage = "Failed to play sound: \(error.localizedDescription)"
            stopAllSounds()
        }
    }
    
    func stopAllSounds() {
        player?.stop()
        player = nil
        isPlaying = false
        currentlyPlaying = nil
    }
}

#Preview {
    WhiteNoiseView()
} 