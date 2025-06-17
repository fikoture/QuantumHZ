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
        case 963: filename = "963"
        default: return
        }
        
        // Get the URL for the audio file
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("Could not find audio file: \(filename).mp3")
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
            print("Error playing audio: \(error.localizedDescription)")
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
    @State private var selectedFrequency: Frequency?
    @State private var volume: Float = 0.5
    @State private var showDescription: Bool = false
    @State private var isScreenBlackedOut = false
    @State private var remainingTime: Int = 600 // 10 minutes in seconds
    @State private var timer: Timer?
    @State private var showInfo: Bool = false
    @State private var isBackButtonPressed = false
    
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
                 icon: "sparkles"),
        Frequency(hz: 963, note: "Si", title: "Cosmic Healing",
                 description: "Benefits: Believed to activate the pineal gland, perform aura cleansing, and strengthen the individual's connection with the spiritual world. Facilitates connection with universal energy and provides inner peace and clarity.",
                 icon: "sun.max")
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BackgroundColor"),
                    Color("AccentColor")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isBackButtonPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isBackButtonPressed = false
                                dismiss()
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.2),
                                                Color.white.opacity(0.1)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .scaleEffect(isBackButtonPressed ? 0.9 : 1.0)
                    .shadow(
                        color: isBackButtonPressed ? Color("AccentColor").opacity(0.3) : Color.black.opacity(0.2),
                        radius: isBackButtonPressed ? 4 : 2,
                        x: 0,
                        y: isBackButtonPressed ? 2 : 1
                    )
                    
                    Spacer()
                    
                    Text("Solfeggio Frequencies")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color("AccentColor").opacity(0.3), radius: 2, x: 0, y: 2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Spacer()
                    
                    Button(action: {
                        showInfo = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.2),
                                                Color.white.opacity(0.1)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Frequency Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 15),
                        GridItem(.flexible(), spacing: 15)
                    ], spacing: 15) {
                        ForEach(frequencies) { frequency in
                            FrequencyButton(frequency: frequency) {
                                selectedFrequency = frequency
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .fullScreenCover(item: $selectedFrequency) { frequency in
            FrequencyDetailView(frequency: frequency)
        }
        .sheet(isPresented: $showInfo) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        
                        Text("What Are Solfeggio Frequencies?")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            showInfo = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.2),
                                                    Color.white.opacity(0.1)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("Solfeggio frequencies are ancient sound tones believed to have existed for thousands of years, based on specific mathematical patterns. While modern scientific research has not yet provided conclusive evidence about the effects of these frequencies, there is a widespread belief that listening to these frequencies supports mental, emotional, physical, and spiritual well-being.")
                        .foregroundColor(.white.opacity(0.9))
                    
                    Group {
                        Text("Emotional and Mental Balance:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("• Stress and Anxiety Reduction: Many frequencies are thought to have calming and relaxing effects, which may help reduce stress and anxiety.\n• Clearing Emotional Blockages: Certain frequencies (e.g., 396 Hz) are believed to help resolve negative emotional patterns such as fear and guilt.\n• Mental Clarity and Focus: By calming the mind and reducing distractions, they may enhance concentration and mental clarity.")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Group {
                        Text("Physical Healing and Health:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("• Cellular Repair and Renewal: The 528 Hz frequency, in particular, is associated with 'DNA repair' and is believed to support healing at the cellular level.\n• Pain Reduction: Some low frequencies (e.g., 174 Hz) are believed to have analgesic and soothing effects.\n• Immune System Support: There are claims that certain frequencies help strengthen the immune system.")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Group {
                        Text("Spiritual Growth and Awakening:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("• Intuition and Wisdom Development: Higher frequencies (e.g., 852 Hz) are believed to enhance intuitive abilities and inner wisdom.\n• Spiritual Connection: Frequencies like 963 Hz are thought to strengthen the individual's connection with higher consciousness or universal energy.\n• Awareness and Meditation Depth: These frequencies may help deepen meditation practices and facilitate easier access to deeper states.")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Group {
                        Text("Relationships and Harmony:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Frequencies like 639 Hz are believed to strengthen relationships by promoting love, understanding, and empathy in interpersonal connections.")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Text("Important Note: The benefits of Solfeggio frequencies are generally based on anecdotal evidence, traditional beliefs, and personal experiences. There is limited definitive clinical evidence widely accepted by modern Western medicine or scientific research. These frequencies should not replace medical treatments or professional support. However, many people experience that listening to these sounds contributes to their overall well-being and relaxation.")
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top)
                }
                .padding()
            }
            .background(Color("BackgroundColor"))
        }
    }
}

