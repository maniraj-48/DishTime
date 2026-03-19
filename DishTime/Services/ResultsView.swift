import SwiftUI

// ResultsView.swift
// Purpose: Shows ranked restaurant results after AI analysis
// GROUP 1: Restaurants WITH dish reviews → big RANK #1 card + small cards
// GROUP 2: Restaurants WITHOUT dish reviews → gray cards

struct ResultsView: View {
    
    let dishName: String
    let locationName: String
    @StateObject private var viewModel = SearchViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.hasError {
                    ErrorView(errorType: .notFound, dishName: dishName) {
                        viewModel.search(dishName: dishName, locationName: locationName)
                    }
                } else if viewModel.restaurants.isEmpty && viewModel.noReviewRestaurants.isEmpty {
                    loadingView
                } else {
                    filterBar
                    resultsList
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Only search if we don't have results yet
            // Prevents re-searching when coming back from DetailView
            if viewModel.restaurants.isEmpty && viewModel.noReviewRestaurants.isEmpty && !viewModel.isLoading {
                viewModel.search(dishName: dishName, locationName: locationName)
            }
        }
    }
    
    // MARK: - Top Bar
    // Back arrow + dish name + subtitle + filter icon
    var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 38, height: 38)
                        .shadow(color: .black.opacity(0.08), radius: 4)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("AppDark"))
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(dishName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("AppDark"))
                Text(viewModel.isLoading ? "Analyzing reviews in \(locationName)..." : "Showing top results")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(width: 38, height: 38)
                    .shadow(color: .black.opacity(0.08), radius: 4)
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 15))
                    .foregroundColor(Color("AppDark"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Loading View
    var loadingView: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color("AppOrange").opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color("AppOrange"))
            }
            VStack(spacing: 8) {
                Text("Finding Best Restaurants")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("AppDark"))
                Text("Analyzing \(dishName) reviews in \(locationName)...")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            ProgressView()
                .tint(Color("AppOrange"))
                .scaleEffect(1.2)
            Spacer()
        }
    }
    
    // MARK: - Filter Bar
    // Distance | Rating | Top Rated (selected) | Price
    var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterPill(label: "Distance", isSelected: false)
                FilterPill(label: "Rating", isSelected: false)
                FilterPill(label: "Top Rated", isSelected: true)
                FilterPill(label: "Price", isSelected: false)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
    
    // MARK: - Results List
    // GROUP 1: Has dish reviews → RANK cards with scores
    // GROUP 2: No dish reviews → gray cards
    var resultsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                
                // ── GROUP 1: WITH dish reviews ──
                if !viewModel.restaurants.isEmpty {
                    
                    // RANK #1 — Big featured card with orange border
                    if let first = viewModel.restaurants.first {
                        NavigationLink(destination: DetailView(
                            restaurant: first,
                            dishName: dishName
                        )) {
                            TopRankedCard(rank: 1, restaurant: first, dishName: dishName)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // RANKS 2, 3, 4, 5 — Small cards
                    ForEach(Array(viewModel.restaurants.dropFirst().enumerated()), id: \.offset) { index, restaurant in
                        NavigationLink(destination: DetailView(
                            restaurant: restaurant,
                            dishName: dishName
                        )) {
                            SmallRestaurantCard(rank: index + 2, restaurant: restaurant, dishName: dishName)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // ── GROUP 2: WITHOUT dish reviews ──
                if !viewModel.noReviewRestaurants.isEmpty {
                    HStack {
                        Text("Dish Likely Available")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("No dish reviews found")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 8)
                    
                    ForEach(viewModel.noReviewRestaurants) { restaurant in
                        NavigationLink(destination: DetailView(
                            restaurant: restaurant,
                            dishName: dishName
                        )) {
                            NoReviewCard(restaurant: restaurant, dishName: dishName)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer(minLength: 80)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
}

// MARK: - Top Ranked Card
// Big RANK #1 card — matches screenshot exactly
// Orange border, food photo area, WHAT PEOPLE LOVE, KEEP IN MIND, button
struct TopRankedCard: View {
    let rank: Int
    let restaurant: Restaurant
    let dishName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // ── Photo/Header Area ──
            // Dark gradient placeholder (real photo later)
            ZStack(alignment: .bottomTrailing) {
                
                // Dark food gradient background
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.08, blue: 0.05),
                            Color(red: 0.4, green: 0.22, blue: 0.06)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    Image(systemName: "fork.knife")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.08))
                }
                .frame(height: 200)
                
                // RANK badge — top left
                VStack {
                    HStack {
                        Text("RANK #\(rank)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color("AppOrange"))
                            .cornerRadius(6)
                            .padding(14)
                        Spacer()
                    }
                    Spacer()
                }
                
                // DISH SCORE badge — bottom right
                VStack(spacing: 0) {
                    Text("DISH SCORE")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .tracking(0.5)
                    HStack(alignment: .bottom, spacing: 2) {
                        Text(String(format: "%.1f", restaurant.dishScore))
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)
                        Text("/5")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.bottom, 4)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
                .padding(14)
            }
            .frame(height: 200)
            .clipped()
            
            // ── White Content Area ──
            VStack(alignment: .leading, spacing: 14) {
                
                // Restaurant name + green rating badge
                // Matches screenshot: name on left, green "5.0 ★" on right
                HStack(alignment: .top, spacing: 8) {
                    Text(restaurant.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("AppDark"))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    // Green rating badge — matches old UI
                    HStack(spacing: 4) {
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Address
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 11))
                        .foregroundColor(Color("AppOrange"))
                    Text(restaurant.address)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                // ⚠️ Warning — only shows for Scenario 2
                if restaurant.hasWarning {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 12))
                        Text(restaurant.warningMessage)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    .padding(10)
                    .background(Color.orange.opacity(0.08))
                    .cornerRadius(8)
                }
                
                // ✅ WHAT PEOPLE LOVE section
                // Matches screenshot heading style exactly
                if !restaurant.bestReview.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("WHAT PEOPLE LOVE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(1.2)
                        
                        // Single review card (scrollable horizontally like screenshot)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                // Main review card
                                Text("\"\(restaurant.bestReview)\"")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color("AppDark"))
                                    .italic()
                                    .padding(12)
                                    .frame(width: 220, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.05), radius: 4)
                                
                                // Second card placeholder
                                Text("\"Great authentic flavors, highly recommend!\"")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color("AppDark"))
                                    .italic()
                                    .padding(12)
                                    .frame(width: 180, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.05), radius: 4)
                            }
                        }
                    }
                }
                
                // ⚠️ KEEP IN MIND section
                // Only shows when hasWarning = true
                if restaurant.hasWarning {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("KEEP IN MIND")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(1.2)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                Text("\"\(restaurant.warningMessage)\"")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color("AppDark"))
                                    .italic()
                                    .padding(12)
                                    .frame(width: 220, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.05), radius: 4)
                            }
                        }
                    }
                }
                
                // View Menu & Order button — full width orange
                HStack {
                    Spacer()
                    Text("View Menu & Order →")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(Color("AppOrange"))
                .cornerRadius(14)
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(18)
        // ✅ Orange border — key feature of old UI!
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color("AppOrange"), lineWidth: 2)
        )
        .shadow(color: Color("AppOrange").opacity(0.15), radius: 14, x: 0, y: 6)
    }
}

