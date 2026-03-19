import SwiftUI
import CoreLocation

struct HomeView: View {
    
    @State private var searchText = ""
    @State private var locationText = ""
    @State private var navigateToResults = false
    
    let suggestions = [
        "Butter Chicken", "Truffle Pasta",
        "Spicy Ramen", "Paneer Curry",
        "Sushi Roll", "Pad Thai"
    ]
    
    // Both fields must have text to enable search
    var canSearch: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty &&
        !locationText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    // ── Logo & Title ──
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color("AppOrange"))
                                .frame(width: 64, height: 64)
                            Image(systemName: "fork.knife")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("DishTime")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color("AppDark"))
                        
                        Text("Find the Best Dish, Not Just the Restaurant.")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer().frame(height: 40)
                    
                    // ── Search Fields ──
                    VStack(spacing: 12) {
                        
                        // Dish Search Bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 17))
                            
                            TextField("e.g. Paneer Curry, Sushi, Pizza...", text: $searchText)
                                .font(.system(size: 15))
                                .foregroundColor(Color("AppDark"))
                            
                            if !searchText.isEmpty {
                                Button { searchText = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
                        .padding(.horizontal, 24)
                        
                        // Location Bar
                        HStack(spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(Color("AppOrange"))
                                .font(.system(size: 17))
                            
                            TextField("Enter city e.g. New York, London...", text: $locationText)
                                .font(.system(size: 15))
                                .foregroundColor(Color("AppDark"))
                            
                            if !locationText.isEmpty {
                                Button { locationText = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
                        .padding(.horizontal, 24)
                        
                        // Search Button
                        Button {
                            if canSearch {
                                navigateToResults = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Find Best Restaurants")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canSearch ? Color("AppOrange") : Color("AppOrange").opacity(0.4))
                            .cornerRadius(16)
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    Spacer().frame(height: 32)
                    
                    // ── Quick Suggestion Chips ──
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Popular right now")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 24)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(suggestions, id: \.self) { dish in
                                    Button {
                                        searchText = dish
                                    } label: {
                                        Text(dish)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(searchText == dish ? .white : Color("AppOrange"))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(searchText == dish ? Color("AppOrange") : Color("AppOrange").opacity(0.1))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    Spacer()
                    
                    Text("Powered by Google Places & Gemini AI")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToResults) {
                ResultsView(dishName: searchText, locationName: locationText)
            }
        }
    }
}

#Preview {
    HomeView()
}
