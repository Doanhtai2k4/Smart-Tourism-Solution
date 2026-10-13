import os
import json
import random
import sys
from datetime import datetime, timedelta

# Ensure UTF-8 printing
try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

# Ensure reproducibility
random.seed(42)

# Paths
BASE_DIR = os.path.dirname(__file__)
DATA_DIR = os.path.join(BASE_DIR, 'data')
os.makedirs(DATA_DIR, exist_ok=True)

USERS_JSON_FILE = os.path.join(DATA_DIR, 'users_firebase.json')
TRIPS_JSON_FILE = os.path.join(DATA_DIR, 'trips_firebase.json')

print("Starting generation of Firebase-compliant JSON datasets...")

# -------------------------------------------------------------------------
# 1. SAMPLE DATA POOLS
# -------------------------------------------------------------------------
vn_names = [
    "Nguyen Minh Tri", "Tran Thi Hoa", "Le Hoang Nam", "Pham Ngoc Lan", "Hoang Duc Trung",
    "Phan Thanh Thao", "Vu Quoc Huy", "Dang Minh Thu", "Bui Xuan An", "Do Khanh Linh",
    "Ngo Huu Phuoc", "Duong Cat Tuong", "Ly Minh Triet", "Hoang Bao Ngoc", "Tran Van Cuong",
    "Nguyen Thi Huong", "Pham Van Son", "Bui Hong Hanh", "Vu Viet Tuan", "Le My Duyen"
]

intl_names = [
    "John Smith", "Emily Johnson", "David Miller", "Sarah Connor", "Kenji Sato",
    "Yuki Takahashi", "Min-ji Kim", "Ji-woo Park", "Pierre Bernard", "Sophie Martin"
]

nationalities = ["Viet Nam", "USA", "France", "Japan", "South Korea", "Australia"]
genders = ["Male", "Female"]
occupations = ["Software Engineer", "Student", "Marketing Specialist", "Graphic Designer", "Doctor", "Teacher", "Business Analyst"]
hobbies_pool = ["photography", "foodie", "hiking", "swimming", "reading", "gaming", "music", "sketching", "cooking"]

destinations_pool = [
    {"name": "Da Nang", "lat": 16.0544, "lng": 108.2022, "type": "relaxation"},
    {"name": "Ha Noi", "lat": 21.0285, "lng": 105.8542, "type": "culture"},
    {"name": "Phu Quoc", "lat": 10.2899, "lng": 103.9840, "type": "relaxation"},
    {"name": "Sa Pa", "lat": 22.3364, "lng": 103.8438, "type": "adventure"},
    {"name": "Nha Trang", "lat": 12.2388, "lng": 109.1967, "type": "relaxation"},
    {"name": "Da Lat", "lat": 11.9404, "lng": 108.4583, "type": "relaxation"},
    {"name": "Ho Chi Minh City", "lat": 10.8231, "lng": 106.6297, "type": "culture"},
    {"name": "Hoi An", "lat": 15.8801, "lng": 108.3380, "type": "culture"},
    {"name": "Ha Giang", "lat": 22.8233, "lng": 104.9835, "type": "adventure"}
]

# -------------------------------------------------------------------------
# 2. GENERATE USERS DATA (30 users)
# -------------------------------------------------------------------------
num_users = 30
users = []

for i in range(1, num_users + 1):
    uid = f"auth_uid_{i:04d}"
    gender = random.choice(genders)
    
    # 80% Vietnamese, 20% international
    if random.random() < 0.8:
        name = vn_names[(i - 1) % len(vn_names)]
        country = "Viet Nam"
    else:
        name = intl_names[(i - 1) % len(intl_names)]
        country = random.choice(nationalities[1:])
        
    email = f"{name.lower().replace(' ', '')}@example.com"
    age = random.randint(20, 50)
    
    # Calculate date of birth
    dob = datetime.now() - timedelta(days=age * 365 + random.randint(0, 364))
    
    # Registration date in last 6 months
    created_at = datetime.now() - timedelta(days=random.randint(10, 180))
    
    # Hobbies & Favorites
    hobbies = random.sample(hobbies_pool, random.randint(2, 4))
    favorites = [f"trip_{random.randint(1, 15):04d}" for _ in range(random.randint(0, 3))]
    
    users.append({
        "uid": uid,
        "email": email,
        "name": name,
        "profilePic": f"https://api.dicebear.com/7.x/adventurer/svg?seed={name.replace(' ', '')}",
        "isAuthenticated": True,
        "dateOfBirth": dob.strftime("%Y-%m-%d"),
        "gender": gender,
        "country": country,
        "occupation": random.choice(occupations),
        "hobbies": hobbies,
        "favorites": favorites,
        "phoneNumber": f"+8490{random.randint(1000000, 9999999)}",
        "bio": f"Hi, I am {name}. I love exploring new destinations and local foods!",
        "createdAt": created_at.isoformat() + "Z"
    })