// MARK: - Small Restaurant Card
// Compact cards for ranks 2, 3, 4, 5
// Matches screenshot: dark image box, name, rating, distance, review, tags
struct SmallRestaurantCard: View {
    let rank: Int
    let restaurant: Restaurant
    let dishName: String
    
    // Sample tags based on review content
    // These will be real when Gemini adds tag support
    var tags: [String] {
        if restaurant.hasWarning { return ["⚠️ Check rating"] }
        if restaurant.dishScore >= 4.5 { return ["Highly rated", "Must try"] }
        if restaurant.dishScore >= 4.0 { return ["Popular", "Authentic"] }
        return ["Good option"]
    }
    
    var body: some View {
        HStack(spacing: 12) {
            
            // Rank number — dark circle
            ZStack {
                Circle()
                    .fill(Color("AppDark"))
                    .frame(width: 32, height: 32)
                Text("\(rank)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Dark food image box — placeholder for now
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.08, blue: 0.05),
                                Color(red: 0.4, green: 0.22, blue: 0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Restaurant details
            VStack(alignment: .leading, spacing: 5) {
                
                // Name + DISH SCORE on right
                HStack(alignment: .top) {
                    Text(restaurant.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color("AppDark"))
                        .lineLimit(1)
                    Spacer()
                    // Dish score — orange, right aligned
                    VStack(spacing: 0) {
                        Text(String(format: "%.1f", restaurant.dishScore))
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(Color("AppOrange"))
                        Text("DISH\nSCORE")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
                
                // Rating + distance
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color("AppOrange"))
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                    Text("• Nearby")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                // Best review snippet
                if !restaurant.bestReview.isEmpty {
                    Text("\"\(restaurant.bestReview)\"")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                // Tags row — like "Large portions" "Spicy!" in screenshot
                HStack(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(restaurant.hasWarning ? .orange : Color("AppOrange"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                restaurant.hasWarning ?
                                Color.orange.opacity(0.1) :
                                Color("AppOrange").opacity(0.1)
                            )
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

// MARK: - No Review Card
// Gray card — Scenario 3 and 4
// Shows when dish has no reviews or Gemini quota exhausted
struct NoReviewCard: View {
    let restaurant: Restaurant
    let dishName: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Gray question mark box
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.08))
                    .frame(width: 60, height: 60)
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.gray.opacity(0.4))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("AppDark"))
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color("AppOrange"))
                    Text("Restaurant Rating: \(String(format: "%.1f", restaurant.rating))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
                Text("Dish likely available · No \(dishName) reviews found")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.4))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Filter Pill
// Orange = selected, White = not selected
struct FilterPill: View {
    let label: String
    let isSelected: Bool
    var body: some View {
        Text(label)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(isSelected ? .white : Color("AppDark"))
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isSelected ? Color("AppOrange") : Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 4)
    }
}

#Preview {
    // Mock data to preview UI without needing Gemini
    NavigationStack {
        ResultsView(dishName: "Paneer Curry", locationName: "Texas")
    }
}
