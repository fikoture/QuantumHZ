import SwiftUI
import AVFoundation
import UIKit

struct SoundSessionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showRecordingStudio = false
    @State private var showMeditationSessions = false
    
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
                
                // Navigation Cards
                ScrollView {
                    VStack(spacing: 20) {
                        SessionNavigationCard(
                            title: "Voice Recording Studio",
                            description: "Record, save & share your voice",
                            icon: "mic.circle.fill",
                            action: { showRecordingStudio = true }
                        )
                        
                        SessionNavigationCard(
                            title: "Meditation Sessions",
                            description: "Themed meditation recordings",
                            icon: "brain.head.profile",
                            action: { showMeditationSessions = true }
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 20)
        }
        .fullScreenCover(isPresented: $showRecordingStudio) {
            VoiceRecordingStudioView()
        }
        .fullScreenCover(isPresented: $showMeditationSessions) {
            MeditationSessionsView()
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
            
            Text("Sound Sessions")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal)
    }
}

struct SessionNavigationCard: View {
    let title: String
    let description: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(Color("AccentColor"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("PrimaryColor"))
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(Color("PrimaryColor").opacity(0.6))
            }
            .padding()
            .glassCard()
        }
    }
}

// MARK: - Voice Recording Studio
struct VoiceRecordingStudioView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var recordings: [RecordingItem] = []
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                studioHeader
                
                // Recording Controls
                recordingControls
                    .padding()
                    .glassCard()
                
                // Recordings List
                recordingsList
            }
            .padding()
        }
        .onAppear(perform: loadRecordings)
    }
    
    private var studioHeader: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .glassEffect()
            
            Spacer()
            
            Text("Recording Studio")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear.frame(width: 44, height: 44)
        }
    }
    
    private var recordingControls: some View {
        VStack(spacing: 20) {
            Text(audioRecorder.isRecording ? "Recording..." : "Tap to Record")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Button(action: {
                audioRecorder.isRecording ? audioRecorder.stopRecording() : audioRecorder.startRecording()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 70, height: 70)
                        .shadow(color: .red.opacity(0.5), radius: 10)
                    
                    Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
            }
            
            if audioRecorder.isRecording {
                Text(audioRecorder.recordingTime, style: .timer)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private var recordingsList: some View {
        Group {
            if recordings.isEmpty {
                VStack {
                    Spacer()
                    Text("No Recordings Yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Tap the microphone to start your first recording.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                List {
                    ForEach(recordings) { recording in
                        SavedRecordingRow(
                            recording: recording,
                            onDelete: {
                                deleteRecording(url: recording.url)
                            }
                        )
                    }
                    .onDelete(perform: delete)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
        }
    }
    
    private func loadRecordings() {
        recordings = audioRecorder.fetchAllRecordings()
    }
    
    private func deleteRecording(url: URL) {
        audioRecorder.deleteRecording(url: url)
        loadRecordings()
    }
    
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let recording = recordings[index]
            deleteRecording(url: recording.url)
        }
    }
}

// MARK: - Meditation Sessions
struct MeditationSessionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // This would be populated with actual meditation session data
    private let sessions = [
        "Morning Gratitude",
        "Deep Sleep Relaxation",
        "Stress & Anxiety Relief",
        "Focus and Concentration"
    ]
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .glassEffect()
                    
                    Spacer()
                    
                    Text("Meditation Sessions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                
                // Session List
                List {
                    ForEach(sessions, id: \.self) { session in
                        Text(session)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Recording Logic
class AudioRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var recordingTime: Date = Date()
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession
    private var timer: Timer?
    
    init() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
    }
    
    func startRecording() {
        let fileName = getDocumentsDirectory().appendingPathComponent("recording-\(Date().timeIntervalSince1970).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder?.record()
            isRecording = true
            recordingTime = Date()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.recordingTime = Date() // Just to trigger UI update
            }
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        timer?.invalidate()
        timer = nil
    }
    
    func fetchAllRecordings() -> [RecordingItem] {
        let directory = getDocumentsDirectory()
        var recordings: [RecordingItem] = []
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            for file in files.filter({ $0.pathExtension == "m4a" }) {
                let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
                let date = attributes[.creationDate] as? Date ?? Date()
                let name = file.lastPathComponent
                recordings.append(RecordingItem(id: UUID(), name: name, url: file, date: date))
            }
        } catch {
            print("Could not fetch recordings")
        }
        
        return recordings.sorted(by: { $0.date > $1.date })
    }
    
    func deleteRecording(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Could not delete recording")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
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
    @StateObject private var audioPlayer = RecordingPlayer()
    
    var body: some View {
        HStack(spacing: 12) {
            // Play/Pause Button
            Button(action: { audioPlayer.togglePlayback(url: recording.url) }) {
                Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color("AccentColor"))
            }
            
            // Recording Info
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.name)
                    .font(.headline)
                    .foregroundColor(Color("PrimaryColor"))
                    .lineLimit(1)
                
                Text(formatDate(recording.date))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .font(.body)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .glassCard()
        .onDisappear {
            audioPlayer.stopPlayback()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

class RecordingPlayer: ObservableObject {
    @Published var isPlaying = false
    private var audioPlayer: AVAudioPlayer?
    
    func togglePlayback(url: URL) {
        if let player = audioPlayer, player.isPlaying {
            stopPlayback()
        } else {
            playRecording(url: url)
        }
    }
    
    private func playRecording(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Could not play recording.")
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
    }
}

#Preview {
    SoundSessionsView()
} 