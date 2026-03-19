# DishTime 🍽️
### Find the best restaurant for any dish in seconds!

---

## 📱 About
DishTime is an AI-powered iOS app that solves a real problem — when you're craving a specific dish, you normally spend 30 minutes checking every restaurant on Google Maps one by one. DishTime does it in **30 seconds**.

Just type the dish and city, and the app finds the best restaurant for that exact dish using AI.

---

## ✨ Features
- 🔍 Search any dish in any city
- 🤖 AI-powered dish score out of 5
- ⭐ Real customer review snippets
- 🏆 Ranked results (best dish first)
- ⚠️ Warning indicators for bad dish reviews
- 📍 Location-based restaurant discovery
- 🔄 Smart fallback system for API failures

---

## 🛠️ Tech Stack
- **SwiftUI** — UI framework
- **MapKit** — City to GPS coordinates
- **Google Places API** — Restaurant discovery & reviews
- **Gemini 2.5 Flash Lite AI** — Dish review analysis & scoring

---

## 🔄 How It Works
1. User enters dish + city
2. MapKit converts city to GPS coordinates
3. Google Places finds top 10 restaurants nearby
4. Top 5 restaurants selected by Google rating
5. Fetches 5 real customer reviews per restaurant
6. Gemini AI reads reviews and scores the dish out of 5
7. Results ranked by dish score — best restaurant shown first

---

## 📊 Scoring System
| Scenario | Result |
|----------|--------|
| Dish reviewed + good score | RANK card with dish score |
| Dish reviewed + low score | RANK card with ⚠️ warning |
| No dish reviews found | Gray card (N/A score) |
| API failure/quota exceeded | Fallback score from Google rating |

---

## 🚀 Getting Started

### Prerequisites
- Xcode 15+
- iOS 16+
- Google Places API Key
- Gemini AI API Key

### Setup
1. Clone the repository
```bash
git clone https://github.com/yourusername/dishtime.git
```

2. Open `DishTime.xcodeproj` in Xcode

3. Add your API keys in `Config.plist`:
```
GooglePlacesAPIKey → your Google Places key
GeminiAPIKey → your Gemini AI Studio key
```

4. Build and run on simulator or device

---

## 📁 Project Structure
```
DishTime/
├── Models/
│   └── Restaurant.swift
├── Views/
│   ├── HomeView.swift
│   ├── ResultsView.swift
│   ├── DetailView.swift
│   └── ErrorView.swift
├── ViewModels/
│   └── SearchViewModel.swift
├── Services/
│   ├── GooglePlacesService.swift
│   └── GeminiService.swift
└── Config.plist
```

---

## 👨‍💻 Developer
Built with ❤️ as a personal iOS project to solve real everyday problems.

---

## 📄 License
This project is for personal and educational use.
