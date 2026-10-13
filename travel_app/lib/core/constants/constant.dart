class Constant {
  static const jsonResponseExample = '''{
    "destination": "string",
    "currentLocation": "string",
    "currentLat": 0.0,
    "currentLng": 0.0,
    "destinationLat": 0.0,
    "destinationLng": 0.0,
    "startDate": "string",
    "endDate": "string",
    "overview": "string",
    "tripType": "string",
    "totalDays": 0,
    "totalPeople": 0,
    "images": [
      "string", 
      "string", 
      "string"
    ],
    "dailyPlan": [
      {
        "day": 0,
        "date": "string",
        "activities": [
          {
            "time": "string",
            "destinationId": "string",
            "description": "string"
          }
        ]
      }
    ],
    "accommodationSuggestions": [
      {
        "name": "string",
        "type": "string",
        "location": "string",
        "priceRange": "string"
      }
    ],
    "transportationDetails": {
      "localTransport": "string",
      "tips": "string"
    },
    "foodRecommendations": ["string"],
    "additionalTips": ["string"],
    "budget": "string"
  }''';
}
