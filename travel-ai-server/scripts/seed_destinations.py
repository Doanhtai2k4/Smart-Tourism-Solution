import os
from datetime import datetime, timezone
from pathlib import Path

import firebase_admin
from firebase_admin import credentials, firestore


ROOT_DIR = Path(__file__).resolve().parent.parent
CRED_PATH = ROOT_DIR / "serviceAccountKey.json"

DESTINATIONS = [
    {
        "id": "da-nang",
        "name": "Da Nang",
        "province": "Da Nang",
        "category": "Biển",
        "tags": ["biển", "ẩm thực", "gia đình"],
        "latitude": 16.0544,
        "longitude": 108.2022,
        "description": "Thành phố biển năng động với bãi biển đẹp, ẩm thực phong phú và nhiều điểm tham quan.",
        "imageQuery": "Da Nang beach Vietnam",
        "topActivities": ["Tắm biển", "Khám phá Sơn Trà", "Thưởng thức ẩm thực"],
    },
    {
        "id": "ha-noi",
        "name": "Ha Noi",
        "province": "Ha Noi",
        "category": "Văn hóa",
        "tags": ["văn hóa", "ẩm thực", "lịch sử"],
        "latitude": 21.0285,
        "longitude": 105.8542,
        "description": "Thủ đô nghìn năm văn hiến với phố cổ, di tích lịch sử và ẩm thực đặc sắc.",
        "imageQuery": "Hanoi Old Quarter Vietnam",
        "topActivities": ["Tham quan phố cổ", "Khám phá bảo tàng", "Ăn street food"],
    },
    {
        "id": "phu-quoc",
        "name": "Phu Quoc",
        "province": "Kien Giang",
        "category": "Biển",
        "tags": ["biển", "nghỉ dưỡng", "gia đình"],
        "latitude": 10.2899,
        "longitude": 103.9840,
        "description": "Đảo ngọc với biển xanh, hoàng hôn đẹp và những khu nghỉ dưỡng ven biển.",
        "imageQuery": "Phu Quoc island beach Vietnam",
        "topActivities": ["Lặn ngắm san hô", "Ngắm hoàng hôn", "Thăm chợ đêm"],
    },
    {
        "id": "sa-pa",
        "name": "Sa Pa",
        "province": "Lao Cai",
        "category": "Núi",
        "tags": ["núi", "mạo hiểm", "văn hóa"],
        "latitude": 22.3364,
        "longitude": 103.8438,
        "description": "Thị trấn vùng cao nổi tiếng với ruộng bậc thang, khí hậu mát mẻ và văn hóa bản địa.",
        "imageQuery": "Sapa rice terraces Vietnam",
        "topActivities": ["Trekking", "Chinh phục Fansipan", "Thăm bản làng"],
    },
    {
        "id": "nha-trang",
        "name": "Nha Trang",
        "province": "Khanh Hoa",
        "category": "Biển",
        "tags": ["biển", "nghỉ dưỡng", "ẩm thực"],
        "latitude": 12.2388,
        "longitude": 109.1967,
        "description": "Thành phố biển sôi động với vịnh đẹp, đảo nhỏ và nhiều hoạt động dưới nước.",
        "imageQuery": "Nha Trang beach Vietnam",
        "topActivities": ["Đi đảo", "Lặn biển", "Tắm bùn"],
    },
    {
        "id": "da-lat",
        "name": "Da Lat",
        "province": "Lam Dong",
        "category": "Nghỉ dưỡng",
        "tags": ["núi", "nghỉ dưỡng", "ẩm thực"],
        "latitude": 11.9404,
        "longitude": 108.4583,
        "description": "Thành phố ngàn hoa lãng mạn với khí hậu se lạnh, đồi thông và cà phê đặc sản.",
        "imageQuery": "Da Lat Vietnam pine forest",
        "topActivities": ["Săn mây", "Thăm vườn hoa", "Khám phá quán cà phê"],
    },
    {
        "id": "ho-chi-minh-city",
        "name": "Ho Chi Minh City",
        "province": "Ho Chi Minh City",
        "category": "Văn hóa",
        "tags": ["văn hóa", "ẩm thực", "thành phố"],
        "latitude": 10.8231,
        "longitude": 106.6297,
        "description": "Đô thị sôi động với di tích lịch sử, khu phố đa văn hóa và ẩm thực đường phố.",
        "imageQuery": "Ho Chi Minh City Vietnam skyline",
        "topActivities": ["Tham quan di tích", "Ăn street food", "Khám phá chợ"],
    },
    {
        "id": "hoi-an",
        "name": "Hoi An",
        "province": "Quang Nam",
        "category": "Văn hóa",
        "tags": ["văn hóa", "lịch sử", "ẩm thực"],
        "latitude": 15.8801,
        "longitude": 108.3380,
        "description": "Phố cổ bên sông với đèn lồng, kiến trúc di sản và nền ẩm thực duyên dáng.",
        "imageQuery": "Hoi An ancient town Vietnam",
        "topActivities": ["Đi bộ phố cổ", "Thả đèn hoa đăng", "Đạp xe làng quê"],
    },
    {
        "id": "ha-giang",
        "name": "Ha Giang",
        "province": "Ha Giang",
        "category": "Mạo hiểm",
        "tags": ["núi", "mạo hiểm", "văn hóa"],
        "latitude": 22.7662,
        "longitude": 104.9389,
        "description": "Cung đường núi hùng vĩ dành cho những chuyến phượt và khám phá vùng cao.",
        "imageQuery": "Ha Giang loop Vietnam mountains",
        "topActivities": ["Đi xe máy", "Ngắm đèo Mã Pí Lèng", "Thăm chợ vùng cao"],
    },
    {
        "id": "ninh-binh",
        "name": "Ninh Binh",
        "province": "Ninh Binh",
        "category": "Thiên nhiên",
        "tags": ["thiên nhiên", "văn hóa", "gia đình"],
        "latitude": 20.2506,
        "longitude": 105.9745,
        "description": "Vùng non nước với sông ngầm, núi đá vôi và những di sản văn hóa đặc sắc.",
        "imageQuery": "Ninh Binh Trang An Vietnam",
        "topActivities": ["Đi thuyền Tràng An", "Thăm chùa", "Đạp xe"],
    },
    {
        "id": "ha-long-bay",
        "name": "Ha Long Bay",
        "province": "Quang Ninh",
        "category": "Thiên nhiên",
        "tags": ["biển", "thiên nhiên", "gia đình"],
        "latitude": 20.9101,
        "longitude": 107.1839,
        "description": "Di sản thiên nhiên thế giới với hàng nghìn đảo đá vôi giữa làn nước xanh.",
        "imageQuery": "Ha Long Bay Vietnam",
        "topActivities": ["Du thuyền", "Chèo kayak", "Thăm hang động"],
    },
]

