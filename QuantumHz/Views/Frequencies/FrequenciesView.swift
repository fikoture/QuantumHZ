import SwiftUI
import AVFoundation

struct Frequency: Identifiable {
    let id = UUID()
    let hz: Int
    let note: String
    let title: String
    let description: String
    let icon: String
}

class AudioPlayer {
    private var audioPlayer: AVAudioPlayer?
    private var currentFrequency: Int?
    var onError: ((String) -> Void)?

    deinit {
        // Automatically stop the player when the view is dismissed
        self.stop()
    }

    func play(frequency: Int, volume: Float) {
        // Get the filename based on frequency
        let filename: String
        switch frequency {
        case 111: filename = "111"
        case 174: filename = "174"
        case 285: filename = "285"
        case 396: filename = "396"
        case 417: filename = "417"
        case 432: filename = "432"
        case 528: filename = "528"
        case 639: filename = "639"
        case 741: filename = "741"
        case 852: filename = "852"
        default: return
        }

        // Get the URL for the audio file
        guard let url = AudioResourceLocator.url(forResource: filename, withExtension: "mp3") else {
            let message = "Could not find audio file: \(filename).mp3"
            print(message)
            onError?(message)
            return
        }

        do {
            // Configure audio session
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            // Create and configure audio player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1 // Infinite loop
            audioPlayer?.volume = volume
            audioPlayer?.play()
            currentFrequency = frequency

            print("Playing frequency: \(frequency) Hz")
        } catch {
            let message = "Error playing audio: \(error.localizedDescription)"
            print(message)
            onError?(message)
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentFrequency = nil
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error deactivating audio session: \(error.localizedDescription)")
        }
    }
    
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
}

struct AudioVisualizer: View {
    let frequency: Int
    @State private var barHeights: [CGFloat] = Array(repeating: 0.3, count: 20)
    @State private var isAnimating = false
    
    private var animationSpeed: Double {
        // Higher frequencies animate faster
        return 1.0 / Double(frequency) * 0.5
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<20) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("AccentColor"),
                                Color("PrimaryColor")
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 4, height: barHeights[index] * 80)
                    .animation(
                        Animation.easeInOut(duration: animationSpeed)
                            .repeatForever()
                            .delay(Double(index) * 0.05),
                        value: barHeights[index]
                    )
            }
        }
        .frame(height: 80)
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            isAnimating = false
        }
    }
    
    private func startAnimation() {
        isAnimating = true
        
        func updateBars() {
            guard isAnimating else { return }
            
            for i in 0..<barHeights.count {
                barHeights[i] = CGFloat.random(in: 0.2...1.0)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed) {
                updateBars()
            }
        }
        
        updateBars()
    }
}