# Write users json
with open(USERS_JSON_FILE, 'w', encoding='utf-8') as f:
    json.dump(users, f, ensure_ascii=False, indent=2)
print(f"Successfully generated {len(users)} users matching UserModel in {USERS_JSON_FILE}")

# -------------------------------------------------------------------------
# 3. GENERATE TRIPS & EXPENSES DATA (1-2 trips per user)
# -------------------------------------------------------------------------
trips = []
trip_id_counter = 1
expense_id_counter = 1

expense_titles = {
    "food": ["Ăn sáng phở Lý Quốc Sư", "Ăn trưa cơm niêu", "Uống cà phê Cộng", "Ăn tối hải sản", "Ăn vặt bánh tráng trộn"],
    "transport": ["Thuê xe máy tự lái", "Grab đi sân bay", "Vé máy bay khứ hồi", "Xăng xe di chuyển", "Vé taxi về khách sạn"],
    "accommodation": ["Thanh toán Homestay ngày 1", "Đặt phòng khách sạn Mường Thanh", "Đặt phòng Resort 4 sao", "Phí phụ thu nhận phòng sớm"],
    "shopping": ["Mua quà lưu niệm", "Mua đặc sản địa phương", "Mua quần áo đi biển", "Mua sắm tại chợ đêm"],
    "entertainment": ["Vé cáp treo Bà Nà Hills", "Vé vào cổng KDL Sun World", "Vé chèo thuyền Kayak", "Vé xem biểu diễn nghệ thuật"],
    "other": ["Phí bảo hiểm du lịch", "Phí gửi đồ hành lý", "Mua thuốc men dự phòng"]
}

