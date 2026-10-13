import os
import random
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Avoid unicode errors on Windows stdout
import sys
try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

# Ensure reproducibility
random.seed(42)
np.random.seed(42)

# Output directory configuration
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), 'data')
os.makedirs(OUTPUT_DIR, exist_ok=True)

# -------------------------------------------------------------------------
# 1. INITIALIZE NAMES AND LOOKUP DATA
# -------------------------------------------------------------------------
vn_first_names_male = ["Nguyen", "Tran", "Le", "Pham", "Hoang", "Phan", "Vu", "Vo", "Dang", "Bui", "Do", "Ho", "Ngo", "Duong", "Ly"]
vn_middle_names_male = ["Van", "Duc", "Minh", "Anh", "Tuan", "Huu", "Quoc", "Xuan", "Thanh", "Cong", "Duy", "Hai"]
vn_last_names_male = ["Hung", "Cuong", "Tuan", "Dung", "Nam", "Khanh", "Trung", "Son", "Hai", "Lam", "Huy", "Tung", "Phong", "Bao"]

vn_first_names_female = ["Nguyen", "Tran", "Le", "Pham", "Hoang", "Phan", "Vu", "Vo", "Dang", "Bui", "Do", "Ho", "Ngo", "Duong", "Ly"]
vn_middle_names_female = ["Thi", "Hong", "Ngoc", "Thu", "Phuong", "Minh", "Truc", "Khanh", "Anh", "Cat", "Nhu", "My"]
vn_last_names_female = ["Hoa", "Lan", "Mai", "Cuc", "Vy", "Trang", "Linh", "Huong", "Anh", "Thao", "Ha", "Yen", "Chi", "Quynh"]

intl_first_names = ["James", "John", "Robert", "Michael", "William", "David", "Richard", "Joseph", "Thomas", "Charles", "Mary", "Patricia", "Jennifer", "Linda", "Elizabeth", "Barbara", "Susan", "Jessica", "Sarah", "Karen", "Kenji", "Hiroshi", "Yuki", "Min-ji", "Ji-woo", "Seo-jun", "Pierre", "Jean", "Charlotte", "Sophie"]
intl_last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Sato", "Suzuki", "Takahashi", "Kim", "Lee", "Park", "Martin", "Bernard", "Dubois", "Taylor"]

nationalities = ["Viet Nam", "USA", "France", "Japan", "South Korea", "Australia"]
travel_styles = ["Backpacking", "Luxury", "Adventure", "Culture/Historical", "Relaxation", "Family"]
budget_ranges = ["Low", "Medium", "High"]
device_types = ["Android", "iOS", "Web"]

# Locations
destinations_domestic = ["Da Nang", "Ha Noi", "Phu Quoc", "Sa Pa", "Nha Trang", "Da Lat", "Ho Chi Minh City", "Hoi An", "Ha Giang", "Ninh Binh", "Ha Long Bay"]
destinations_intl = ["Bangkok", "Singapore", "Tokyo", "Seoul", "Paris", "Sydney", "Bali"]

def generate_random_name(gender, nationality):
    if nationality == "Viet Nam":
        if gender == "Male":
            return f"{random.choice(vn_first_names_male)} {random.choice(vn_middle_names_male)} {random.choice(vn_last_names_male)}"
        else:
            return f"{random.choice(vn_first_names_female)} {random.choice(vn_middle_names_female)} {random.choice(vn_last_names_female)}"
    else:
        return f"{random.choice(intl_first_names)} {random.choice(intl_last_names)}"

# -------------------------------------------------------------------------
# 2. GENERATE USERS DATA
# -------------------------------------------------------------------------
num_users = 1000
users_data = []

# Budget probabilities correlated with travel styles for realistic logic
style_budget_prob = {
    "Backpacking": {"Low": 0.75, "Medium": 0.20, "High": 0.05},
    "Luxury": {"Low": 0.00, "Medium": 0.15, "High": 0.85},
    "Adventure": {"Low": 0.35, "Medium": 0.50, "High": 0.15},
    "Culture/Historical": {"Low": 0.20, "Medium": 0.60, "High": 0.20},
    "Relaxation": {"Low": 0.10, "Medium": 0.50, "High": 0.40},
    "Family": {"Low": 0.05, "Medium": 0.65, "High": 0.30}
}

print(f"Generating data for {num_users} users...")

start_date_range = datetime(2025, 6, 1)
end_date_range = datetime(2026, 5, 31)
date_delta = end_date_range - start_date_range

for i in range(1, num_users + 1):
    user_id = f"U{i:04d}"
    gender = random.choices(["Male", "Female", "Other"], weights=[0.48, 0.48, 0.04])[0]
    
    # 75% Viet Nam, 25% international
    nationality = random.choices(nationalities, weights=[0.75, 0.06, 0.04, 0.05, 0.06, 0.04])[0]
    name = generate_random_name(gender, nationality)
    
    # Realistic age distribution (peaks around 32)
    age = int(np.clip(np.random.normal(32, 10), 18, 70))
    
    # Registration date in the last year
    random_days = random.randint(0, date_delta.days)
    reg_date = start_date_range + timedelta(days=random_days, hours=random.randint(0, 23), minutes=random.randint(0, 59))
    
    travel_style = random.choice(travel_styles)
    
    budget_prob = style_budget_prob[travel_style]
    budget_range = random.choices(list(budget_prob.keys()), weights=list(budget_prob.values()))[0]
    
    # Travel duration average
    if travel_style in ["Backpacking", "Adventure"]:
        avg_duration = random.randint(5, 14)
    elif travel_style in ["Relaxation", "Luxury"]:
        avg_duration = random.randint(3, 7)
    else:
        avg_duration = random.randint(2, 6)
        
    # Active status
    is_active = random.choices([True, False], weights=[0.78, 0.22])[0]
    
    users_data.append({
        "user_id": user_id,
        "name": name,
        "age": age,
        "gender": gender,
        "nationality": nationality,
        "registration_date": reg_date.strftime("%Y-%m-%d %H:%M:%S"),
        "preferred_travel_style": travel_style,
        "budget_range": budget_range,
        "average_trip_duration": avg_duration,
        "is_active": is_active
    })