struct FrequenciesView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userService: UserService
    @State private var selectedFrequency: Frequency?
    @State private var volume: Float = 0.5
    @State private var showDescription: Bool = false
    @State private var remainingTime: Int = 600
    @State private var timer: Timer?
    @State private var showInfo = false
    @State private var isBackButtonPressed = false
    @State private var animateBackground = false
    @State private var showPremiumSheet = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    private let audioPlayer = AudioPlayer()
    
    private let frequencies = [
        Frequency(hz: 111, note: "Low", title: "Cell Regeneration", 
                 description: "This frequency is believed to have effects on cell renewal and strengthening the immune system. It has a calming effect and facilitates meditation.",
                 icon: "leaf"),
        Frequency(hz: 174, note: "Low", title: "Pain Relief",
                 description: "Benefits: Pain and stress relief, supporting physical and energetic healing, acting as a natural anesthetic. Promotes healing by giving organs a sense of security and love.",
                 icon: "heart.text.square"),
        Frequency(hz: 285, note: "Low", title: "Tissue Healing",
                 description: "Benefits: Supporting tissue and organ healing, renewing and reorganizing energy fields, helping cells return to their original state. Promotes rapid healing of injuries (burns, fractures, sprains, etc.).",
                 icon: "bandage"),
        Frequency(hz: 396, note: "Ut", title: "Fear Release",
                 description: "Benefits: Helps release fear and guilt. Reduces anxiety and worry by resolving negative energy blockages, supporting feelings of confidence and peace.",
                 icon: "heart.circle"),
        Frequency(hz: 417, note: "Re", title: "Change & Trauma Resolution",
                 description: "Benefits: Encourages acceptance of change, release from traumatic experiences, and clearing negative energies from the past. Believed to dissolve crystallized emotional patterns.",
                 icon: "arrow.triangle.2.circlepath"),
        Frequency(hz: 432, note: "Natural", title: "Natural Harmony",
                 description: "Benefits: Considered to be in harmony with nature. Has deep calming and soothing effects. Said to slow heart rate and fill the mind with feelings of peace and well-being. Ideal for yoga, light exercise, meditation, or sleep.",
                 icon: "leaf.circle"),
        Frequency(hz: 528, note: "Mi", title: "Love & Miracle Frequency",
                 description: "Benefits: Believed to support DNA repair, heal cells, and increase inner peace. Associated with raising love and harmony energy. Said to reduce stress and trigger positive transformations.",
                 icon: "heart.fill"),
        Frequency(hz: 639, note: "Fa", title: "Relationship Harmony",
                 description: "Benefits: Believed to help deepen relationships, strengthen bonds, forgiveness, and enhance empathy. Promotes harmonious relationships through understanding, tolerance, and love.",
                 icon: "link.circle"),
        Frequency(hz: 741, note: "Sol", title: "Mental Clarity",
                 description: "Benefits: Believed to support mental clarity, self-expression, detoxification of the body, and intuitive awakening. May enhance problem-solving abilities and creativity.",
                 icon: "brain.head.profile"),
        Frequency(hz: 852, note: "La", title: "Intuitive Power",
                 description: "Benefits: Believed to strengthen intuition, support spiritual awakening, clear negative subconscious patterns, and help reach a higher level of consciousness. Facilitates return to spiritual order.",
                 icon: "sparkles")
    ]
    
    var body: some View {
        ZStack {
            // Modern animated background with blur
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BackgroundColor"),
                    Color("BackgroundColor").opacity(0.9),
                    Color("BackgroundColor").opacity(0.8),
                    Color("AccentColor").opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .blur(radius: animateBackground ? 30 : 0)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateBackground)
            
            // Content
            VStack(spacing: 20) {
                // Header with glass effect
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                    .glassEffect()
                    
                    Spacer()
                    
                    Text("Frequencies")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("PrimaryColor"), Color("AccentColor")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Spacer()
                    
                    Button(action: { showInfo.toggle() }) {
                        Image(systemName: "info")
                            .font(.headline)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                    .glassEffect()
                }
                .padding(.horizontal)
                .padding(.vertical)
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(frequencies) { frequency in
                            FrequencyCard(
                                frequency: frequency,
                                isSelected: selectedFrequency?.id == frequency.id,
                                isPlaying: audioPlayer.isPlaying && selectedFrequency?.id == frequency.id,
                                isPremium: frequency.hz > 285,
                                userIsPremium: userService.isPremium()
                            )
                            .onTapGesture {
                                handleFrequencyTap(frequency)
                            }
                        }
                    }
                    .padding()
                }
                
                if let selectedFrequency = selectedFrequency {
                    // Player controls with glass effect
                    VStack(spacing: 16) {
                        // Frequency info
                        VStack(alignment: .center, spacing: 8) {
                            Text("\(selectedFrequency.hz) Hz")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(selectedFrequency.title)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Audio visualizer
                        if audioPlayer.isPlaying {
                            AudioVisualizer(frequency: selectedFrequency.hz)
                                .frame(height: 60)
                        }
                        
                        // Volume slider
                        HStack {
                            Image(systemName: "speaker.fill")
                                .foregroundColor(.white)
                            
                            Slider(value: $volume, in: 0...1) { _ in
                                audioPlayer.setVolume(volume)
                            }
                            .accentColor(Color("PrimaryColor"))
                            
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        
                        // Play/Stop button
                        Button(action: {
                            if audioPlayer.isPlaying {
                                audioPlayer.stop()
                            } else {
                                audioPlayer.play(frequency: selectedFrequency.hz, volume: volume)
                            }
                        }) {
                            Image(systemName: audioPlayer.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                .font(.system(size: 54))
                                .foregroundColor(Color("PrimaryColor"))
                        }
                    }
                    .padding()
                    .glassCard()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.spring(), value: selectedFrequency?.id)
        .onAppear {
            animateBackground = true
            audioPlayer.onError = { message in
                errorMessage = message
                showErrorAlert = true
            }
        }
        .sheet(isPresented: $showInfo) {
            FrequencyInfoView()
                .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumView()
                .preferredColorScheme(.dark)
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func handleFrequencyTap(_ frequency: Frequency) {
        if frequency.hz > 285 && !userService.isPremium() {
            showPremiumSheet = true
            return
        }
        
        if selectedFrequency?.id == frequency.id {
            // Deselect and stop if the same frequency is tapped again
            selectedFrequency = nil
            audioPlayer.stop()
        } else {
            selectedFrequency = frequency
            audioPlayer.play(frequency: frequency.hz, volume: volume)
        }
    }
}

struct FrequencyCard: View {
    let frequency: Frequency
    let isSelected: Bool
    let isPlaying: Bool
    let isPremium: Bool
    let userIsPremium: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Spacer()
            
            Image(systemName: frequency.icon)
                .font(.title)
                .foregroundColor(isSelected ? Color("PrimaryColor") : .white)
                .frame(height: 30)
            
            Spacer()
            
            Text("\(frequency.hz) Hz")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(frequency.title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Playing indicator
            if isPlaying {
                LinearGradient(
                    gradient: Gradient(colors: [Color("PrimaryColor"), Color("AccentColor")]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 3)
                .clipShape(Capsule())
            } else {
                Color.clear.frame(height: 3)
            }
        }
        .padding(12)
        .frame(height: 150)
        .background(AppTheme.Colors.glassBackground)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color("PrimaryColor") : AppTheme.Colors.glassBorder,
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
                
                if isPremium && !userIsPremium {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                        .foregroundColor(Color("AccentColor"))
                        .padding(6)
                        .background(Color.black.opacity(0.3).clipShape(Circle()))
                        .padding(8)
                }
            }
        )
        .shadow(color: AppTheme.Colors.glassShadow, radius: 10, x: 0, y: 5)
        .opacity(isPremium && !userIsPremium ? 0.7 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

#Preview {
    FrequenciesView()
        .environmentObject(UserService.shared)
}