for user in users:
    u_uid = user["uid"]
    u_name = user["name"]
    u_reg_date = datetime.fromisoformat(user["createdAt"].replace('Z', ''))
    
    # 1 or 2 trips per user
    num_user_trips = random.choice([1, 2])
    
    for t_idx in range(num_user_trips):
        trip_id = f"trip_{trip_id_counter:04d}"
        dest_info = random.choice(destinations_pool)
        dest_name = dest_info["name"]
        
        # Chronological dates (starts 10-60 days after registration)
        start_date = u_reg_date + timedelta(days=random.randint(10, 60))
        end_date = start_date + timedelta(days=random.randint(3, 7))
        
        total_days = (end_date - start_date).days
        total_people = random.randint(1, 4)
        
        budget_level = random.choice(["Low", "Medium", "High"])
        budget_amounts = {"Low": "2,000,000 VND", "Medium": "6,000,000 VND", "High": "15,000,000 VND"}
        
        # Status matching logic
        # If trip end date is in the past, it's visited, otherwise planned
        now = datetime.now()
        if end_date < now:
            status = "visited"
            is_visited = True
        else:
            status = "planned"
            is_visited = False
            
        # Daily Plan structure matching DayPlan model in Dart
        daily_plans = []
        for d in range(1, total_days + 1):
            daily_plans.append({
                "day": d,
                "theme": f"Khám phá ngày {d} tại {dest_name}",
                "activities": [
                    {
                        "time": "08:00",
                        "activity": "Ăn sáng và thưởng thức cà phê địa phương",
                        "location": f"Quán ăn đặc sản {dest_name}",
                        "notes": "Nên đi sớm để tránh đông khách"
                    },
                    {
                        "time": "10:30",
                        "activity": "Tham quan địa điểm nổi tiếng",
                        "location": f"Khu du lịch sinh thái {dest_name}",
                        "notes": "Mang theo máy ảnh và kem chống nắng"
                    },
                    {
                        "time": "18:30",
                        "activity": "Ăn tối hải sản và dạo chợ đêm",
                        "location": f"Khu phố ẩm thực {dest_name}",
                        "notes": "Thử các món ăn đường phố"
                    }
                ]
            })
            
        # Accommodations
        accommodations = [
            {
                "name": f"Khách sạn {dest_name} Boutique",
                "type": "Hotel",
                "priceRange": "500.000 - 1.500.000 VND",
                "rating": 4.5,
                "address": f"Số 12 Đường ven biển, {dest_name}"
            }
        ]
        
        # 3 to 5 expenses for this trip
        expenses = []
        num_expenses = random.randint(3, 5)
        for e in range(num_expenses):
            category = random.choice(list(expense_titles.keys()))
            title = random.choice(expense_titles[category])
            
            # Amount based on category and budget_level
            if category == "accommodation":
                amount = float(random.randint(400000, 1500000))
            elif category == "transport":
                amount = float(random.randint(100000, 800000))
            elif category == "food":
                amount = float(random.randint(50000, 250000))
            else:
                amount = float(random.randint(30000, 300000))
                
            if budget_level == "High":
                amount *= 2.5
            elif budget_level == "Low":
                amount *= 0.6
                
            expense_date = start_date + timedelta(days=random.randint(0, total_days - 1), hours=random.randint(8, 20))
            
            expenses.append({
                "id": f"exp_{expense_id_counter:05d}",
                "tripId": trip_id,
                "payerId": u_uid,
                "payerName": u_name,
                "title": title,
                "amount": round(amount, -3), # Round to nearest thousand
                "category": category,
                "date": expense_date.isoformat() + "Z",
                "splitWith": [u_uid]
            })
            expense_id_counter += 1
            
        trips.append({
            "travelId": trip_id,
            "userId": u_uid,
            "createdAt": u_reg_date.isoformat() + "Z",
            "updatedAt": (u_reg_date + timedelta(hours=2)).isoformat() + "Z",
            "destination": dest_name,
            "destinationLowerCase": dest_name.lower(),
            "currentLocation": "Ha Noi" if dest_name != "Ha Noi" else "Da Nang",
            "currentLat": 21.0285 if dest_name != "Ha Noi" else 16.0544,
            "currentLng": 105.8542 if dest_name != "Ha Noi" else 108.2022,
            "destinationLat": dest_info["lat"],
            "destinationLng": dest_info["lng"],
            "startDate": start_date.strftime("%Y-%m-%d"),
            "endDate": end_date.strftime("%Y-%m-%d"),
            "overview": f"Chuyến đi khám phá {dest_name} đầy hứa hẹn dành cho các tín đồ yêu thích {dest_info['type']}.",
            "tripType": dest_info["type"],
            "totalDays": total_days,
            "totalPeople": total_people,
            "images": [
                f"https://images.unsplash.com/photo-1555215695-3004980ad54e?q=80&w=600"
            ],
            "dailyPlan": daily_plans,
            "accommodationSuggestions": accommodations,
            "transportationDetails": {
                "localTransport": "Xe máy tự lái, taxi truyền thống",
                "tips": "Nên hỏi giá trước khi đi và thuê xe máy tại homestay để tiết kiệm chi phí"
            },
            "foodRecommendations": [
                f"Đặc sản ẩm thực đường phố {dest_name}",
                f"Quán hải sản tươi sống giá rẻ tại trung tâm {dest_name}"
            ],
            "additionalTips": [
                "Mang theo đầy đủ giấy tờ tùy thân",
                "Nên mang giày thể thao để di chuyển tham quan dễ dàng"
            ],
            "budget": budget_amounts[budget_level],
            "budgetType": budget_level,
            "companions": random.choice(["Solo", "Couples", "Family", "Friends"]),
            "accommodationType": "Homestay",
            "transportPreferences": "Xe máy",
            "pace": random.choice(["Relaxed", "Medium", "Fast"]),
            "foodPreference": "Ẩm thực địa phương",
            "interests": random.sample(hobbies_pool, 2),
            "isFavorite": random.random() < 0.2,
            "isVisited": is_visited,
            "status": status,
            "visitedAt": end_date.isoformat() + "Z" if is_visited else None,
            "language": "vi",
            "generatedByAi": True,
            "share_code": f"SHARE_{random.randint(1000, 9999)}",
            "member_ids": [u_uid],
            "ownerName": u_name,
            "ownerPhoto": f"https://api.dicebear.com/7.x/adventurer/svg?seed={u_name.replace(' ', '')}",
            
            # Temporary store expenses so import script can easily access them!
            "expenses": expenses
        })
        
        trip_id_counter += 1

# Write trips json
with open(TRIPS_JSON_FILE, 'w', encoding='utf-8') as f:
    json.dump(trips, f, ensure_ascii=False, indent=2)

print(f"Successfully generated {len(trips)} trips matching TravelDbModel in {TRIPS_JSON_FILE}")
print(f"Also embedded {(expense_id_counter - 1)} expenses matching ExpenseModel.")
print("Firebase-compliant datasets successfully saved!")
