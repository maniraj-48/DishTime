import Foundation
import CoreLocation

// GooglePlacesService.swift
// Purpose: Handles ALL communication with Google Places API
// Two jobs:
// 1. Search restaurants near user by dish name
// 2. Fetch reviews for each restaurant
// All other files just call this service — they don't touch the API directly

class GooglePlacesService {
    
    // Singleton — one shared instance used everywhere in the app
    static let shared = GooglePlacesService()
    private init() {}
    
    private let apiKey = APIKeys.googlePlaces
    private let baseURL = "https://places.googleapis.com/v1/places"
    
    // MARK: - Search Restaurants by Dish
    // What it does: Takes a dish name + location, returns list of restaurants
    // Called by: SearchViewModel when user taps Search
    func searchRestaurants(
        dish: String,
        latitude: Double,
        longitude: Double,
        completion: @escaping (Result<[Restaurant], Error>) -> Void
    ) {
        let urlString = "\(baseURL):searchText"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Tell Google we want JSON back
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Our API key goes here
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        // Tell Google which fields we need — only pay for what we use
        request.setValue(
            "places.id,places.displayName,places.formattedAddress,places.rating,places.userRatingCount,places.location,places.internationalPhoneNumber",
            forHTTPHeaderField: "X-Goog-FieldMask"
        )
        
        // Search query — dish name + "restaurant" to filter results
        let body: [String: Any] = [
            "textQuery": "\(dish) restaurant",
            "locationBias": [
                "circle": [
                    "center": [
                        "latitude": latitude,
                        "longitude": longitude
                    ],
                    "radius": 50000.0  // Search within 50km radius
                ]
            ],
            "maxResultCount": 10,
            "languageCode": "en"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Make the actual network call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            print("📍 Google Response: \(String(data: data, encoding: .utf8) ?? "no data")")
            
            do {
                // Parse the JSON response from Google
                let decoded = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)
                let restaurants = decoded.places.map { place in
                    Restaurant(
                        id: place.id,
                        name: place.displayName.text,
                        address: place.formattedAddress,
                        rating: place.rating ?? 0.0,
                        phoneNumber: place.internationalPhoneNumber ?? "Not available",
                        latitude: place.location.latitude,
                        longitude: place.location.longitude
                    )
                }
                completion(.success(restaurants))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Fetch Reviews for a Restaurant
    // What it does: Gets up to 5 reviews for one restaurant using its Google Place ID
    // Called by: SearchViewModel after getting restaurant list
    func fetchReviews(
        placeId: String,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        let urlString = "\(baseURL)/\(placeId)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        // Only fetch reviews field — saves API cost
        request.setValue("reviews", forHTTPHeaderField: "X-Goog-FieldMask")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(GooglePlaceDetailResponse.self, from: data)
                // Extract just the review text from each review
                let reviewTexts = decoded.reviews?.map { $0.text.text } ?? []
                completion(.success(reviewTexts))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Google API Response Models
// Purpose: These structs match exactly what Google sends back as JSON
// Swift uses these to automatically parse the response

nonisolated struct GooglePlacesResponse: Codable {
    let places: [GooglePlace]
}

struct GooglePlace: Codable {
    let id: String
    let displayName: GoogleDisplayName
    let formattedAddress: String
    let rating: Double?
    let userRatingCount: Int?
    let location: GoogleLocation
    let internationalPhoneNumber: String?
}

struct GoogleDisplayName: Codable {
    let text: String
}

struct GoogleLocation: Codable {
    let latitude: Double
    let longitude: Double
}

nonisolated struct GooglePlaceDetailResponse: Codable {
    let reviews: [GoogleReview]?
}

struct GoogleReview: Codable {
    let text: GoogleReviewText
    let rating: Int?
}

struct GoogleReviewText: Codable {
    let text: String
}
