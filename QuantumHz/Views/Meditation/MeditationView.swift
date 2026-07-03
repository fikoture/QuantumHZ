import SwiftUI
import AVFoundation
import WebKit

// MARK: - Audio Manager
class AudioPlayerManager: NSObject {
    static let shared = AudioPlayerManager()
    var player: AVPlayer?
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }
    }
    
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

// MARK: - Constants
struct MeditationConstants {
    static let defaultDurations = [5, 10, 15]
    static let sounds: [(name: String, icon: String)] = [
        ("Rain", "cloud.rain"),
        ("Forest", "leaf"),
        ("Ocean", "water.waves"),
        ("Radio", "radio")
    ]
    static let timerUpdateInterval: TimeInterval = 1.0
    static let radioVolume: Float = 0.5
    static let minCustomDuration = 1
    static let maxCustomDuration = 180
    static let gridColumns = [GridItem(.adaptive(minimum: 60, maximum: 70), spacing: 10)]
    static let cornerRadius: CGFloat = 16
    static let timerDisplaySize: CGFloat = 220
    static let startStopButtonSize: CGFloat = 70
    static let animationDuration = 0.3
}

// MARK: - Main View
struct MeditationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userService: UserService
    
    // MARK: State Variables
    @State private var selectedDuration: Int = 5
    @State private var customDuration: String = ""
    @State private var isCustomDurationActive: Bool = false
    @State private var showCustomDurationAlert: Bool = false
    @State private var isMeditating: Bool = false
    @State private var remainingTime: Int = 0
    @State private var timer: Timer?
    @State private var selectedSound: String = "Rain"
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isScreenBlackedOut: Bool = false
    @State private var showBlackoutConfirmation: Bool = false
    @State private var currentTime = Date()
    @State private var clockTimer: Timer?
    @State private var isRadioPlaying = false
    @State private var showPremiumSheet = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
    // Configuration
    private let radioStreamURL = "https://klassikr.streamabc.net/klr_nqlq9rgbhlx_vasj-mp3-192-7148511?sABC=6850q0np%230%237q8656271475pn2834429o727r9op41q%23&aw_0_1st.playerid=&amsparams=playerid:placeholder"
    
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
                withAnimation(.easeInOut(duration: MeditationConstants.animationDuration)) {
                    isScreenBlackedOut = true
                    startClockTimer()
                }
            }
            Button("No", role: .cancel) {}
        } message: {
            Text("This will turn off the screen to save power and reduce distractions. You can turn it back on at any time.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumView()
        }
        .onDisappear {
            cleanupResources()
        }
    }
    
    // MARK: - Main Views
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
            Button(action: handleBackButton) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .glassEffect()
            .accessibilityLabel("Go back")
            
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
                    startClockTimer()
                }
            }) {
                Image(systemName: "eye.slash")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .glassEffect()
            .accessibilityLabel(isScreenBlackedOut ? "Turn screen on" : "Turn screen off")
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
                    .accessibilityLabel("Time remaining: \(timeString(from: TimeInterval(remainingTime)))")
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
                withAnimation(.easeInOut(duration: MeditationConstants.animationDuration)) {
                    isScreenBlackedOut = false
                    stopClockTimer()
                }
            }) {
                Text("Show Screen")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .glassEffect()
            .accessibilityLabel("Show screen")
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
            .accessibilityLabel("Timer: \(timeString(from: TimeInterval(isMeditating ? remainingTime : selectedDuration * 60)))")
        }
        .frame(width: MeditationConstants.timerDisplaySize, height: MeditationConstants.timerDisplaySize)
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
                
                LazyVGrid(columns: MeditationConstants.gridColumns, spacing: 10) {
                    ForEach(MeditationConstants.sounds, id: \.name) { sound in
                        SoundCell(
                            soundName: sound.name,
                            iconName: sound.icon,
                            isSelected: selectedSound == sound.name,
                            action: {
                                handleSoundSelection(sound.name)
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
                    ForEach(MeditationConstants.defaultDurations, id: \.self) { duration in
                        let isDisabled = !userService.isPremium() && duration != 5
                        
                        DurationButton(
                            duration: duration,
                            isSelected: selectedDuration == duration && !isCustomDurationActive,
                            isDisabled: isDisabled,
                            action: {
                                handleDurationSelection(duration, isDisabled: isDisabled)
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
        .accessibilityLabel(isMeditating ? "Stop meditation" : "Start meditation")
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
                validateAndSetCustomDuration()
            }
            Button("Cancel", role: .cancel) { }
        }
        .accessibilityLabel("Add custom duration")
    }
    
    // MARK: - Action Handlers
    private func handleBackButton() {
        cleanupResources()
        dismiss()
    }
    
    private func handleSoundSelection(_ soundName: String) {
        withAnimation(.spring()) {
            stopMeditation()
            remainingTime = selectedDuration * 60
            selectedSound = soundName
            if soundName == "Radio" {
                playRadio()
            } else {
                AudioPlayerManager.shared.stop()
                isRadioPlaying = false
            }
        }
    }
    
    private func handleDurationSelection(_ duration: Int, isDisabled: Bool) {
        if isDisabled {
            showPremiumSheet = true
        } else {
            withAnimation(.spring()) {
                selectedDuration = duration
                isCustomDurationActive = false
                remainingTime = duration * 60
            }
        }
    }
    
    private func validateAndSetCustomDuration() {
        guard !customDuration.isEmpty else { return }
        
        if let duration = Int(customDuration) {
            if duration >= MeditationConstants.minCustomDuration && duration <= MeditationConstants.maxCustomDuration {
                selectedDuration = duration
                isCustomDurationActive = true
                remainingTime = duration * 60
                customDuration = ""
            } else {
                showError("Duration must be between \(MeditationConstants.minCustomDuration) and \(MeditationConstants.maxCustomDuration) minutes")
            }
        } else {
            showError("Please enter a valid number")
        }
    }
    
    // MARK: - Audio & Playback
    private func playSound(soundName: String) {
        if soundName == "Radio" { return }
        
        guard let url = Bundle.main.url(forResource: soundName.lowercased(), withExtension: "mp3") else {
            showError("Could not find sound file: \(soundName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            showError("Could not play sound: \(error.localizedDescription)")
        }
    }
    
    private func playRadio() {
        guard let url = URL(string: radioStreamURL) else {
            showError("Invalid radio stream URL")
            return
        }
        AudioPlayerManager.shared.playStream(url: url)
        isRadioPlaying = true
    }
    
    // MARK: - Meditation Control
    private func startMeditation() {
        isMeditating = true
        remainingTime = selectedDuration * 60
        playSound(soundName: selectedSound)
        
        timer = Timer.scheduledTimer(withTimeInterval: MeditationConstants.timerUpdateInterval, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                stopMeditation()
            }
        }
    }
    
    private func stopMeditation() {
        isMeditating = false
        invalidateTimer()
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Screen Blackout
    private func startClockTimer() {
        currentTime = Date()
        clockTimer = Timer.scheduledTimer(withTimeInterval: MeditationConstants.timerUpdateInterval, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func stopClockTimer() {
        clockTimer?.invalidate()
        clockTimer = nil
    }
    
    // MARK: - Utilities
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
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
    
    private func cleanupResources() {
        stopMeditation()
        stopClockTimer()
        AudioPlayerManager.shared.stop()
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

// MARK: - Subviews
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
        .accessibilityLabel(soundName)
        .accessibilityHint(isSelected ? "Currently selected" : "")
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
        .accessibilityLabel("\(duration) minutes")
        .accessibilityHint(isDisabled ? "Premium required" : (isSelected ? "Selected" : ""))
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
