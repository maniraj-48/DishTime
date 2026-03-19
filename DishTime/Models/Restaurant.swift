import Foundation

// Restaurant.swift
// Purpose: The data blueprint for every restaurant in the app
// Think of this like a form with fields — every restaurant fills in these fields
// This struct is used everywhere: GooglePlacesService, GeminiService, ResultsView, DetailView

struct Restaurant: Identifiable, Codable {
    
    // MARK: - Basic Info (comes from Google Places API)
    let id: String          // Unique Google Place ID e.g. "ChIJWzc2g3W1RIYRjO8jatRnEYs"
    let name: String        // Restaurant name e.g. "Tikka House Indian Eatery"
    let address: String     // Full address e.g. "5610 N Lamar Blvd, Austin, TX"
    let rating: Double      // Google star rating e.g. 4.9 (out of 5)
    let phoneNumber: String // Phone number e.g. "+1 512-243-5855"
    let latitude: Double    // GPS latitude for map location
    let longitude: Double   // GPS longitude for map location
    
    // MARK: - AI Analysis Results (added after Gemini analyzes reviews)
    // These start empty — Gemini fills them in during search
    
    var dishScore: Double = 0.0
    // Gemini's score for the searched dish at this restaurant
    // Range: 0.0 to 5.0
    // 0.0 = dish not mentioned in reviews at all
    // 5.0 = dish mentioned and highly praised
    
    var bestReview: String = ""
    // The single best review sentence that mentions the dish
    // Gemini picks this from all the reviews
    // Example: "The butter chicken here was absolutely incredible and full of flavor"
    
    var hasDishReviews: Bool = false
    // true  = at least one review mentioned the dish → show AI score
    // false = no reviews mentioned the dish → show "dish likely available"
    
    // MARK: - Combined Score (calculated in SearchViewModel)
    var finalScore: Double = 0.0
    // Formula: (dishScore × 0.7) + (googleRating × 0.3)
    // Dish quality counts 70% — most important!
    // Restaurant rating counts 30% — also matters but less
    // Used to sort restaurants from best to worst
    // Example: dishScore 4.5, rating 4.9
    // finalScore = (4.5 × 0.7) + (4.9 × 0.3) = 3.15 + 1.47 = 4.62
    
    // MARK: - Warning System
    var hasWarning: Bool = false
    // true = dish is great BUT restaurant rating is low
    // Triggers when: dishScore >= 3.5 AND googleRating < 3.0
    
    var warningMessage: String = ""
    // Message shown to user when hasWarning is true
    // Example: "Great Butter Chicken but restaurant has low overall rating"
}