DESTINATION_IMAGES = {
    "da-nang": "https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?auto=format&fit=crop&w=900&q=85",
    "ha-noi": "https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=900&q=85",
    "phu-quoc": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=900&q=85",
    "sa-pa": "https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=900&q=85",
    "nha-trang": "https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?auto=format&fit=crop&w=900&q=85",
    "da-lat": "https://images.unsplash.com/photo-1519501025264-65ba15a82390?auto=format&fit=crop&w=900&q=85",
    "ho-chi-minh-city": "https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&w=900&q=85",
    "hoi-an": "https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?auto=format&fit=crop&w=900&q=85",
    "ha-giang": "https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=900&q=85",
    "ninh-binh": "https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=900&q=85",
    "ha-long-bay": "https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=900&q=85",
}


def seed_destinations():
    if not CRED_PATH.exists():
        raise FileNotFoundError(f"Khong tim thay file: {CRED_PATH}")

    if not firebase_admin._apps:
        firebase_admin.initialize_app(credentials.Certificate(str(CRED_PATH)))

    db = firestore.client()
    now = datetime.now(timezone.utc)
    batch = db.batch()

    for destination in DESTINATIONS:
        destination_id = destination["id"]
        payload = {
            **destination,
            "images": [DESTINATION_IMAGES[destination_id]],
            "suitableFor": ["Solo", "Couples", "Family", "Friends"],
            "averageRating": 4.5,
            "ratingCount": 0,
            "viewCount": 0,
            "favoriteCount": 0,
            "trendingScore": len(DESTINATIONS) - DESTINATIONS.index(destination),
            "nameLowerCase": destination["name"].lower(),
            "country": "Viet Nam",
            "bestTimeToVisit": ["Quanh nam"],
            "budgetLevel": "$$",
            "idealDuration": 3,
            "searchKeywords": [destination["name"], *destination["tags"]],
            "createdAt": now,
            "updatedAt": now,
        }
        batch.set(db.collection("destinations").document(destination_id), payload, merge=True)

    batch.commit()
    print(f"Da seed {len(DESTINATIONS)} dia diem vao collection destinations.")


if __name__ == "__main__":
    seed_destinations()