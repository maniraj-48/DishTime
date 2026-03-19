import SwiftUI

// LoginView.swift
// Purpose: Existing users log in here with email/password or Google
// Navigates to HomeView on success, or SignUpView for new users

struct LoginView: View {
    
    @State private var email = ""           // Stores typed email
    @State private var password = ""        // Stores typed password
    @State private var showPassword = false // Toggles password visibility
    @State private var goToHome = false     // Triggers navigation to HomeView
    @State private var goToSignUp = false   // Triggers navigation to SignUpView
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        // ── Top Food Image Banner ──
                        foodBanner
                        
                        // ── Form Content ──
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // Title
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Welcome Back")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color("AppDark"))
                                Text("Log in to your account to continue your culinary journey")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            // ── Email Field ──
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email Address")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color("AppDark"))
                                
                                HStack {
                                    TextField("email@example.com", text: $email)
                                        .font(.system(size: 15))
                                        .keyboardType(.emailAddress)        // Shows email keyboard
                                        .autocapitalization(.none)          // No auto caps for email
                                    Image(systemName: "envelope")
                                        .foregroundColor(.gray)
                                }
                                .padding(14)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                                )
                            }
                            
                            // ── Password Field ──
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Password")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color("AppDark"))
                                    Spacer()
                                    Button("Forgot Password?") { }
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color("AppOrange"))
                                }
                                
                                HStack {
                                    // Switches between secure and visible text
                                    if showPassword {
                                        TextField("Enter your password", text: $password)
                                            .font(.system(size: 15))
                                    } else {
                                        SecureField("Enter your password", text: $password)
                                            .font(.system(size: 15))
                                    }
                                    
                                    // Eye icon to show/hide password
                                    Button {
                                        showPassword.toggle()
                                    } label: {
                                        Image(systemName: showPassword ? "eye.slash" : "eye")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(14)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                                )
                            }
                            
                            // ── Login Button ──
                            Button {
                                goToHome = true     // For now just navigate — real auth comes later
                            } label: {
                                HStack(spacing: 8) {
                                    Text("Log In")
                                        .font(.system(size: 16, weight: .semibold))
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 16))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("AppOrange"))
                                .cornerRadius(14)
                            }
                            
                            // ── OR Divider ──
                            HStack {
                                Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                                Text("OR")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                                Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                            }
                            
                            // ── Continue with Google ──
                            Button { } label: {
                                HStack(spacing: 10) {
                                    // Google "G" icon placeholder
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 24, height: 24)
                                        Text("G")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color.blue)
                                    }
                                    Text("Continue with Google")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color("AppDark"))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            
                            // ── Sign Up Link ──
                            HStack {
                                Spacer()
                                Text("Don't have an account?")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Button("Sign Up") {
                                    goToSignUp = true
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color("AppOrange"))
                                Spacer()
                            }
                            .padding(.bottom, 30)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 28)
                    }
                }
            }
            .navigationBarHidden(true)
            // Navigate to Home when logged in
            .navigationDestination(isPresented: $goToHome) {
                HomeView()
            }
            // Navigate to Sign Up
            .navigationDestination(isPresented: $goToSignUp) {
                SignUpView()
            }
        }
    }
    
    // MARK: - Food Banner
    // Purpose: Decorative food image at the top of login screen
    var foodBanner: some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.2, green: 0.5, blue: 0.3).opacity(0.85))
                .frame(height: 220)
            
            // Food icons as decoration
            HStack(spacing: 20) {
                ForEach(["🥗", "🍜", "🍕", "🥘"], id: \.self) { emoji in
                    Text(emoji)
                        .font(.system(size: 44))
                        .opacity(0.7)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