df_users = pd.DataFrame(users_data)
users_file = os.path.join(OUTPUT_DIR, 'users.csv')
df_users.to_csv(users_file, index=False, encoding='utf-8')
print(f"Successfully saved {len(df_users)} users to {users_file}")

# -------------------------------------------------------------------------
# 3. GENERATE ACTIVITIES DATA
# -------------------------------------------------------------------------
print("Generating user activity records...")
activities_data = []
activity_id_counter = 1

# Activity weights
activity_types = [
    "search_destination", "create_trip", "book_hotel", "book_flight", 
    "log_expense", "generate_packing_list", "check_weather", 
    "convert_currency", "send_chat_message"
]
activity_weights = [0.25, 0.12, 0.06, 0.04, 0.15, 0.08, 0.12, 0.08, 0.10]

for idx, user in df_users.iterrows():
    u_id = user["user_id"]
    u_reg_date = datetime.strptime(user["registration_date"], "%Y-%m-%d %H:%M:%S")
    u_active = user["is_active"]
    u_budget = user["budget_range"]
    u_style = user["preferred_travel_style"]
    u_nat = user["nationality"]
    
    # Inactive users churn quickly with very few activities
    if u_active:
        num_acts = random.randint(15, 45)
    else:
        num_acts = random.randint(2, 6)
        
    current_time = u_reg_date
    
    for _ in range(num_acts):
        if u_active:
            time_gap = timedelta(days=random.randint(0, 15), hours=random.randint(0, 23), minutes=random.randint(1, 59))
        else:
            time_gap = timedelta(days=random.randint(0, 2), hours=random.randint(0, 12), minutes=random.randint(1, 59))
            
        current_time += time_gap
        
        # Upper bound time limit (June 1st, 2026)
        if current_time > datetime(2026, 6, 1):
            break
            
        act_type = random.choices(activity_types, weights=activity_weights)[0]
        device = random.choices(device_types, weights=[0.55, 0.35, 0.10])[0]
        session_len = int(np.clip(np.random.normal(12, 8), 1, 60))
        
        # Domestic vs international destination preferences
        if u_nat == "Viet Nam":
            dest_pool = destinations_domestic * 4 + destinations_intl
        else:
            dest_pool = destinations_domestic * 6 + destinations_intl * 1
            
        # Filter destinations by style
        if u_style == "Luxury":
            dest_pool = [d for d in dest_pool if d in ["Phu Quoc", "Nha Trang", "Ha Long Bay", "Singapore", "Tokyo", "Paris", "Sydney"]]
            if not dest_pool:
                dest_pool = ["Phu Quoc", "Nha Trang"]
        elif u_style == "Backpacking":
            dest_pool = [d for d in dest_pool if d in ["Sa Pa", "Ha Giang", "Da Lat", "Hoi An", "Bangkok", "Bali", "Ninh Binh"]]
            if not dest_pool:
                dest_pool = ["Ha Giang", "Sa Pa"]
                
        destination = random.choice(dest_pool)
        
        spend = 0.0
        rating = np.nan
        
        if act_type == "book_hotel":
            if u_budget == "Low":
                spend = float(random.randint(250000, 750000))
            elif u_budget == "Medium":
                spend = float(random.randint(800000, 2500000))
            else: # High
                spend = float(random.randint(3000000, 15000000))
            rating = float(random.choices([5, 4, 3, 2, 1], weights=[0.5, 0.3, 0.12, 0.05, 0.03])[0])
            
        elif act_type == "book_flight":
            is_intl_dest = destination in destinations_intl
            if is_intl_dest:
                if u_budget == "Low":
                    spend = float(random.randint(3000000, 6000000))
                elif u_budget == "Medium":
                    spend = float(random.randint(6000000, 15000000))
                else:
                    spend = float(random.randint(15000000, 40000000))
            else: # Domestic
                if u_budget == "Low":
                    spend = float(random.randint(800000, 1500000))
                elif u_budget == "Medium":
                    spend = float(random.randint(1500000, 3000000))
                else:
                    spend = float(random.randint(3000000, 6000000))
            rating = float(random.choices([5, 4, 3, 2, 1], weights=[0.45, 0.35, 0.13, 0.05, 0.02])[0])
            
        elif act_type == "log_expense":
            if u_budget == "Low":
                spend = float(random.randint(30000, 250000))
            elif u_budget == "Medium":
                spend = float(random.randint(100000, 1000000))
            else:
                spend = float(random.randint(500000, 4000000))
                
        activities_data.append({
            "activity_id": f"ACT{activity_id_counter:06d}",
            "user_id": u_id,
            "timestamp": current_time.strftime("%Y-%m-%d %H:%M:%S"),
            "activity_type": act_type,
            "destination": destination,
            "spend_amount": spend,
            "device_type": device,
            "session_duration_minutes": session_len,
            "rating": rating
        })
        
        activity_id_counter += 1

df_activities = pd.DataFrame(activities_data)
activities_file = os.path.join(OUTPUT_DIR, 'activities.csv')
df_activities.to_csv(activities_file, index=False, encoding='utf-8')
print(f"Successfully saved {len(df_activities)} activities to {activities_file}")
print("Data generation complete!")
