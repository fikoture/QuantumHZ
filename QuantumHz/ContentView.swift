import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject private var userService: UserService
    @State private var isMusicPlaying = true
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isShowingInfo = false
    @State private var isShowingPremiumSheet = false
    @State private var animateBackground = false
    
    // Navigation states
    @State private var showMeditation = false
    @State private var showWhiteNoise = false
    @State private var showFrequencies = false
    @State private var showSoundSessions = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern background with animated gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("BackgroundColor"),
                        Color("BackgroundColor").opacity(0.8),
                        Color("AccentColor").opacity(0.2)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .blur(radius: animateBackground ? 30 : 0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateBackground)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        headerView
                            .padding(.top, 20)
                        
                        // Feature cards
                        LazyVGrid(columns: columns, spacing: 20) {
                            featureCards
                        }
                        .padding(.horizontal)
                        
                        // Premium status card
                        premiumStatusCard
                            .padding()
                        
                    }
                }
                .navigationBarHidden(true)
            }
            .onAppear {
                setupAudioPlayer()
                animateBackground = true
            }
            .fullScreenCover(isPresented: $showMeditation) { MeditationView() }
            .fullScreenCover(isPresented: $showWhiteNoise) { WhiteNoiseView() }
            .fullScreenCover(isPresented: $showFrequencies) { FrequenciesView() }
            .fullScreenCover(isPresented: $showSoundSessions) { SoundSessionsView() }
            .sheet(isPresented: $isShowingPremiumSheet) { PremiumView().preferredColorScheme(.dark) }
            .sheet(isPresented: $isShowingInfo) { InfoView().preferredColorScheme(.dark) }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var headerView: some View {
        HStack {
            // Info Button
            Button(action: { isShowingInfo.toggle() }) {
                Image(systemName: "info")
                    .font(.headline)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            }
            .glassEffect()
            
            Spacer()
            
            // Title
            VStack {
                Text("QuantumHz")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("PrimaryColor"), Color("AccentColor")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Your Frequency Oasis")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Mute/Unmute Button
            Button(action: {
                isMusicPlaying.toggle()
                if isMusicPlaying {
                    audioPlayer?.play()
                } else {
                    audioPlayer?.pause()
                }
            }) {
                Image(systemName: isMusicPlaying ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.headline)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            }
            .glassEffect()
        }
        .padding(.horizontal)
    }
    
    private var featureCards: some View {
        Group {
            FeatureCardButton(
                icon: "waveform.path.ecg",
                title: "Frequencies",
                description: "Explore Solfeggio frequencies.",
                action: { showFrequencies = true }
            )
            FeatureCardButton(
                icon: "headphones",
                title: "Meditation Timer",
                description: "Guided meditation sessions.",
                action: { showMeditation = true }
            )
            FeatureCardButton(
                icon: "mic.fill",
                title: "Sound Sessions",
                description: "Record your own affirmations.",
                action: { showSoundSessions = true }
            )
            FeatureCardButton(
                icon: "speaker.fill",
                title: "White Noise",
                description: "Relaxing ambient sounds.",
                action: { showWhiteNoise = true }
            )
        }
    }
    
    private var premiumStatusCard: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: userService.isPremium() ? "crown.fill" : "crown")
                    .font(.title)
                    .foregroundColor(userService.isPremium() ? Color("AccentColor") : .white)
                
                Text(userService.isPremium() ? "Premium User" : "Standard User")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if !userService.isPremium() {
                    Button(action: { isShowingPremiumSheet = true }) {
                        Text("Upgrade")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("AccentColor"))
                            .clipShape(Capsule())
                    }
                }
            }
            
            if !userService.isPremium() {
                Text("Upgrade to unlock all frequencies and features!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .glassCard()
    }
    
    private func setupAudioPlayer() {
        guard audioPlayer == nil, let url = AudioResourceLocator.url(forResource: "MainMusic", withExtension: "mp3") else {
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 0.5
            if isMusicPlaying {
                audioPlayer?.play()
            }
        } catch {
            print("Error setting up audio player: \(error.localizedDescription)")
        }
    }
}

struct FeatureCardButton: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    let cardHeight: CGFloat = 180
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 10) {
                HStack {
                    Spacer()
                    Image(systemName: icon)
                        .font(.largeTitle)
                        .foregroundColor(Color("PrimaryColor"))
                    Spacer()
                }
                
                Spacer()
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true) // Prevents word breaking in title
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical:true)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(height: cardHeight)
            .glassCard()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserService.shared)
}

