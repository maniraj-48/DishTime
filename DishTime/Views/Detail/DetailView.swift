import SwiftUI

// DetailView.swift
// Purpose: Full detail screen for ONE restaurant
// Opens when user taps any card in ResultsView
// Shows different content based on whether dish was reviewed or not:
// CASE 1: hasDishReviews = true  → show AI score, best review, warning
// CASE 2: hasDishReviews = false → show "dish likely available" message

struct DetailView: View {
    
    // Full restaurant object passed from ResultsView
    // Contains ALL data: Google info + Gemini analysis
    let restaurant: Restaurant
    
    // What the user originally searched e.g. "Butter Chicken"
    let dishName: String
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Brown header with dish score badge
                headerImage
                
                // Scrollable content below header
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Restaurant name, address, star rating, warning badge
                        restaurantInfo
                        
                        // Address row + phone number row
                        contactInfo
                        
                        Divider().padding(.horizontal)
                        
                        // 3 scores side by side:
                        // Dish Score | Restaurant Rating | Final Score
                        scoresSection
                        
                        Divider().padding(.horizontal)
                        
                        // CASE 1: Dish was mentioned → show best review
                        // CASE 2: Dish not mentioned → show "likely available" message
                        if restaurant.hasDishReviews {
                            whatPeopleLoveSection  // renamed to match old UI style
                        } else {
                            noDishReviewSection
                        }
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header Image
    // Dark gradient banner at top — matches old UI style
    // Shows dish score badge bottom right
    // Shows "N/A" if dish wasn't reviewed
    var headerImage: some View {
        ZStack(alignment: .topLeading) {
            ZStack {
                // Dark gradient background like old UI
                LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.2, blue: 0.05),
                        Color(red: 0.6, green: 0.3, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 240)
                
                // Decorative fork icon in background
                Image(systemName: "fork.knife")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.12))
                
