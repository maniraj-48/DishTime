
import SwiftUI

// SignUpView.swift
// Purpose: New users create an account here
// Collects name, email, password — then navigates to HomeView

struct SignUpView: View {
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var goToHome = false
    @Environment(\.dismiss) var dismiss   // Goes back to LoginView
    
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // ── Back Button + Title ──
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("AppDark"))
                        }
                        Spacer()
                        Text("Sign Up")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color("AppDark"))
                        Spacer()
                        Color.clear.frame(width: 24) // Balances the back button
                    }
                    .padding(.top, 16)
                    
                    // ── Heading ──
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Create Account")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color("AppDark"))
                        Text("Join DishTime and start your culinary journey today.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    // ── Full Name ──
                    inputField(
                        title: "Full Name",
                        placeholder: "Enter your full name",
                        text: $fullName,
                        icon: "person"
                    )
                    
                    // ── Email ──
                    inputField(
                        title: "Email",
                        placeholder: "example@email.com",
                        text: $email,
                        icon: "envelope"
                    )
                    
                    // ── Password ──
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("AppDark"))
                        
                        HStack {
                            if showPassword {
                                TextField("Min. 8 characters", text: $password)
                            } else {
                                SecureField("Min. 8 characters", text: $password)
                            }
                            Button { showPassword.toggle() } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                    }
                    
                    // ── Confirm Password ──
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("AppDark"))
                        
                        HStack {
                            SecureField("Repeat password", text: $confirmPassword)
                            // Shows checkmark if passwords match
                            if !confirmPassword.isEmpty {
                                Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(password == confirmPassword ? .green : .red)
                            }
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                    }
                    
                    // ── Sign Up Button ──
                    Button {
                        goToHome = true
                    } label: {
                        Text("Sign Up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("AppOrange"))
                            .cornerRadius(14)
                    }
                    
                    // ── OR Divider ──
                    HStack {
                        Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                        Text("Or continue with")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .fixedSize()
                            .padding(.horizontal, 8)
                        Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                    }
                    
                    // ── Google + Apple Buttons ──
                    VStack(spacing: 12) {
                        socialButton(label: "Google", icon: "G", color: .blue)
                        socialButton(label: "Apple ID", icon: "", color: .black)
                    }
                    
                    // ── Already have account ──
                    HStack {
                        Spacer()
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Button("Login") { dismiss() }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("AppOrange"))
                        Spacer()
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goToHome) {
            HomeView()
        }
    }
    
    // MARK: - Reusable Input Field
    // Purpose: Avoids repeating the same text field UI code
    func inputField(title: String, placeholder: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("AppDark"))
            HStack {
                TextField(placeholder, text: text)
                    .font(.system(size: 15))
                    .autocapitalization(.none)
                Image(systemName: icon)
                    .foregroundColor(.gray)
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
        }
    }
    
    // MARK: - Social Login Button
    // Purpose: Reusable Google/Apple sign in button
    func socialButton(label: String, icon: String, color: Color) -> some View {
        Button { } label: {
            HStack(spacing: 10) {
                if label == "Apple ID" {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                } else {
                    Text(icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("AppDark"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
    }
}

#Preview {
    SignUpView()
}
