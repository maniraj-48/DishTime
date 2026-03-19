import SwiftUI

struct SplashView: View {
    
    // Controls how full the loading bar is (0 = empty, 1 = full)
    @State private var progress: CGFloat = 0.0
    
    // Controls when to switch to the next screen
    @State private var isFinished = false
    
    var body: some View {
        
        // If loading is done, go to HomeView
        // If not, show the splash screen
        if isFinished {
            LoginView()
        } else {
            splashContent
        }
    }
    
    // MARK: - Main Splash Content
    var splashContent: some View {
        ZStack {
            
            // ── Background ──
            Color("AppBackground")
                .ignoresSafeArea()
            
            // Food image at bottom (faded)
            VStack {
                Spacer()
                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .opacity(0.08)
                    .clipped()
            }
            .ignoresSafeArea()
            
            // ── Main Content ──
            VStack(spacing: 20) {
                
                Spacer()
                
                // App Logo Circle
                ZStack {
                    Circle()
                        .fill(Color("AppOrange").opacity(0.15))
                        .frame(width: 110, height: 110)
                    
                    Circle()
                        .stroke(Color("AppOrange").opacity(0.3), lineWidth: 1.5)
                        .frame(width: 110, height: 110)
                    
                    // Fork and knife icon
                    HStack(spacing: 6) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(Color("AppOrange"))
                        
                        // Clock icon
                        ZStack {
                            Circle()
                                .fill(Color("AppOrange"))
                                .frame(width: 28, height: 28)
                            Image(systemName: "clock.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // App Name
                Text("DishTime")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(Color("AppDark"))
                
                // Tagline
                Text("Find the Best Dish, Not Just the Restaurant.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color("AppDark").opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // ── Loading Bar Section ──
                VStack(spacing: 8) {
                    
                    // Loading bar background
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("AppOrange").opacity(0.2))
                            .frame(width: 200, height: 4)
                        
                        // Orange fill that grows
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("AppOrange"))
                            .frame(width: 200 * progress, height: 4)
                            .animation(.easeInOut(duration: 2.0), value: progress)
                    }
                    
                    // Loading text
                    Text("CRAFTING YOUR MENU...")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color("AppOrange"))
                        .tracking(1.5)
                }
                .padding(.bottom, 60)
            }
        }
        // When screen appears, start the animation
        .onAppear {
            progress = 1.0       // Bar fills up over 2 seconds
            
            // After 2.5 seconds, go to next screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                isFinished = true
            }
        }
    }
}

#Preview {
    SplashView()
}
