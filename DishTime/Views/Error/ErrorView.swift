import SwiftUI

// ErrorView.swift
// Purpose: Shown when something goes wrong
// Examples: no internet, dish not found in reviews, API limit reached
// Always gives user a clear message + Try Again button

struct ErrorView: View {
    
    // The error type changes the icon and message shown
    enum ErrorType {
        case notFound       // Dish not mentioned in any reviews
        case noInternet     // No internet connection
        case apiError       // Google/OpenAI API failed
    }
    
    let errorType: ErrorType
    let dishName: String
    var onRetry: () -> Void  // What happens when user taps Try Again
    
    // Pick icon based on error type
    var errorIcon: String {
        switch errorType {
        case .notFound:   return "magnifyingglass.circle"
        case .noInternet: return "wifi.slash"
        case .apiError:   return "exclamationmark.triangle"
        }
    }
    
    // Pick message based on error type
    var errorMessage: String {
        switch errorType {
        case .notFound:
            return "No restaurants found with reviews mentioning \"\(dishName)\". Try a different dish name."
        case .noInternet:
            return "No internet connection. Please check your WiFi or mobile data and try again."
        case .apiError:
            return "Something went wrong on our end. Please try again in a moment."
        }
    }
    
    var errorTitle: String {
        switch errorType {
        case .notFound:   return "No Results Found"
        case .noInternet: return "No Connection"
        case .apiError:   return "Something Went Wrong"
        }
    }
    
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                
                Spacer()
                
                // ── Error Icon ──
                ZStack {
                    Circle()
                        .fill(Color("AppOrange").opacity(0.1))
                        .frame(width: 110, height: 110)
                    Image(systemName: errorIcon)
                        .font(.system(size: 44))
                        .foregroundColor(Color("AppOrange"))
                }
                
                // ── Error Text ──
                VStack(spacing: 12) {
                    Text(errorTitle)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color("AppDark"))
                    
                    Text(errorMessage)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // ── Try Again Button ──
                Button {
                    onRetry()   // Calls whatever action was passed in
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Try Again")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("AppOrange"))
                    .cornerRadius(16)
                    .padding(.horizontal, 40)
                }
                
                // ── Search Different Dish ──
                Button {
                    onRetry()
                } label: {
                    Text("Search a different dish")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("AppOrange"))
                }
                
                Spacer(minLength: 40)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ErrorView(errorType: .notFound, dishName: "Truffle Pizza") { }
}
