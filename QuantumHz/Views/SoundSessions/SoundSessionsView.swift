import SwiftUI
import AVFoundation
import UIKit

struct SoundSessionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showRecordingStudio = false
    @State private var showMeditationSessions = false
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
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
                    
                    Text("Sound Sessions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("PrimaryColor"))
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Voice Recording Studio Card
                        Button(action: {
                            showRecordingStudio = true
                        }) {
                            VStack(spacing: 20) {
                                // Header
                                HStack {
                                    Image(systemName: "mic.circle.fill")
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(Color("AccentColor"))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Voice Recording Studio")
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundColor(Color("PrimaryColor"))
                                        
                                        Text("Record, save & share your voice")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color("PrimaryColor"))
                                        .opacity(0.6)
                                }
                            }
                            .padding(24)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("PrimaryColor").opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color("AccentColor").opacity(0.1), radius: 15, x: 0, y: 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Saved Meditation Recordings Card
                        Button(action: {
                            showMeditationSessions = true
                        }) {
                            VStack(spacing: 20) {
                                // Header
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(Color("AccentColor"))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Meditation Sessions")
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundColor(Color("PrimaryColor"))
                                        
                                        Text("Themed meditation recordings")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color("PrimaryColor"))
                                        .opacity(0.6)
                                }
                            }
                            .padding(24)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("PrimaryColor").opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color("AccentColor").opacity(0.1), radius: 15, x: 0, y: 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showRecordingStudio) {
            VoiceRecordingStudioView()
        }
        .fullScreenCover(isPresented: $showMeditationSessions) {
            MeditationSessionsView()
        }
    }
}

struct RecordingItem: Identifiable {
    let id: UUID
    let name: String
    let url: URL
    let date: Date
}

struct SavedRecordingRow: View {
    let recording: RecordingItem
    let onDelete: () -> Void
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var showDeleteAlert = false
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Play/Pause Button
                Button(action: {
                    if isPlaying {
                        stopPlayback()
                    } else {
                        playRecording()
                    }
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(Color("AccentColor"))
                        .scaleEffect(isPlaying ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isPlaying)
                }
                
                // Recording Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("PrimaryColor"))
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(formatDate(recording.date))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        
                        if let duration = getAudioDuration(url: recording.url) {
                            Text("•")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text(formatDuration(duration))
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 8) {
                    // Share Button
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("AccentColor"))
                            .frame(width: 32, height: 32)
                            .background(Color("AccentColor").opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    // Delete Button
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            
            // Progress Bar (when playing)
            if isPlaying {
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle(tint: Color("AccentColor")))
                    .scaleEffect(y: 0.5)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("PrimaryColor").opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isPlaying ? Color("AccentColor").opacity(0.3) : Color("PrimaryColor").opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
        .alert("Delete Recording", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(recording.name)'? This action cannot be undone.")
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [recording.url])
        }
    }
    
    private func playRecording() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
            audioPlayer?.delegate = AudioPlayerDelegate(isPlaying: $isPlaying)
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Error playing recording: \(error.localizedDescription)")
        }
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func getAudioDuration(url: URL) -> TimeInterval? {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            return audioPlayer.duration > 0 ? audioPlayer.duration : nil
        } catch {
            print("Error getting audio duration: \(error.localizedDescription)")
            return nil
        }
    }
}

// Audio Player Delegate to handle playback completion
class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    @Binding var isPlaying: Bool
    
    init(isPlaying: Binding<Bool>) {
        self._isPlaying = isPlaying
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}

