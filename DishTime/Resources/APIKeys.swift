import Foundation

// APIKeys.swift
// Purpose: One safe place to access all API keys
// Reads from Config.plist — never paste keys directly in code

struct APIKeys {
    
    private static func value(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let value = dict[key] as? String else {
            fatalError("⚠️ '\(key)' not found in Config.plist")
        }
        return value
    }
    
    // Google Places API Key
    // Used by: GooglePlacesService.swift to search restaurants
    static var googlePlaces: String {
        value(for: "GooglePlacesAPIKey")
    }
    
    // Gemini API Key (FREE!)
    // Used by: GeminiService.swift to analyze dish reviews
    static var gemini: String {
        value(for: "GeminiAPIKey")
    }
}
