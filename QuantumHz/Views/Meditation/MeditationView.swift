import SwiftUI
import AVFoundation
import WebKit

class AudioPlayerManager: NSObject {
    static let shared = AudioPlayerManager()
    var player: AVPlayer?
    
    func playStream(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        player?.volume = 0.5
    }
    
    func stop() {
        player?.pause()
        player = nil
    }
}

struct MeditationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDuration: Int = 5
    @State private var customDuration: String = ""
    @State private var isCustomDurationActive: Bool = false
    @State private var showCustomDurationAlert: Bool = false
    @State private var customDurationError: String = ""
    @State private var isMeditating: Bool = false
    @State private var remainingTime: Int = 0
    @State private var timer: Timer?
    @State private var selectedSound: String = "Rain"
    @State private var audioPlayer: AVAudioPlayer?
    @State private var navigateToWelcome = false
    @State private var isScreenBlackedOut: Bool = false
    @State private var showBlackoutConfirmation: Bool = false
    @State private var currentTime = Date()
    @State private var clockTimer: Timer?
    @State private var showYouTubePlayer: Bool = false
    @State private var isRadioPlaying = false
    
    private let durations = [5, 10, 15]
    private let sounds = [
        ("Rain", "cloud.rain"),
        ("Forest", "leaf"),
        ("Ocean", "water.waves"),
        ("Radio", "radio")
    ]
    
    private let columns = [
        GridItem(.adaptive(minimum: 70, maximum: 80), spacing: 12)
    ]
    
    // Radio stream URL
    private let radioStreamURL = "https://klassikr.streamabc.net/klr_nqlq9rgbhlx_vasj-mp3-192-7148511?sABC=6850q0np%230%237q8656271475pn2834429o727r9op41q%23&aw_0_1st.playerid=&amsparams=playerid:;skey:1750126764"
    
    var body: some View {
        ZStack {
            // Background gradient
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
            
            if isScreenBlackedOut {
                // Black screen with only clock and turn on button
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack {
                    Spacer()
                        .frame(height: 200)
                    
                    Text(timeString(from: currentTime))
                        .font(.system(size: 44, weight: .thin, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                    
                    Spacer()
                        .frame(height: 40)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isScreenBlackedOut = false
                            stopClockTimer()
                        }
                    }) {
                        Text("Turn on screen")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                    }
                }
            } else {
                // Normal view with all UI elements
                VStack(spacing: 25) {
                    // Title and screen blackout button in same row
                    HStack {
                        Button(action: {
                            audioPlayer?.stop()
                            audioPlayer = nil
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color("PrimaryColor"))
                                .frame(width: 40, height: 40)
                                .background(Color("PrimaryColor").opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("Meditation Timer")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color("PrimaryColor"))
                            .shadow(color: Color("AccentColor").opacity(0.3), radius: 2, x: 0, y: 2)
                        
                        Spacer()
                        
                        Button(action: {
                            showBlackoutConfirmation = true
                        }) {
                            Image(systemName: isScreenBlackedOut ? "eye.slash.fill" : "eye.slash")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color("PrimaryColor"))
                                .frame(width: 40, height: 40)
                                .background(Color("PrimaryColor").opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Sound Selection with glass effect
                    VStack(spacing: 12) {
                        Text("Background Sound")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("SecondaryColor"))
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(sounds, id: \.0) { sound in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        stopMeditation()
                                        remainingTime = selectedDuration * 60
                                        selectedSound = sound.0
                                        if sound.0 == "Radio" {
                                            playRadio()
                                        } else {
                                            AudioPlayerManager.shared.stop()
                                            isRadioPlaying = false
                                        }
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: sound.1)
                                            .font(.system(size: 22, weight: .medium))
                                            .foregroundColor(selectedSound == sound.0 ? .white : Color("PrimaryColor"))
                                        Text(sound.0)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(selectedSound == sound.0 ? .white : Color("PrimaryColor"))
                                    }
                                    .frame(height: 70)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        ZStack {
                                            if selectedSound == sound.0 {
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color("AccentColor"),
                                                        Color("AccentColor").opacity(0.8)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            } else {
                                                Color("PrimaryColor").opacity(0.08)
                                            }
                                            
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    selectedSound == sound.0
                                                    ? Color("AccentColor")
                                                    : Color("PrimaryColor").opacity(0.1),
                                                    lineWidth: selectedSound == sound.0 ? 1.5 : 1
                                                )
                                        }
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(
                                        color: selectedSound == sound.0
                                        ? Color("AccentColor").opacity(0.4)
                                        : Color("PrimaryColor").opacity(0.1),
                                        radius: selectedSound == sound.0 ? 6 : 2,
                                        x: 0,
                                        y: 3
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if selectedSound == "Radio" {
                            Text("Klassik Radio Meditation Channel")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color("SecondaryColor"))
                                .padding(.top, 8)
                        }
                    }
                    
                    // Timer with modern design
                    ZStack {
                        Circle()
                            .stroke(Color("AccentColor").opacity(0.2), lineWidth: 4)
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(remainingTime) / CGFloat(selectedDuration * 60))
                            .stroke(Color("AccentColor"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear, value: remainingTime)
                        
                        VStack(spacing: 5) {
                            Text(timeString(from: remainingTime))
                                .font(.system(size: 44, weight: .thin, design: .rounded))
                                .foregroundColor(Color("PrimaryColor"))
                                .monospacedDigit()
                            
                            Text(isMeditating ? "Meditating" : "Ready")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color("SecondaryColor"))
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Start/Stop Button with animation
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if isMeditating {
                                stopMeditation()
                            } else {
                                startMeditation()
                            }
                        }
                    }) {
                        Image(systemName: isMeditating ? "stop.circle.fill" : "play.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(isMeditating ? Color.red : Color("AccentColor"))
                            .shadow(color: (isMeditating ? Color.red : Color("AccentColor")).opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.bottom, 20)
                    
                    // Duration Selection with modern design
                    VStack(spacing: 15) {
                        Text("Select Duration")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color("PrimaryColor"))
                        
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(durations, id: \.self) { duration in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedDuration = duration
                                        remainingTime = duration * 60
                                        isCustomDurationActive = false
                                    }
                                }) {
                                    Text("\(duration) min")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(selectedDuration == duration && !isCustomDurationActive ? .white : Color("PrimaryColor"))
                                        .frame(height: 50)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            ZStack {
                                                if selectedDuration == duration && !isCustomDurationActive {
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color("AccentColor"),
                                                            Color("AccentColor").opacity(0.8)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                } else {
                                                    Color("PrimaryColor").opacity(0.05)
                                                }
                                            }
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    selectedDuration == duration && !isCustomDurationActive
                                                    ? Color("AccentColor")
                                                    : Color("PrimaryColor").opacity(0.1),
                                                    lineWidth: selectedDuration == duration && !isCustomDurationActive ? 2 : 1
                                                )
                                        )
                                        .shadow(
                                            color: selectedDuration == duration && !isCustomDurationActive
                                            ? Color("AccentColor").opacity(0.3)
                                            : Color("PrimaryColor").opacity(0.05),
                                            radius: selectedDuration == duration && !isCustomDurationActive ? 8 : 4,
                                            x: 0,
                                            y: 4
                                        )
                                }
                            }
                            
                            // Custom Duration Button
                            Button(action: {
                                showCustomDurationAlert = true
                            }) {
                                HStack(spacing: 2) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Custom")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(isCustomDurationActive ? .white : Color("PrimaryColor"))
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(
                                    ZStack {
                                        if isCustomDurationActive {
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color("AccentColor"),
                                                    Color("AccentColor").opacity(0.8)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        } else {
                                            Color("PrimaryColor").opacity(0.05)
                                        }
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            isCustomDurationActive
                                            ? Color("AccentColor")
                                            : Color("PrimaryColor").opacity(0.1),
                                            lineWidth: isCustomDurationActive ? 2 : 1
                                        )
                                )
                                .shadow(
                                    color: isCustomDurationActive
                                    ? Color("AccentColor").opacity(0.3)
                                    : Color("PrimaryColor").opacity(0.05),
                                    radius: isCustomDurationActive ? 8 : 4,
                                    x: 0,
                                    y: 4
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                    .alert("Custom Duration", isPresented: $showCustomDurationAlert) {
                        VStack(spacing: 15) {
                            HStack(spacing: 20) {
                                Button(action: {
                                    if let currentDuration = Int(customDuration) {
                                        if currentDuration > 1 {
                                            customDuration = "\(currentDuration - 1)"
                                        }
                                    } else {
                                        customDuration = "1"
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color("PrimaryColor"))
                                }
                                
                                TextField("Minutes", text: $customDuration)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 32, weight: .medium))
                                    .frame(width: 80)
                                    .padding(.vertical, 8)
                                    .background(Color("PrimaryColor").opacity(0.05))
                                    .cornerRadius(10)
                                
                                Button(action: {
                                    if let currentDuration = Int(customDuration) {
                                        if currentDuration < 120 {
                                            customDuration = "\(currentDuration + 1)"
                                        }
                                    } else {
                                        customDuration = "1"
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color("PrimaryColor"))
                                }
                            }
                            
                            if !customDurationError.isEmpty {
                                Text(customDurationError)
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                            }
                            
                            HStack(spacing: 20) {
                                Button("Cancel", role: .cancel) {
                                    customDuration = ""
                                    customDurationError = ""
                                }
                                .foregroundColor(Color("PrimaryColor"))
                                
                                Button("Set") {
                                    if let duration = Int(customDuration), duration > 0, duration <= 120 {
                                        selectedDuration = duration
                                        remainingTime = duration * 60
                                        isCustomDurationActive = true
                                        customDuration = ""
                                        customDurationError = ""
                                    } else {
                                        customDurationError = "Enter 1-120 minutes"
                                    }
                                }
                                .foregroundColor(Color("AccentColor"))
                            }
                        }
                        .padding()
                    } message: {
                        Text("Adjust meditation duration")
                            .foregroundColor(Color("SecondaryColor"))
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .confirmationDialog(
            "Turn off screen?",
            isPresented: $showBlackoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Turn off screen") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isScreenBlackedOut = true
                    startClockTimer()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The screen will turn black. Press the button to turn it back on.")
        }
        .onDisappear {
            stopMeditation()
            stopClockTimer()
            audioPlayer?.stop()
            audioPlayer = nil
        }
    }
    
    private func startMeditation() {
        isMeditating = true
        if remainingTime == 0 {
            remainingTime = selectedDuration * 60
        }
        playSelectedSound()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                stopMeditation()
                playCompletionSound()
            }
        }
    }
    
    private func stopMeditation() {
        isMeditating = false
        timer?.invalidate()
        timer = nil
        audioPlayer?.stop()
        AudioPlayerManager.shared.player?.pause()
        AudioPlayerManager.shared.player = nil
        isRadioPlaying = false
    }
    
    private func playSelectedSound() {
        audioPlayer?.stop()
        AudioPlayerManager.shared.player?.pause()
        AudioPlayerManager.shared.player = nil
        isRadioPlaying = false
        
        guard selectedSound != "None" else { return }
        
        if selectedSound == "Radio" {
            playRadio()
        } else {
            // Get the correct filename based on selection
            let fileName = selectedSound.lowercased()
            
            // Try to load the audio file
            if let soundURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
                print("Found \(fileName).mp3 at: \(soundURL)")
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                    audioPlayer?.volume = 0.5 // Set volume to 50%
                    audioPlayer?.prepareToPlay() // Prepare the audio player
                    let success = audioPlayer?.play() ?? false
                    print("Audio playback started: \(success)")
                } catch {
                    print("Error playing sound: \(error.localizedDescription)")
                }
            } else {
                print("Could not find \(fileName).mp3 in the bundle")
                // Print the bundle path for debugging
                if let bundlePath = Bundle.main.resourcePath {
                    print("Bundle path: \(bundlePath)")
                }
            }
        }
    }
    
    private func playCompletionSound() {
        if let soundURL = Bundle.main.url(forResource: "completion", withExtension: "mp3") {
            do {
                let player = try AVAudioPlayer(contentsOf: soundURL)
                player.play()
            } catch {
                print("Error playing completion sound: \(error.localizedDescription)")
            }
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    private func startClockTimer() {
        clockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func stopClockTimer() {
        clockTimer?.invalidate()
        clockTimer = nil
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func playRadio() {
        guard let url = URL(string: radioStreamURL) else {
            print("Invalid radio stream URL")
            return
        }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            
            let playerItem = AVPlayerItem(url: url)
            AudioPlayerManager.shared.player = AVPlayer(playerItem: playerItem)
            AudioPlayerManager.shared.player?.play()
            AudioPlayerManager.shared.player?.volume = 0.5
            isRadioPlaying = true
        } catch {
            print("Error playing radio stream: \(error.localizedDescription)")
        }
    }
}

struct YouTubePlayerView: View {
    let videoID: String
    
    var body: some View {
        WebView(videoID: videoID)
            .edgesIgnoringSafeArea(.all)
    }
}

struct WebView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1&autoplay=1") else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct MeditationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MeditationView()
                .preferredColorScheme(.dark)
                .environment(\.colorScheme, .dark)
        }
        NavigationView {
            MeditationView()
                .preferredColorScheme(.light)
                .environment(\.colorScheme, .light)
        }
    }
}
