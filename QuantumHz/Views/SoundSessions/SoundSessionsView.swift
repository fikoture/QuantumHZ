import SwiftUI

struct SoundSessionsView: View {
    @Environment(\.dismiss) private var dismiss
    
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
                
                Image(systemName: "headphones")
                    .font(.system(size: 60))
                    .foregroundColor(Color("AccentColor"))
                
                Text("Create or join meditative sound loops")
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SoundSessionsView()
} 