                // Dish score badge — bottom right corner
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 2) {
                            Text("DISH SCORE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white.opacity(0.85))
                                .tracking(0.5)
                            // Show actual score OR "N/A" if no dish reviews
                            Text(restaurant.hasDishReviews ? String(format: "%.1f", restaurant.dishScore) : "N/A")
                                .font(.system(size: 30, weight: .black))
                                .foregroundColor(.white)
                            Text("/5")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        .padding(16)
                    }
                }
            }
            .frame(height: 240)
            
            // Back button — top left overlaid on header
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 38, height: 38)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("AppDark"))
                }
            }
            .padding(.top, 50)
            .padding(.leading, 16)
        }
    }
    
    // MARK: - Restaurant Info
    // Shows: name, address, Google star rating, warning badge, dish filter tag
    var restaurantInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    // Restaurant name — big and bold
                    Text(restaurant.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color("AppDark"))
                    
                    // Address with orange pin icon
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 13))
                            .foregroundColor(Color("AppOrange"))
                        Text(restaurant.address)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Google star rating badge — top right
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color("AppOrange"))
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color("AppDark"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color("AppOrange").opacity(0.1))
                .cornerRadius(8)
            }
            
            // Warning banner — only shows when:
            // dish score is good (>= 3.5) BUT restaurant rating is low (< 3.0)
            // Example: "Great Butter Chicken but restaurant has low overall rating"
            if restaurant.hasWarning {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 13))
                    Text(restaurant.warningMessage)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.08))
                .cornerRadius(10)
            }
            
            // Orange tag showing what dish was searched
            // Reminds user these reviews are filtered for their dish
            HStack(spacing: 6) {
                Image(systemName: "fork.knife.circle.fill")
                    .foregroundColor(Color("AppOrange"))
                Text("Reviews filtered for: \(dishName)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("AppOrange"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color("AppOrange").opacity(0.08))
            .cornerRadius(10)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Contact Info
    // Two white cards stacked:
    // Card 1 — full address with map pin icon
    // Card 2 — phone number with phone icon
    var contactInfo: some View {
        VStack(spacing: 10) {
            
            // Address card
            HStack(spacing: 10) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color("AppOrange"))
                Text(restaurant.address)
                    .font(.system(size: 14))
                    .foregroundColor(Color("AppDark"))
                Spacer()
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(12)
            
            // Phone card
            // Shows fallback text if Google didn't return a phone number
            HStack(spacing: 10) {
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color("AppOrange"))
                Text(restaurant.phoneNumber.isEmpty ? "Phone not available" : restaurant.phoneNumber)
                    .font(.system(size: 14))
                    .foregroundColor(Color("AppDark"))
                Spacer()
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Scores Section
    // 3 columns in a white card showing all scores:
    // Dish Score (0-10) | Restaurant Rating (0-5) | Final Score (0-10)
    // Final Score = (dishScore × 0.7) + (googleRating × 0.3)
    var scoresSection: some View {
        HStack(spacing: 0) {
            
            // Column 1: Dish Score — from Gemini AI
            // Shows N/A if dish wasn't mentioned in any review
            VStack(spacing: 4) {
                Text(restaurant.hasDishReviews ? String(format: "%.1f", restaurant.dishScore) : "N/A")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("AppOrange"))
                Text("Dish Score")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Text("out of 5")
                    .font(.system(size: 10))
                    .foregroundColor(.gray.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            
            Divider().frame(height: 50)
            
            // Column 2: Restaurant Rating — from Google Places
            // Always available — comes directly from Google
            VStack(spacing: 4) {
                Text(String(format: "%.1f", restaurant.rating))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("AppOrange"))
                Text("Restaurant")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Text("out of 5")
                    .font(.system(size: 10))
                    .foregroundColor(.gray.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            
            Divider().frame(height: 50)
            
            // Column 3: Final Score — weighted combination
            // Formula: (dishScore × 0.7) + (googleRating × 0.3)
            // Only meaningful when dish was reviewed
            VStack(spacing: 4) {
                Text(restaurant.hasDishReviews ? String(format: "%.1f", restaurant.finalScore) : "N/A")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("AppOrange"))
                Text("Final Score")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Text("out of 5")
                    .font(.system(size: 10))
                    .foregroundColor(.gray.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
    
    // MARK: - What People Love Section
    // Matches old UI style "WHAT PEOPLE LOVE" heading
    // Shows the single best review Gemini selected for the dish
    // Only shown when hasDishReviews = true
    var whatPeopleLoveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Section header — matches old UI exactly
            Text("WHAT PEOPLE LOVE")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1)
                .padding(.horizontal, 16)
            
            // Best review quote in green card
            if !restaurant.bestReview.isEmpty {
                HStack(alignment: .top, spacing: 10) {
                    // Decorative large quote mark
                    Text("\"")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.green.opacity(0.3))
                        .offset(y: -4)
                    
                    // The actual review text — can wrap multiple lines
                    Text(restaurant.bestReview)
                        .font(.system(size: 14))
                        .foregroundColor(Color("AppDark"))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                .padding(14)
                .background(Color.green.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal, 16)
            }
            
            // Keep In Mind section — shows warning if applicable
            // Matches old UI "KEEP IN MIND" section
            if restaurant.hasWarning {
                VStack(alignment: .leading, spacing: 8) {
                    Text("KEEP IN MIND")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .tracking(1)
                        .padding(.horizontal, 16)
                    
                    HStack(alignment: .top, spacing: 10) {
                        Text("\"")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.orange.opacity(0.3))
                            .offset(y: -4)
                        
                        // Warning message — e.g. "Great Butter Chicken but restaurant has low overall rating"
                        Text(restaurant.warningMessage)
                            .font(.system(size: 14))
                            .foregroundColor(Color("AppDark"))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    .padding(14)
                    .background(Color.orange.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                }
            }
            
            // View Menu button — matches old UI orange button
            Button {
                // Future: open maps or website
            } label: {
                HStack {
                    Spacer()
                    Text("View Menu & Order →")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(Color("AppOrange"))
                .cornerRadius(12)
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - No Dish Review Section
    // Only shown when hasDishReviews = false
    // Tells user dish is probably available but nobody reviewed it specifically
    var noDishReviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Gray heading (not green — no confirmed reviews)
            Text("ℹ️  About \(dishName) Here")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
            
            // Info card explaining the situation to the user
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dish likely available")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("AppDark"))
                    
                    Text("No reviews mentioning \(dishName) were found, but this restaurant serves similar cuisine.")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            
            // Still show the orange button for no-review restaurants
            // User might still want to check the menu
            Button {
                // Future: open maps or website
            } label: {
                HStack {
                    Spacer()
                    Text("View Menu & Order →")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(Color("AppOrange"))
                .cornerRadius(12)
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DetailView(
        restaurant: Restaurant(
            id: "1",
            name: "Royal India Cuisine",
            address: "123 Curry Lane, Downtown",
            rating: 4.8,
            phoneNumber: "+1 (212) 555-0198",
            latitude: 0,
            longitude: 0
        ),
        dishName: "Butter Chicken"
    )
}
