var body: some View {
    NavigationStack {
        ZStack {
            // Background
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title and Screen Blackout Toggle
                HStack {
                    NavigationLink(destination: ContentView()) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("PrimaryColor"))
                            .frame(width: 40, height: 40)
                            .background(Color("PrimaryColor").opacity(0.1))
                            .clipShape(Circle())
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        audioPlayer?.stop()
                        audioPlayer = nil
                    })
                    
                    Spacer()
                    
                    Text("Meditation Timer")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("PrimaryColor"))
                    
                    Spacer()
                    
                    Button(action: {
                        isScreenBlackedOut.toggle()
                    }) {
                        Image(systemName: isScreenBlackedOut ? "lightbulb.fill" : "lightbulb")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("PrimaryColor"))
                            .frame(width: 40, height: 40)
                            .background(Color("PrimaryColor").opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)

                // Rest of the view content
                // Sound Selection with modern design
                VStack(spacing: 15) {
                    Text("Background Sound")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color("PrimaryColor"))
                    
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(sounds, id: \.0) { sound in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    stopMeditation()
                                    remainingTime = selectedDuration * 60
                                    selectedSound = sound.0
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: sound.1)
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(selectedSound == sound.0 ? .white : Color("PrimaryColor"))
                                    Text(sound.0)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(selectedSound == sound.0 ? .white : Color("PrimaryColor"))
                                }
                                .frame(height: 80)
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
                                            Color("PrimaryColor").opacity(0.05)
                                        }
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            selectedSound == sound.0
                                            ? Color("AccentColor")
                                            : Color("PrimaryColor").opacity(0.1),
                                            lineWidth: selectedSound == sound.0 ? 2 : 1
                                        )
                                )
                                .shadow(
                                    color: selectedSound == sound.0
                                    ? Color("AccentColor").opacity(0.3)
                                    : Color("PrimaryColor").opacity(0.05),
                                    radius: selectedSound == sound.0 ? 8 : 4,
                                    x: 0,
                                    y: 4
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
                
                Spacer()
                
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
                                }
                            }) {
                                Text("\(duration) min")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(selectedDuration == duration ? .white : Color("PrimaryColor"))
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        ZStack {
                                            if selectedDuration == duration {
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
                                                selectedDuration == duration
                                                ? Color("AccentColor")
                                                : Color("PrimaryColor").opacity(0.1),
                                                lineWidth: selectedDuration == duration ? 2 : 1
                                            )
                                    )
                                    .shadow(
                                        color: selectedDuration == duration
                                        ? Color("AccentColor").opacity(0.3)
                                        : Color("PrimaryColor").opacity(0.05),
                                        radius: selectedDuration == duration ? 8 : 4,
                                        x: 0,
                                        y: 4
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
        }
    }
} 