// ShareSheet struct to handle sharing
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Exclude only the most irrelevant activity types
        controller.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList
        ]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct FeaturePreviewItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color("AccentColor"))
                .frame(width: 40, height: 40)
                .background(Color("AccentColor").opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color("PrimaryColor"))
            
            Text(description)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct VoiceRecordingStudioView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordingURL: URL?
    @State private var showRecordingAlert = false
    @State private var recordingName = ""
    @State private var savedRecordings: [RecordingItem] = []
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
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
                    
                    VStack(spacing: 2) {
                        Text("Voice Recording")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color("PrimaryColor"))
                        Text("Studio")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color("PrimaryColor"))
                    }
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 30)
                .background(.ultraThinMaterial)
                
                // Main Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Features Section
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "mic.circle.fill")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(Color("AccentColor"))
                                
                                Text("Voice Recording Studio")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(Color("PrimaryColor"))
                                
                                Spacer()
                                
                                Text("\(savedRecordings.count) saved")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color("PrimaryColor").opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            Text("Record your own voice for meditation, affirmations, or guided sessions. Your recordings are saved locally and can be shared with others.")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.leading)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("PrimaryColor").opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color("AccentColor").opacity(0.1), radius: 15, x: 0, y: 8)
                        
                        // Record Section
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "record.circle")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color("AccentColor"))
                                
                                Text("Record")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color("PrimaryColor"))
                                
                                Spacer()
                                
                                Text("High quality audio")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            // Recording Controls
                            HStack(spacing: 16) {
                                Button(action: {
                                    if isRecording {
                                        stopRecording()
                                    } else {
                                        startRecording()
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                                            .font(.system(size: 20, weight: .semibold))
                                        Text(isRecording ? "Stop Recording" : "Start Recording")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                isRecording ? Color.red : Color("AccentColor"),
                                                isRecording ? Color.red.opacity(0.8) : Color("PrimaryColor")
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: isRecording ? Color.red.opacity(0.3) : Color("AccentColor").opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .disabled(isRecording && audioRecorder == nil)
                                
                                if !isRecording && recordingURL != nil {
                                    Button(action: {
                                        showRecordingAlert = true
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "square.and.arrow.down")
                                                .font(.system(size: 20, weight: .semibold))
                                            Text("Save")
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.green,
                                                    Color.green.opacity(0.8)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(12)
                                        .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                                    }
                                }
                            }
                            
                            // Recording Status
                            if isRecording {
                                HStack {
                                    Image(systemName: "record.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(.red)
                                        .opacity(0.8)
                                    
                                    Text("Recording...")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.red)
                                        .opacity(0.8)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("PrimaryColor").opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color("AccentColor").opacity(0.1), radius: 15, x: 0, y: 8)
                        
                        // Manage Section
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "waveform")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color("AccentColor"))
                                
                                Text("Manage")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color("PrimaryColor"))
                                
                                Spacer()
                                
                                Text("Your recordings")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            if !savedRecordings.isEmpty {
                                ForEach(savedRecordings) { recording in
                                    SavedRecordingRow(recording: recording, onDelete: {
                                        deleteRecording(recording)
                                    })
                                }
                            } else {
                                // Empty State
                                VStack(spacing: 12) {
                                    Image(systemName: "waveform.badge.plus")
                                        .font(.system(size: 30, weight: .light))
                                        .foregroundColor(Color("AccentColor").opacity(0.6))
                                    
                                    Text("No recordings yet")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.vertical, 20)
                            }
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("PrimaryColor").opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color("AccentColor").opacity(0.1), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
        }
        .alert("Save Recording", isPresented: $showRecordingAlert) {
            TextField("Recording name", text: $recordingName)
            Button("Save") {
                saveRecording()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a name for your recording")
        }
        .onAppear {
            setupAudioSession()
        }
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }
    
    private func startRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        recordingURL = audioFilename
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }
    
    private func saveRecording() {
        guard let url = recordingURL, !recordingName.isEmpty else { return }
        
        let newRecording = RecordingItem(
            id: UUID(),
            name: recordingName,
            url: url,
            date: Date()
        )
        
        savedRecordings.append(newRecording)
        recordingName = ""
        recordingURL = nil
    }
    
    private func deleteRecording(_ recording: RecordingItem) {
        // Remove from array
        savedRecordings.removeAll { $0.id == recording.id }
        
        // Delete file from file system
        do {
            try FileManager.default.removeItem(at: recording.url)
            print("Recording deleted successfully: \(recording.name)")
        } catch {
            print("Error deleting recording file: \(error.localizedDescription)")
        }
    }
}

struct MeditationSessionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
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
                    
                    VStack(spacing: 2) {
                        Text("Meditation")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color("PrimaryColor"))
                        Text("Sessions")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color("PrimaryColor"))
                    }
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 30)
                .background(.ultraThinMaterial)
                
                // Main Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Coming Soon Section
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(Color("AccentColor"))
                                
                                Text("Meditation Sessions")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(Color("PrimaryColor"))
                                
                                Spacer()
                            }
                            
                            Text("Themed meditation recordings will be available here soon. Different categories including stress relief, sleep, focus, and more will be added.")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.leading)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("PrimaryColor").opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color("AccentColor").opacity(0.1), radius: 15, x: 0, y: 8)
                        
                        // Placeholder for future content
                        VStack(spacing: 16) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 60, weight: .light))
                                .foregroundColor(Color("AccentColor").opacity(0.6))
                            
                            Text("Coming Soon")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color("PrimaryColor"))
                            
                            Text("Themed meditation sessions will be available here")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("PrimaryColor").opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color("AccentColor").opacity(0.1), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
        }
    }
}

#Preview {
    SoundSessionsView()
} 