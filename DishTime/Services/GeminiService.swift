import Foundation

// GeminiService.swift
// Purpose: Sends restaurant reviews to Google Gemini AI for analysis
// Gemini reads the reviews and tells us:
// 1. Is the dish mentioned in the reviews?
// 2. If yes — how good is it? (score 0-5)
// 3. What is the single best review mentioning the dish?
// Cost: FREE up to 20 requests/day on free tier

class GeminiService {
    
    // Singleton pattern — only one instance of GeminiService exists
    // Access it anywhere with: GeminiService.shared
    static let shared = GeminiService()
    private init() {}
    
    // API key loaded from Config.plist (never paste keys directly in code!)
    private let apiKey = APIKeys.gemini
    
    // The Gemini API endpoint URL
    // gemini-2.5-flash = fast, smart, free tier eligible model
    private var url: URL {
        URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=\(apiKey)")!

    }
    
    // MARK: - Main Function: Analyze Dish
    // Called once per restaurant during search
    // dishName = what user searched e.g. "Butter Chicken"
    // reviews = array of 5 review strings from Google Places
    // completion = callback with either success (DishAnalysis) or failure (Error)
    func analyzeDish(
        dishName: String,
        reviews: [String],
        completion: @escaping (Result<DishAnalysis, Error>) -> Void
    ) {
        // If no reviews available, return empty result immediately
        // No point calling Gemini with nothing to analyze — saves quota!
        guard !reviews.isEmpty else {
            completion(.success(DishAnalysis(score: 0, bestReview: "", hasDishReviews: false)))
            return
        }
        
        // Format reviews into numbered list for Gemini to read
        // Example output:
        // "Review 1: Great food!\nReview 2: Loved the curry..."
        let reviewsText = reviews.enumerated()
            .map { "Review \($0.offset + 1): \($0.element)" }
            .joined(separator: "\n")
        
        // IMPORTANT: This prompt is carefully designed to get ONLY JSON back
        // Previous version returned "Here is the JSON requested" before the JSON
        // Fix: Tell Gemini to output ONLY JSON with no intro text
        // The example at the end shows the exact compact format we need
        let prompt = """
        Analyze these restaurant reviews for mentions of "\(dishName)".
        
        Reviews:
        \(reviewsText)
        
        Rules:
        - If "\(dishName)" is mentioned: set hasDishReviews to true, score 0.0-5.0, pick best review sentence
        - If "\(dishName)" is NOT mentioned: set hasDishReviews to false, score 0, bestReview empty string
        
        Output ONLY this JSON and nothing else, no intro text, no explanation:
        {"score":4.5,"bestReview":"The dish was amazing and full of flavor.","hasDishReviews":true}
        """
        
        // Build the HTTP request body as JSON
        // temperature 0.1 = very consistent/predictable responses
        // maxOutputTokens 150 = short! Just enough for our small JSON
        // NOTE: responseMimeType removed — was causing issues with gemini-2.5-flash
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.1,     // Low = predictable JSON output every time
                "maxOutputTokens": 150  // Short = just our JSON, nothing extra
            ]
        ]
        
        // Set up the HTTP POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        print("🤖 Sending to Gemini: \(dishName) with \(reviews.count) reviews")
        
        // Make the actual network call to Gemini API
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Handle network errors (no internet, timeout, DNS fail etc)
            if let error = error {
                print("❌ Gemini Network Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Log HTTP status code for debugging
            // 200 = success ✅
            // 429 = quota exceeded ❌
            // 404 = model not found ❌
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Gemini HTTP Status: \(httpResponse.statusCode)")
                
                // If quota exceeded, return empty result gracefully
                // Restaurant still shows in "no review" group instead of crashing
                if httpResponse.statusCode == 429 {
                    print("⚠️ Gemini quota exceeded — skipping this restaurant")
                    completion(.success(DishAnalysis(score: 0, bestReview: "", hasDishReviews: false)))
                    return
                }
            }
            
            // Make sure we got data back
            guard let data = data else {
                print("❌ Gemini: No data received")
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            // Log raw response for debugging
            print("🤖 Gemini Raw Response: \(String(data: data, encoding: .utf8) ?? "unreadable")")
            
            do {
                // STEP 1: Decode the Gemini wrapper
                // Gemini wraps our answer inside:
                // candidates[0] → content → parts[0] → text
                let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                
                // STEP 2: Extract the text from inside the wrapper
                guard let text = geminiResponse.candidates.first?.content.parts.first?.text else {
                    print("❌ Gemini: No text found in response")
                    completion(.success(DishAnalysis(score: 0, bestReview: "", hasDishReviews: false)))
                    return
                }
                
                print("✅ Gemini Text: \(text)")
                
                // STEP 3: Clean the text
                // Remove markdown code fences just in case Gemini adds them
                let cleanText = text
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // STEP 4: Find JSON starting point
                // Extract just the JSON part starting from "{"
                // This handles cases where Gemini adds text BEFORE the JSON
                let jsonStartIndex = cleanText.firstIndex(of: "{") ?? cleanText.startIndex
                let jsonText = String(cleanText[jsonStartIndex...])
                
                // STEP 5: Convert to Data for JSON decoding
                guard let jsonData = jsonText.data(using: .utf8) else {
                    print("❌ Gemini: Could not convert text to JSON data")
                    completion(.success(DishAnalysis(score: 0, bestReview: "", hasDishReviews: false)))
                    return
                }
                
                // STEP 6: Decode into DishAnalysis struct
                let analysis = try JSONDecoder().decode(DishAnalysis.self, from: jsonData)
                print("✅ Dish score: \(analysis.score)/5 | Has reviews: \(analysis.hasDishReviews)")
                completion(.success(analysis))
                
            } catch {
                print("❌ Gemini Parse Error: \(error.localizedDescription)")
                // Return empty result instead of failing completely
                // Restaurant still shows in "no review" group
                completion(.success(DishAnalysis(score: 0, bestReview: "", hasDishReviews: false)))
            }
        }.resume()
    }
}

// MARK: - Gemini API Response Wrapper Models
// These exactly mirror the JSON structure Gemini returns
// Full structure: { candidates: [{ content: { parts: [{ text: "..." }] } }] }

nonisolated struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]   // Usually just 1 candidate
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]             // Usually just 1 part
}

struct GeminiPart: Codable {
    let text: String                    // This is where our JSON lives!
}

// MARK: - Dish Analysis Result
// This is the final parsed result from Gemini
// Matches the JSON format we ask Gemini to return:
// {"score":4.5,"bestReview":"...","hasDishReviews":true}
nonisolated struct DishAnalysis: Codable {
    let score: Double           // 0.0 to 5.0 dish quality score
    let bestReview: String      // Best review sentence mentioning the dish
    let hasDishReviews: Bool    // true = dish mentioned, false = not mentioned
}
