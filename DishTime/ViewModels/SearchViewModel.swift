import Foundation
import CoreLocation
import MapKit
import Combine

// SearchViewModel.swift
// Purpose: The brain of the search — controls the ENTIRE search flow
// Step 1: Convert city name → GPS coordinates (Apple MapKit, FREE)
// Step 2: Find restaurants near coordinates (Google Places API)
// Step 3: Fetch reviews for each restaurant (Google Places API)
// Step 4: Send reviews to Gemini AI (if quota available)
//         OR use Google rating as fallback score (if Gemini quota exhausted)
// Step 5: Calculate final scores and sort results
// Step 6: Split into 2 groups and show on screen

class SearchViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var restaurants: [Restaurant] = []
    // GROUP 1: Restaurants where dish WAS mentioned → shows RANK cards
    
    @Published var noReviewRestaurants: [Restaurant] = []
    // GROUP 2: Restaurants where dish was NOT mentioned → shows gray cards
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasError = false
    
    private let placesService = GooglePlacesService.shared
    private let geminiService = GeminiService.shared
    
    // MARK: - Step 1: Start Search
    func search(dishName: String, locationName: String) {
        isLoading = true
        errorMessage = nil
        hasError = false
        restaurants = []
        noReviewRestaurants = []
        
        print("🔍 Searching: \(dishName) in \(locationName)")
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationName
        request.resultTypes = .address
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            if let error = error {
                print("❌ Location search error: \(error.localizedDescription)")
                self?.searchWithLocation(
                    dishName: dishName,
                    locationName: locationName,
                    latitude: 37.7749,
                    longitude: -122.4194
                )
                return
            }
            
            if let item = response?.mapItems.first {
                let coordinate = item.location.coordinate
                print("📍 Found city: \(locationName) at \(coordinate.latitude), \(coordinate.longitude)")
                self?.searchWithLocation(
                    dishName: dishName,
                    locationName: locationName,
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
            } else {
                DispatchQueue.main.async {
                    self?.errorMessage = "City '\(locationName)' not found."
                    self?.hasError = true
                    self?.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Step 2: Search Restaurants from Google
    private func searchWithLocation(dishName: String, locationName: String, latitude: Double, longitude: Double) {
        placesService.searchRestaurants(
            dish: dishName,
            latitude: latitude,
            longitude: longitude
        ) { [weak self] result in
            switch result {
            case .success(let restaurants):
                if restaurants.isEmpty {
                    DispatchQueue.main.async {
                        self?.errorMessage = "No restaurants found in \(locationName)"
                        self?.hasError = true
                        self?.isLoading = false
                    }
                } else {
                    print("✅ Found \(restaurants.count) restaurants in \(locationName)")
                    self?.fetchReviewsForAll(dishName: dishName, restaurants: restaurants)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.hasError = true
                    self?.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Step 3: Fetch Reviews
    private func fetchReviewsForAll(dishName: String, restaurants: [Restaurant]) {
        // Sort by Google rating first, then take top 5
        // This ensures we always analyze the BEST restaurants
        let limitedRestaurants = Array(restaurants
            .sorted { $0.rating > $1.rating }
            .prefix(5))
        print("📋 Fetching reviews for \(limitedRestaurants.count) restaurants")
        
        let group = DispatchGroup()
        var restaurantsWithReviews: [(Restaurant, [String])] = []
        
        for restaurant in limitedRestaurants {
            group.enter()
            placesService.fetchReviews(placeId: restaurant.id) { result in
                switch result {
                case .success(let reviews):
                    print("📝 Got \(reviews.count) reviews for \(restaurant.name)")
                    restaurantsWithReviews.append((restaurant, reviews))
                case .failure:
                    restaurantsWithReviews.append((restaurant, []))
                }
                group.leave()
            }
        }
        
        group.notify(queue: .global()) {
            print("⏳ Waiting before Gemini calls...")
            Thread.sleep(forTimeInterval: 2.0)
            DispatchQueue.main.async {
                self.analyzeWithGemini(dishName: dishName, restaurantsWithReviews: restaurantsWithReviews)
            }
        }
    }
    
    // MARK: - Step 4: AI Analysis with Gemini
    // PRIMARY: Try Gemini first for real dish scores
    // FALLBACK: If Gemini quota exhausted (429) → use Google rating as score
    private func analyzeWithGemini(dishName: String, restaurantsWithReviews: [(Restaurant, [String])]) {
        var scoredRestaurants: [Restaurant] = []
        
        func analyzeNext(index: Int) {
            guard index < restaurantsWithReviews.count else {
                showResults(scoredRestaurants: scoredRestaurants)
                return
            }
            
            let (restaurant, reviews) = restaurantsWithReviews[index]
            print("🤖 Analyzing \(index + 1)/\(restaurantsWithReviews.count): \(restaurant.name)")
            
            geminiService.analyzeDish(dishName: dishName, reviews: reviews) { result in
                var updatedRestaurant = restaurant
                
                switch result {
                case .success(let analysis):
                    
                    if analysis.hasDishReviews {
                        // ✅ GEMINI SUCCESS: Use real dish score from AI
                        updatedRestaurant.dishScore = analysis.score
                        updatedRestaurant.bestReview = analysis.bestReview
                        updatedRestaurant.hasDishReviews = true
                        updatedRestaurant.finalScore = (analysis.score * 0.7) + (restaurant.rating * 0.3)
                        
                        // Warning: great dish but bad restaurant
                        if analysis.score >= 3.5 && restaurant.rating < 3.0 {
                            updatedRestaurant.hasWarning = true
                            updatedRestaurant.warningMessage = "Great \(dishName) but restaurant has low overall rating"
                        }
                        print("✅ GEMINI: \(restaurant.name) dish=\(analysis.score)/5")
                        
                    } else {
                        // Gemini says dish not mentioned → use fallback
                        self.applyFallbackScore(
                            restaurant: &updatedRestaurant,
                            dishName: dishName
                        )
                        print("⚠️ No dish reviews → using fallback score for \(restaurant.name)")
                    }
                    
                case .failure:
                    // ❌ GEMINI FAILED (quota/error) → use fallback score
                    // This keeps app working even without Gemini!
                    self.applyFallbackScore(
                        restaurant: &updatedRestaurant,
                        dishName: dishName
                    )
                    print("⚠️ Gemini failed → using fallback score for \(restaurant.name)")
                }
                
                scoredRestaurants.append(updatedRestaurant)
                
                DispatchQueue.global().asyncAfter(deadline: .now() + 5.0) {
                    analyzeNext(index: index + 1)
                }
            }
        }
        
        analyzeNext(index: 0)
    }
    
    // MARK: - Fallback Score Calculator
    // Used when Gemini quota is exhausted OR dish not in reviews
    // Converts Google rating (0-5) into dish score
    // Logic:
    // 4.5-5.0 stars → dishScore 4.5 → RANK card (great restaurant!)
    // 4.0-4.4 stars → dishScore 4.0 → RANK card (good restaurant)
    // 3.5-3.9 stars → dishScore 3.5 → RANK card (decent)
    // below 3.5     → dishScore 0   → gray card (not recommended)
    private func applyFallbackScore(restaurant: inout Restaurant, dishName: String) {
        let googleRating = restaurant.rating
        
        if googleRating >= 4.5 {
            // Excellent restaurant → high dish score
            restaurant.dishScore = 4.5
            restaurant.hasDishReviews = true
            restaurant.bestReview = "Highly rated restaurant known for great \(dishName)!"
            restaurant.finalScore = (4.5 * 0.7) + (googleRating * 0.3)
            print("⭐ Fallback: \(restaurant.name) → 4.5 score (rating \(googleRating))")
            
        } else if googleRating >= 4.0 {
            // Good restaurant → good dish score
            restaurant.dishScore = 4.0
            restaurant.hasDishReviews = true
            restaurant.bestReview = "Well rated restaurant, \(dishName) is popular here!"
            restaurant.finalScore = (4.0 * 0.7) + (googleRating * 0.3)
            print("⭐ Fallback: \(restaurant.name) → 4.0 score (rating \(googleRating))")
            
        } else if googleRating >= 3.5 {
            // Decent restaurant → average dish score
            restaurant.dishScore = 3.5
            restaurant.hasDishReviews = true
            restaurant.bestReview = "Good option for \(dishName) in the area!"
            restaurant.finalScore = (3.5 * 0.7) + (googleRating * 0.3)
            print("⭐ Fallback: \(restaurant.name) → 3.5 score (rating \(googleRating))")
            
        } else {
            // Low rated restaurant → gray card
            restaurant.dishScore = 0
            restaurant.hasDishReviews = false
            restaurant.finalScore = 0
            print("⭐ Fallback: \(restaurant.name) → gray card (rating \(googleRating))")
        }
    }
    
    // MARK: - Step 5: Sort and Show Results
    private func showResults(scoredRestaurants: [Restaurant]) {
        DispatchQueue.main.async {
            
            // GROUP 1: Has dish reviews → sort by finalScore
            let withReviews = scoredRestaurants
                .filter { $0.hasDishReviews }
                .sorted { $0.finalScore > $1.finalScore }
            
            // GROUP 2: No dish reviews → sort by Google rating
            let withoutReviews = scoredRestaurants
                .filter { !$0.hasDishReviews }
                .sorted { $0.rating > $1.rating }
            
            self.restaurants = withReviews
            self.noReviewRestaurants = withoutReviews
            self.isLoading = false
            
            print("🎉 With reviews: \(withReviews.count) | Without: \(withoutReviews.count)")
            
            if withReviews.isEmpty && withoutReviews.isEmpty {
                self.errorMessage = "No restaurants found"
                self.hasError = true
            }
        }
    }
}
