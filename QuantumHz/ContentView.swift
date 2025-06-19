import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject private var userService: UserService
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab = 0
    @State private var isShowingOnboarding = true
    @State private var logoScale: CGFloat = 1.0
    @State private var logoRotation: Double = 0.0
    @State private var isMusicPlaying = true
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isShowingInfo = false
    @State private var isShowingPremiumSheet = false
    
    // Navigation states
    @State private var showMeditation = false
    @State private var showWhiteNoise = false
    @State private var showFrequencies = false
    @State private var showSoundSessions = false
    
    @State private var showPremiumPurchaseAlert = false
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Modern background with gradient and effects
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
            
            // Animated background circles with glass effect
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("AccentColor").opacity(0.15),
                                    Color("PrimaryColor").opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 250 + CGFloat(index * 60))
                        .blur(radius: 30)
                        .offset(
                            x: CGFloat.random(in: -150...150),
                            y: CGFloat.random(in: -150...150)
                        )
                        .animation(
                            Animation.easeInOut(duration: 10)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 2),
                            value: UUID()
                        )
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Üstte logo ve başlık
                VStack(spacing: 15) {
                    Image("AppIcon")
                        .resizable()
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(color: Color("AccentColor").opacity(0.4), radius: 20, x: 0, y: 10)
                        .scaleEffect(logoScale)
                        .rotationEffect(.degrees(logoRotation))
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                                logoScale = 1.2
                                logoRotation = 360
                            }
                            setupAudioPlayer()
                        }
                    Text("QuantumHz")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(Color("PrimaryColor"))
                        .shadow(color: Color("AccentColor").opacity(0.3), radius: 2, x: 0, y: 2)
                }
                .padding(.top, 10)
                
                // Üstte info ve ses butonları hizalı
                HStack {
                    Button(action: { isShowingInfo = true }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 32))
                            .foregroundColor(Color("AccentColor"))
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .stroke(Color("PrimaryColor").opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .shadow(color: Color("PrimaryColor").opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    Spacer()
                    Button(action: {
                        if isMusicPlaying {
                            audioPlayer?.pause()
                        } else {
                            if audioPlayer == nil {
                                setupAudioPlayer()
                            } else {
                                audioPlayer?.play()
                            }
                        }
                        isMusicPlaying.toggle()
                    }) {
                        Image(systemName: isMusicPlaying ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color("PrimaryColor"))
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .stroke(Color("PrimaryColor").opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .shadow(color: Color("PrimaryColor").opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Kartlar ve premium statü birlikte scrollable olacak
                ScrollView {
                    VStack(spacing: 20) {
                        LazyVGrid(columns: columns, spacing: 20) {
                            Button(action: {
                                audioPlayer?.stop()
                                audioPlayer = nil
                                isMusicPlaying = false
                                showMeditation = true
                            }) {
                                FeatureCard(
                                    title: "Meditation Timer",
                                    icon: "chart.bar.fill",
                                    description: "Enhance your mindfulness and relax deeply with personalized meditation guidance."
                                )
                            }
                            Button(action: {
                                audioPlayer?.stop()
                                audioPlayer = nil
                                isMusicPlaying = false
                                showWhiteNoise = true
                            }) {
                                FeatureCard(
                                    title: "White Noise",
                                    icon: "waveform.circle.fill",
                                    description: "Relax with soothing sounds and ambient noise"
                                )
                            }
                            Button(action: {
                                audioPlayer?.stop()
                                audioPlayer = nil
                                isMusicPlaying = false
                                showFrequencies = true
                            }) {
                                FeatureCard(
                                    title: "Frequencies",
                                    icon: "waveform.path.ecg",
                                    description: "Explore theta, alpha, beta tones"
                                )
                            }
                            Button(action: {
                                audioPlayer?.stop()
                                audioPlayer = nil
                                isMusicPlaying = false
                                showSoundSessions = true
                            }) {
                                FeatureCard(
                                    title: "Sound Sessions",
                                    icon: "headphones",
                                    description: "Create or join meditative sound loops"
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Premium Status Section (kartların hemen altında)
                        VStack(spacing: 10) {
                            Text("Your Plan")
                                .font(.subheadline)
                                .foregroundColor(Color("SecondaryColor"))
                            Text(userService.isPremium() ? "Premium" : "Free")
                                .font(.title3.bold())
                                .foregroundColor(userService.isPremium() ? .green : .gray)
                            if !userService.isPremium() {
                                Button(action: { isShowingPremiumSheet = true }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.system(size: 18, weight: .bold))
                                        Text("Upgrade to Premium")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 24)
                                    .background(Color("AccentColor"))
                                    .cornerRadius(12)
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: 320)
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color("PrimaryColor").opacity(0.15), lineWidth: 1)
                        )
                        .padding(.bottom, 8)
                    }
                }
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showMeditation) {
            MeditationView()
        }
        .fullScreenCover(isPresented: $showWhiteNoise) {
            WhiteNoiseView()
        }
        .fullScreenCover(isPresented: $showFrequencies) {
            FrequenciesView()
        }
        .fullScreenCover(isPresented: $showSoundSessions) {
            SoundSessionsView()
        }
        .sheet(isPresented: $isShowingInfo) {
            InfoView(isPresented: $isShowingInfo)
        }
        .sheet(isPresented: $isShowingPremiumSheet) {
            ScrollView {
                VStack(spacing: 22) {
                    Text("Compare Plans")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color("PrimaryColor"))
                        .padding(.top, 10)
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Standard")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Divider()
                        FeatureRow(text: "Listen to the first 3 frequencies (111, 174, 285 Hz)", available: true)
                        FeatureRow(text: "Read all frequency details", available: true)
                        FeatureRow(text: "Meditation timer & basic sounds", available: true)
                        FeatureRow(text: "White noise & basic sound sessions", available: true)
                        FeatureRow(text: "Unlimited access to all frequencies", available: false)
                        FeatureRow(text: "Unlimited duration & exclusive sounds", available: false)
                        FeatureRow(text: "Full access to all sound sessions & white noise", available: false)
                        FeatureRow(text: "Upcoming premium features & updates", available: false)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Premium")
                            .font(.headline)
                            .foregroundColor(Color("AccentColor"))
                        Divider()
                        FeatureRow(text: "Listen to all frequencies (no limits)", available: true)
                        FeatureRow(text: "Read all frequency details", available: true)
                        FeatureRow(text: "Meditation timer & basic sounds", available: true)
                        FeatureRow(text: "White noise & all sound sessions", available: true)
                        FeatureRow(text: "Unlimited duration & exclusive sounds", available: true)
                        FeatureRow(text: "Upcoming premium features & updates", available: true)
                    }
                    .padding(14)
                    .background(Color("AccentColor").opacity(0.08))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("AccentColor").opacity(0.18), lineWidth: 1)
                    )
                    HStack(spacing: 16) {
                        Button("Close") {
                            isShowingPremiumSheet = false
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 28)
                        .background(Color("AccentColor"))
                        .cornerRadius(14)
                        Button("Get Premium") {
                            showPremiumPurchaseAlert = true
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 28)
                        .background(Color("PrimaryColor"))
                        .cornerRadius(14)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color("BackgroundColor"), Color("PrimaryColor").opacity(0.08)]),
                    startPoint: .top, endPoint: .bottom)
            )
        }
        .alert(isPresented: $showPremiumPurchaseAlert) {
            Alert(title: Text("Premium Subscription"), message: Text("This is a demo. Integrate your purchase flow here."), dismissButton: .default(Text("OK")))
        }
    }
    
    func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: "MainMusic", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Infinite loop
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isMusicPlaying = true
        } catch {
            print("Error playing background music: \(error.localizedDescription)")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: isIPad ? 30 : 20) {
            ZStack {
                Circle()
                    .fill(ThemeManager.shared.primaryColor.opacity(0.1))
                    .frame(width: isIPad ? 160 : 120, height: isIPad ? 160 : 120)
                    .blur(radius: 10)
                
                Image(systemName: "waveform.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(ThemeManager.shared.primaryColor)
                    .frame(width: isIPad ? 100 : 80, height: isIPad ? 100 : 80)
            }
            
            Text("QuantumHz")
                .font(ThemeManager.shared.titleFont(for: horizontalSizeClass))
                .foregroundColor(ThemeManager.shared.primaryColor)
                .multilineTextAlignment(.center)
            
            Text("Find your focus through frequency.")
                .font(.subheadline)
                .foregroundColor(ThemeManager.shared.secondaryColor)
                .multilineTextAlignment(.center)
        }
    }
    
    private var premiumStatusSection: some View {
        VStack(spacing: 10) {
            Text("Your Plan")
                .font(.subheadline)
                .foregroundColor(ThemeManager.shared.secondaryColor)
            
            Text(userService.isPremium() ? "Premium" : "Free")
                .font(.title3.bold())
                .foregroundColor(userService.isPremium() ? .green : .gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(ThemeManager.shared.cornerRadius(for: horizontalSizeClass))
        .overlay(
            RoundedRectangle(cornerRadius: ThemeManager.shared.cornerRadius(for: horizontalSizeClass))
                .stroke(ThemeManager.shared.primaryColor.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var featuresGrid: some View {
        let columns = [
            GridItem(.adaptive(minimum: isIPad ? 300 : 150), spacing: 20)
        ]
        
        return LazyVGrid(columns: columns, spacing: 20) {
            FeatureCard(title: "Frequencies", icon: "waveform.path.ecg", description: "Explore theta, alpha, beta tones")
            FeatureCard(title: "Sound Sessions", icon: "headphones", description: "Create or join meditative sound loops")
            FeatureCard(title: "Insights", icon: "brain.head.profile", description: "Track focus and clarity over time")
        }
    }
}

struct FeatureCard: View {
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(Color("AccentColor"))
                .frame(width: 50, height: 50)
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryColor"))
                .shadow(color: Color("PrimaryColor").opacity(0.2), radius: 1, x: 0, y: 1)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            Text(description)
                .font(.footnote)
                .foregroundColor(Color("SecondaryColor"))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("PrimaryColor").opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color("PrimaryColor").opacity(0.1), radius: 15, x: 0, y: 8)
    }
}

struct InfoView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("What is QuantumHz?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryColor"))
            
            Text("QuantumHz is an app designed for focus, sleep, and relaxation. By exploring theta, alpha, and beta frequencies, you can optimize your brain waves and achieve a better quality of life.")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Close") {
                isPresented = false
            }
            .padding()
            .background(Color("AccentColor"))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

// Modern feature row for plan comparison
fileprivate struct FeatureRow: View {
    let text: String
    let available: Bool
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: available ? "checkmark.seal.fill" : "xmark.seal")
                .foregroundColor(available ? Color("AccentColor") : .gray)
                .font(.system(size: 18, weight: .semibold))
            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 15, weight: .medium, design: .rounded))
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserService.shared)
}
