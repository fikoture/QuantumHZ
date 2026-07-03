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
    @EnvironmentObject private var userService: UserService
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
    @State private var showPremiumSheet = false
    
    private let durations = [5, 10, 15]
    private let sounds = [
        ("Rain", "cloud.rain"),
        ("Forest", "leaf"),
        ("Ocean", "water.waves"),
        ("Radio", "radio")
    ]
    
    private let columns = [
        GridItem(.adaptive(minimum: 60, maximum: 70), spacing: 10)
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
                blackoutView
            } else {
                mainMeditationView
            }
        }
        .alert("Turn off screen?", isPresented: $showBlackoutConfirmation) {
            Button("Yes") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isScreenBlackedOut = true
                    startClockTimer()
                }
            }
            Button("No", role: .cancel) {}
        } message: {
            Text("This will turn off the screen to save power and reduce distractions. You can turn it back on at any time.")
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumView()
        }
    }
    
    private var mainMeditationView: some View {
        VStack(spacing: 20) {
            headerView
            
            timerDisplayView
            
            controlPanelView
            
            Spacer(minLength: 15)
            
            startButton
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                audioPlayer?.stop()
                AudioPlayerManager.shared.stop()
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .glassEffect()
            
            Spacer()
            
            Text("Meditation Timer")
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
            
            Button(action: { 
                showBlackoutConfirmation = true
                if !isScreenBlackedOut {
                    startClockTimer() // Start timer only when screen is about to black out
                }
            }) {
                Image(systemName: "eye.slash")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .glassEffect()
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    private var blackoutView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            if isMeditating {
                Text(timeString(from: TimeInterval(remainingTime)))
                    .font(.system(size: 64, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                
                Text("Time Remaining")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
            } else {
                Text(timeString(from: currentTime))
                    .font(.system(size: 64, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                
                Text("The time is now")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isScreenBlackedOut = false
                    stopClockTimer()
                }
            }) {
                Text("Show Screen")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .glassEffect()
        }
        .padding(.bottom, 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9))
        .ignoresSafeArea()
        .transition(.opacity)
    }
    
    private var timerDisplayView: some View {
        let progress = isMeditating ? Double(remainingTime) / Double(max(1, selectedDuration * 60)) : 1.0

        return ZStack {
            Circle()
                .stroke(lineWidth: 18)
                .opacity(0.1)
                .foregroundColor(.white)

            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(style: .init(lineWidth: 18, lineCap: .round, lineJoin: .round))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("PrimaryColor"), Color("AccentColor")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: progress)
            
            VStack(spacing: 5) {
                Text(isMeditating ? timeString(from: TimeInterval(remainingTime)) : timeString(from: TimeInterval(selectedDuration * 60)))
                    .font(.system(size: 48, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                
                Text(isMeditating ? "Time Remaining" : "Set Duration")
                    .font(.headline)
                    .textCase(.uppercase)
                    .kerning(1.1)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(width: 220, height: 220)
        .padding(.vertical, 20)
    }
    
    private var controlPanelView: some View {
        VStack(spacing: 20) {
            // Sound Selection
            VStack(spacing: 12) {
                Text("Background Sound")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(sounds, id: \.0) { sound in
                        SoundCell(
                            soundName: sound.0,
                            iconName: sound.1,
                            isSelected: selectedSound == sound.0,
                            action: {
                                withAnimation(.spring()) {
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
                            }
                        )
                    }
                }
            }
            .padding(.bottom, 15)
            
            // Duration Selection
            VStack(spacing: 12) {
                Text("Duration (minutes)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 12) {
                    ForEach(durations, id: \.self) { duration in
                        let isDisabled = !userService.isPremium() && duration != 5
                        
                        DurationButton(
                            duration: duration,
                            isSelected: selectedDuration == duration && !isCustomDurationActive,
                            isDisabled: isDisabled,
                            action: {
                                if isDisabled {
                                    showPremiumSheet = true
                                } else {
                                    withAnimation(.spring()) {
                                        selectedDuration = duration
                                        isCustomDurationActive = false
                                    }
                                }
                            }
                        )
                    }
                    
                    customDurationButton
                }
                
                if !userService.isPremium() {
                    Button(action: { showPremiumSheet = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(Color("AccentColor"))
                            Text("Unlock custom and more durations with Premium")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
        .glassCard()
    }
    
    private var startButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                if isMeditating {
                    stopMeditation()
                } else {
                    startMeditation()
                }
            }
        }) {
            Text(isMeditating ? "Stop Meditation" : "Start Meditation")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(isMeditating ? Color.red : Color("PrimaryColor"))
                .clipShape(Capsule())
                .shadow(color: (isMeditating ? Color.red : Color("PrimaryColor")).opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
    
    private var customDurationButton: some View {
        let isDisabled = !userService.isPremium()
        
        return Button(action: {
            if isDisabled {
                showPremiumSheet = true
            } else {
                showCustomDurationAlert = true
            }
        }) {
            Image(systemName: "plus")
                .font(.headline)
                .foregroundColor(isCustomDurationActive ? .white : .white.opacity(0.8))
                .frame(width: 44, height: 44)
                .background(
                    ZStack {
                        if isCustomDurationActive {
                            LinearGradient(
                                colors: [Color("PrimaryColor"), Color("AccentColor")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            Color.white.opacity(0.1)
                        }
                    }
                )
                .clipShape(Circle())
                .overlay(
                    isDisabled ?
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .overlay(Image(systemName: "lock.fill").foregroundColor(.white.opacity(0.7)))
                        : nil
                )
        }
        .disabled(isDisabled)
        .shadow(
            color: !isDisabled ? Color("AccentColor").opacity(0.6) : .clear,
            radius: 8, x: 0, y: 4
        )
        .alert("Custom Duration", isPresented: $showCustomDurationAlert) {
            TextField("Minutes", text: $customDuration)
                .keyboardType(.numberPad)
            Button("Set") {
                if let duration = Int(customDuration), duration > 0 {
                    selectedDuration = duration
                    isCustomDurationActive = true
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func playSound(soundName: String) {
        if soundName == "Radio" { return } // Radio is handled by AudioPlayerManager
        
        guard let url = Bundle.main.url(forResource: soundName.lowercased(), withExtension: "mp3") else {
            print("Could not find sound file: \(soundName.lowercased()).mp3")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Could not play sound: \(error.localizedDescription)")
        }
    }
    
    private func startMeditation() {
        isMeditating = true
        remainingTime = selectedDuration * 60
        playSound(soundName: selectedSound)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                stopMeditation()
            }
        }
    }
    
    private func stopMeditation() {
        isMeditating = false
        timer?.invalidate()
        timer = nil
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    private func playRadio() {
        guard let url = URL(string: radioStreamURL) else { return }
        AudioPlayerManager.shared.playStream(url: url)
        isRadioPlaying = true
    }
    
    private func startClockTimer() {
        currentTime = Date()
        clockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func stopClockTimer() {
        clockTimer?.invalidate()
        clockTimer = nil
    }
    
    private func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct SoundCell: View {
    let soundName: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.title3)
                Text(soundName)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
            .background(
                ZStack {
                    if isSelected {
                        LinearGradient(
                            colors: [Color("PrimaryColor"), Color("AccentColor")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.white.opacity(0.1)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct DurationButton: View {
    let duration: Int
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(duration)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                .frame(width: 44, height: 44)
                .background(
                    ZStack {
                        if isSelected {
                            LinearGradient(
                                colors: [Color("PrimaryColor"), Color("AccentColor")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            Color.white.opacity(0.1)
                        }
                    }
                )
                .clipShape(Circle())
                .overlay(
                    isDisabled ?
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .overlay(Image(systemName: "lock.fill").foregroundColor(.white.opacity(0.7)))
                        : nil
                )
        }
        .disabled(isDisabled)
    }
}

struct YouTubeView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)") else {
            return webView
        }
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
    MeditationView()
        .environmentObject(UserService.shared)
}
