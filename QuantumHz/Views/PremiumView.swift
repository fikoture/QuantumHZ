import SwiftUI

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var purchaseService = PurchaseService.shared

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color("AccentColor"))
                        
                        Text("Unlock Your Potential")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color("PrimaryColor"))
                        
                        Text("Upgrade to Premium to access all features and content.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Feature Comparison
                    VStack(spacing: 20) {
                        FeatureSection(title: "Standard", features: [
                            ("Listen to the first 3 frequencies", true),
                            ("Read all frequency details", true),
                            ("Basic meditation timer", true),
                            ("Limited white noise sounds", true),
                            ("Unlimited access to all frequencies", false),
                            ("Exclusive sound sessions", false),
                            ("Download for offline use", false)
                        ], isPremium: false)
                        
                        FeatureSection(title: "Premium", features: [
                            ("Listen to all frequencies", true),
                            ("Read all frequency details", true),
                            ("Advanced meditation timer", true),
                            ("Full library of white noise sounds", true),
                            ("Unlimited access to all frequencies", true),
                            ("Exclusive sound sessions", true),
                            ("Download for offline use", true)
                        ], isPremium: true)
                    }
                    
                    // Call to Action
                    Button(action: {
                        Task {
                            await purchaseService.purchasePremium()
                            if UserService.shared.isPremium() {
                                dismiss()
                            }
                        }
                    }) {
                        Group {
                            if purchaseService.isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Upgrade Now - $4.99/month")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("AccentColor"), Color("PrimaryColor")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color("AccentColor").opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .disabled(purchaseService.isPurchasing)
                    .padding(.top, 10)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Not Now")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .alert("Error", isPresented: Binding(
            get: { purchaseService.errorMessage != nil },
            set: { isPresented in
                if !isPresented { purchaseService.errorMessage = nil }
            }
        )) {
            Button("OK") { }
        } message: {
            Text(purchaseService.errorMessage ?? "")
        }
    }
}

struct FeatureSection: View {
    let title: String
    let features: [(String, Bool)]
    let isPremium: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(isPremium ? Color("AccentColor") : .white)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(features, id: \.0) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: feature.1 ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(feature.1 ? (isPremium ? Color("AccentColor") : .green) : .gray.opacity(0.6))
                        
                        Text(feature.0)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .glassCard()
    }
}

#Preview {
    PremiumView()
} 