struct FrequencyButton: View {
    let frequency: Frequency
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                    action()
                }
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: frequency.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 45, height: 45)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color("AccentColor"),
                                        Color("PrimaryColor")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: Color("AccentColor").opacity(0.3),
                           radius: 6, x: 0, y: 3)
                
                VStack(spacing: 2) {
                    Text("\(frequency.hz) Hz")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(frequency.note)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: isPressed ? Color("AccentColor").opacity(0.3) : Color.black.opacity(0.2),
                radius: isPressed ? 6 : 3,
                x: 0,
                y: isPressed ? 3 : 1
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

struct FrequencyDetailView: View {
    let frequency: Frequency
    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = false
    @State private var volume: Float = 0.5
    @State private var remainingTime: Int = 600 // 10 minutes in seconds
    @State private var timer: Timer?
    @State private var isScreenBlackedOut = false
    @State private var showBlackoutConfirmation = false
    private let audioPlayer = AudioPlayer()
    
    private var timeString: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BackgroundColor"),
                    Color("AccentColor")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 15) {
                // Header
                HStack(spacing: 15) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("\(frequency.hz) Hz")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(frequency.note)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Empty view for balance
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Icon
                Image(systemName: frequency.icon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .padding(25)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color("AccentColor"),
                                        Color("PrimaryColor")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: Color("AccentColor").opacity(0.3),
                           radius: 15, x: 0, y: 10)
                
                // Title
                Text(frequency.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Timer Display
                if isPlaying {
                    VStack(spacing: 4) {
                        Text(timeString)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .monospacedDigit()
                        
                        Text("Recommended listening time")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.vertical, 5)
                }
                
                // Wave Animation replaced with Audio Visualizer
                if isPlaying {
                    AudioVisualizer(frequency: frequency.hz)
                        .padding(.vertical, 5)
                }
                
                // Description
                VStack(spacing: 10) {
                    Text(frequency.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.05))
                        )
                    
                    // Warning about minimum listening time
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text("For optimal results, listen to this frequency for at least 10 minutes.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.yellow.opacity(0.1))
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Play/Stop Button
                Button(action: {
                    if isPlaying {
                        audioPlayer.stop()
                        timer?.invalidate()
                        timer = nil
                    } else {
                        audioPlayer.play(frequency: frequency.hz, volume: volume)
                        remainingTime = 600 // Reset to 10 minutes
                        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                            if remainingTime > 0 {
                                remainingTime -= 1
                            } else {
                                timer?.invalidate()
                                timer = nil
                            }
                        }
                    }
                    isPlaying.toggle()
                }) {
                    HStack {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .font(.title2)
                        Text(isPlaying ? "Stop" : "Play")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("AccentColor"),
                                Color("PrimaryColor")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color("AccentColor").opacity(0.3),
                           radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                
                // Volume Control
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "speaker.fill")
                            .foregroundColor(.white.opacity(0.7))
                        Slider(value: Binding(
                            get: { Double(volume) },
                            set: { 
                                volume = Float($0)
                                audioPlayer.setVolume(volume)
                            }
                        ))
                        .accentColor(Color("AccentColor"))
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal)
                }
                
                // Blackout Button
                Button(action: {
                    showBlackoutConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "moon.fill")
                            .font(.title2)
                        Text("Turn Off Screen")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("BackgroundColor"),
                                Color("AccentColor")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color("AccentColor").opacity(0.2),
                           radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.vertical, 20)
        }
        .overlay {
            if isScreenBlackedOut {
                Color.black
                    .ignoresSafeArea()
                    .overlay {
                        VStack(spacing: 40) {
                            Text(timeString)
                                .font(.system(size: 80, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .monospacedDigit()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isScreenBlackedOut = false
                                }
                            }) {
                                VStack(spacing: 15) {
                                    Image(systemName: "hand.tap.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Text("Turn on screen")
                                        .font(.system(size: 24, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 25)
                                .padding(.horizontal, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.white.opacity(0.15))
                                )
                                .padding(.horizontal, 40)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isScreenBlackedOut)
        .navigationBarHidden(true)
        .onDisappear {
            audioPlayer.stop()
            timer?.invalidate()
            timer = nil
        }
        .confirmationDialog(
            "Turn Off Screen",
            isPresented: $showBlackoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Turn Off Screen") {
                isScreenBlackedOut = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The screen will turn off. Tap anywhere to turn it back on.")
        }
    }
}

#Preview {
    FrequenciesView()
} 