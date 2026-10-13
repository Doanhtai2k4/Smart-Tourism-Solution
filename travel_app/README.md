# 🌟 TRIPHERO - Ứng dụng hỗ trợ lên lịch trình du lịch thông minh với AI & Hệ thống gợi ý cá nhân hóa

> **Đồ án tốt nghiệp:** NGHIÊN CỨU VÀ PHÁT TRIỂN ỨNG DỤNG ĐA NỀN TẢNG HỖ TRỢ LÊN KẾ HOẠCH DU LỊCH DỰA TRÊN AI TẠO SINH VÀ HỆ THỐNG GỢI Ý CÁ NHÂN HÓA  
> **Thực hiện:** Nguyễn Văn Hòa (Lớp: 22SE1B - Khoa Khoa học Máy tính)  
> **Giảng viên hướng dẫn:** ThS. Võ Ngọc Đạt  
> **Trường:** Đại học Công nghệ Thông tin và Truyền thông Việt - Hàn (VKU)

---

## 📋 MỤC LỤC

1. [Giới thiệu dự án](#-giới-thiệu-dự-án)
2. [Kiến trúc hệ thống](#-kiến-trúc-hệ-thống)
3. [Yêu cầu phiên bản](#-yêu-cầu-phiên-bản)
4. [Cấu hình dự án](#-cấu-hình-dự-án)
5. [Hướng dẫn cài đặt](#-hướng-dẫn-cài-đặt)
6. [Chức năng hệ thống](#-chức-năng-hệ-thống)
7. [Build & Deploy](#-build--deploy)
8. [API Endpoints](#-api-endpoints)
9. [Troubleshooting](#-troubleshooting)

---

## 🎯 GIỚI THIỆU DỰ ÁN

**TripHero** là giải pháp hỗ trợ lên kế hoạch du lịch thông minh toàn diện, tích hợp trí tuệ nhân tạo (Generative AI) và học máy (Machine Learning) bao gồm:
- **Mobile App (Flutter)**: Ứng dụng di động đa nền tảng viết bằng Flutter dành cho người dùng (khách du lịch) lập kế hoạch, xem bản đồ, quản lý chi tiêu và tương tác với AI.
- **Backend Service (Python/FastAPI)**: Hệ thống API Monolith xử lý các thuật toán ML Recommender, AI Trip Planner, Chatbot, và phân tích phân khúc người dùng.
- **Database & Data Server (Firebase/Firestore)**: Đồng bộ hóa cơ sở dữ liệu đám mây thời gian thực, lưu trữ thông tin chuyến đi, các hoạt động tương tác, và chạy các script di trú dữ liệu ban đầu.

### Tính năng nổi bật:
- 🤖 **AI Chatbot**: Trợ lý ảo hỗ trợ tư vấn du lịch, ghi nhớ ngữ cảnh chuyến đi và lịch sử hội thoại (Groq AI + Llama-3).
- 📅 **AI Trip Planner (RAG)**: Tự động thiết kế lịch trình du lịch chi tiết dưới dạng JSON, nạp danh sách địa điểm gợi ý từ mô hình học máy (hoặc địa điểm thịnh hành làm Fallback) làm ngữ cảnh (Retrieval-Augmented Generation).
- 🎯 **Gợi ý Cá nhân hóa**: Đề xuất địa điểm tối ưu cho từng người dùng dựa trên mô hình **Two-Tower Neural Network (TensorFlow Recommenders)**.
- 📊 **Phân cụm người dùng**: Tự động dán nhãn phân khúc người dùng (*Luxury Elites, Active Budget Backpackers, Standard Vacationers, Occasional / Churned*) bằng thuật toán **K-Means Clustering (Scikit-Learn)** và kết xuất biểu đồ trực quan (PCA 2D, Spending Analysis).
- 🗺️ **Bản đồ tương tác**: Hiển thị đường đi, vị trí các địa điểm du lịch bằng `flutter_map` trỏ về OpenStreetMap.
- 🚨 **Hỗ trợ khẩn cấp (Emergency)**: Cung cấp danh bạ khẩn cấp, hướng dẫn sơ cứu y tế và vị trí Đại sứ quán.
- 🎒 **Packing List**: Tự động gợi ý hành lý cần chuẩn bị dựa theo thời tiết và sự kiện tại điểm đến.

---

## 🏗️ KIẾN TRÚC HỆ THỐNG

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           TRIPHERO ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌────────────────┐           REST API Request          ┌──────────────┐│
│  │  Flutter App   │────────────────────────────────────▶│ Unified API  ││
│  │ (Mobile Client)│◀────────────────────────────────────│  (FastAPI)   ││
│  │  Port: N/A     │           JSON Response             │  Port: 8000  ││
│  └────────────────┘                                     └──────┬───────┘│
│          │                                                     │        │
│          │ Firebase Auth, Firestore Sync,                      │        │
│          │ Firebase Storage                                    │        │
│          ▼                                                     │        │
│  ┌────────────────┐                                            │        │
│  │ Firebase Cloud │◀───────────────────────────────────────────┤        │
│  │ (Authentication│                                            │        │
│  │  & Firestore)  │                                            │        │
│  └────────────────┘                                            ▼        │
│                                                     ┌──────────────────┐│
│                                                     │   Two-Tower ML   ││
│  ┌────────────────┐                                 │ (TensorFlow Rec) ││
│  │  Groq AI API   │◀────────────────────────────────└──────────┬───────┘│
│  │ (Llama-3 LLM)  │                                            │        │
│  └────────────────┘                                            ▼        │
│                                                     ┌──────────────────┐│
│  ┌────────────────┐                                 │ K-Means Analysis ││
│  │  Unsplash API  │◀────────────────────────────────│  (Scikit-Learn)  ││
│  │ (Cover Images) │                                 └──────────────────┘│
│  └────────────────┘                                                     │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 YÊU CẦU PHIÊN BẢN

### Mobile App (Flutter)
| Thành phần | Phiên bản | Ghi chú |
|------------|-----------|---------|
| **Flutter SDK** | `>=3.10.7` | Stable channel |
| **Dart SDK** | `>=3.10.7 <4.0.0` | Đi kèm Flutter |
| **Riverpod** | `^4.0.0` | State management & Code generator |
| **Go Router** | `Latest` | Routing |
| **Google Generative AI** | `^0.4.7` | Gemini API cho client-side |
| **Flutter Map** | `^6.0.0` | Bản đồ OpenStreetMap |
| **JDK (Java)** | `17` | Bắt buộc cho gradle Android |

### Backend API (Python/FastAPI)
| Thành phần | Phiên bản | Ghi chú |
|------------|-----------|---------|
| **Python** | `3.9` đến `3.11` | Khuyên dùng 3.10 để tương thích TensorFlow |
| **FastAPI** | `0.115.12` | Web API framework |
| **Uvicorn** | `0.34.0` | ASGI Web Server |
| **TensorFlow** | `2.20.0` | Học máy xây dựng mạng neural |
| **TensorFlow Recommenders**| `0.7.3` | Thư viện xây dựng mô hình Two-Tower |
| **TF-Keras** | `~=2.16` | Keras legacy support |
| **Firebase Admin** | `6.7.0` | Kết nối & thao tác Firestore |
| **Numpy / Pandas** | `2.1.3` (numpy) | Tiền xử lý & biến đổi dữ liệu |
| **Scikit-Learn** | `Latest` | Thuật toán K-Means và PCA |
| **Groq SDK** | `>=0.9.0` | Client gọi Llama-3/Llama-3.3 LLM |
| **APScheduler** | `>=3.10.0` | Quản lý tiến trình retrain ngầm định kỳ |

---

## ⚙️ CẤU HÌNH DỰ ÁN

### 📁 1. Flutter Mobile App Configuration

#### File: `travel_app/.env` (Tạo ở thư mục gốc của Flutter)
```env

# Groq API Key (Dùng để tạo lịch trình, Sử dụng cho AI chat)
GROQ_API_KEY=YOUR_GROQ_KEY

# OpenWeather API Key (Dùng để xem thời tiết)
WEATHER_API_KEY=YOUR_WEATHER_API_KEY

# Unsplash Access Key (Dùng để tải ảnh minh họa điểm đến)
UNSPLASH_ACCESS_KEY=YOUR_UNSPLASH_KEY

# URL gốc của Gemini API
BASE_URL=https://generativelanguage.googleapis.com/v1/
```

#### File: `travel_app/lib/core/constants/api_constants.dart`
```dart
static const String renderUrl = 'https://travel-ai-server-14w0.onrender.com';
static bool useRender = true; // Chuyển thành true để dùng server Render, false để dùng Localhost (10.0.2.2)
```

#### File: `travel_app/android/app/google-services.json`
**Cách lấy:**
1. Tạo project trên Firebase Console: https://console.firebase.google.com/
2. Đăng ký app với package name: `com.hoadev.travel_app`
3. Chạy lệnh `./gradlew signingReport` trong thư mục `android/` để lấy mã SHA-1 cấu hình Google Sign-in.
4. Tải file `google-services.json` đặt vào thư mục `travel_app/android/app/`.

---

### 📁 2. Backend Configuration (FastAPI)

#### File: `triphero_api/.env` (Tạo ở thư mục gốc của FastAPI)
```env
GROQ_API_KEY=gsk_your_groq_api_key_here
UNSPLASH_ACCESS_KEY=your_unsplash_access_key_here
```

#### File: `triphero_api/serviceAccountKey.json`
**Cách lấy:**
1. Trên Firebase Console, vào **Project Settings** → **Service Accounts**.
2. Click **Generate new private key** để tải file JSON xác thực Admin.
3. Đổi tên file tải về thành `serviceAccountKey.json` và lưu vào thư mục gốc của `triphero_api/`.

#### Thư mục mô hình: `triphero_api/two_tower_model/`
Mô hình học máy Two-Tower được lưu trữ dưới dạng `SavedModel` của TensorFlow. Cấu trúc thư mục bắt buộc:
```
two_tower_model/
├── assets/
├── variables/
│   ├── variables.data-00000-of-00001
│   └── variables.index
└── saved_model.pb
```
*Lưu ý: Nếu thiếu thư mục này, server sẽ tự động chạy ở chế độ Fallback đề xuất địa điểm thịnh hành chung.*

---

## 🚀 HƯỚNG DẪN CÀI ĐẶT

### Bước 1: Clone Repository

```bash
git clone https://github.com/hoaDaiNhan74/travel_app.git
cd travel_app
```

### Bước 2: Cài đặt Flutter Mobile App

1. Tải các thư viện phụ thuộc:
```bash
flutter pub get
```
2. Chạy code generation để tự động sinh mã Riverpod/Freezed:
```bash
dart run build_runner build --delete-conflicting-outputs
```
3. Cấu hình file `.env` và `google-services.json` như hướng dẫn ở trên.

### Bước 3: Cài đặt Backend Service (FastAPI)

1. Di chuyển sang thư mục API và tạo môi trường ảo:
```bash
cd ../triphero_api
python -m venv venv
```
2. Kích hoạt môi trường ảo:
   - **Windows (PowerShell)**: `.\venv\Scripts\activate`
   - **Linux/macOS**: `source venv/bin/activate`
3. Cài đặt các thư viện:
```bash
pip install -r requirements.txt
```
*(Khuyên dùng công cụ `uv` nếu có sẵn để tăng tốc độ cài đặt: `uv pip install -r requirements.txt`).*

### Bước 4: Đổ dữ liệu mẫu (Database Migration)
Trước khi chạy hệ thống lần đầu, bạn cần khởi tạo dữ liệu trên Cloud Firestore:
```bash
# 1. Đẩy danh sách địa điểm du lịch ban đầu lên Firestore
python scripts/migrate_destinations.py

# 2. Đổ dữ liệu tương tác người dùng mẫu phục vụ huấn luyện hệ thống gợi ý
python scripts/seed_real_interactions.py
```

### Bước 5: Khởi chạy các dịch vụ

```bash
# Khởi chạy server FastAPI (Chạy main.py cấu hình tối ưu, không block RAM)
python main.py
```
- Truy cập Swagger UI kiểm tra API: [http://localhost:8000/docs](http://localhost:8000/docs)
- Endpoint kiểm tra sức khỏe: `http://localhost:8000/health`

```bash
# Chạy Flutter Mobile App
cd ../travel_app
flutter run
```

---

## 💡 CHỨC NĂNG HỆ THỐNG

### 📱 FLUTTER MOBILE APP (Người dùng)

#### 🔐 Xác thực & Tài khoản
| Chức năng | Mô tả | File/Screen chính |
|-----------|-------|-------------|
| **Đăng nhập** | Email/Password hoặc Google Sign-in (OAuth2). | `login_screen.dart` |
| **Đăng ký** | Tạo tài khoản mới, đồng bộ hồ sơ lên Firestore. | `register_screen.dart` |
| **Hồ sơ cá nhân** | Quản lý thông tin, đổi ảnh đại diện qua Storage. | `profile_screen.dart` |

#### 📅 Lên kế hoạch du lịch (AI Trip Planner)
| Chức năng | Mô tả |
|-----------|-------|
| **Tạo chuyến đi** | Người dùng nhập điểm đến, số ngày, ngân sách, thể loại ưa thích. |
| **AI Generator (RAG)**| Server FastAPI gọi Groq AI kết xuất lịch trình chi tiết dạng JSON dựa trên địa điểm đề xuất từ Two-Tower model. |
| **Bản đồ hành trình** | Trực quan hóa lộ trình di chuyển của các ngày trên bản đồ `flutter_map`. |
| **Quản lý chi tiêu** | Ghi chép hóa đơn và tổng chi tiêu chung của chuyến đi. |
| **Chia sẻ chuyến đi** | Mời bạn bè tham gia chỉnh sửa chung thông qua mã chia sẻ (`share_code`). |

#### 🤖 Các tính năng thông minh khác
| Chức năng | Mô tả |
|-----------|-------|
| **Personalized Recommend**| Danh sách địa điểm gợi ý cá nhân hóa xếp đầu tiên tại màn hình Khám phá. |
| **AI Chatbot** | Hỗ trợ giải đáp, gợi ý quán ăn, khách sạn theo thời gian thực. |
| **Packing List** | Tự động lập danh sách hành lý tương ứng với thời tiết tại điểm đến. |
| **Emergency Support** | Tra cứu cẩm nang sơ cứu, số điện thoại khẩn cấp, địa chỉ Đại sứ quán. |

---

### ⚙️ BACKEND API (FastAPI & Machine Learning)

#### AI & Recommendation Services
- **Personalized Recommendation Engine**: Chạy mô hình Two-Tower để so khớp vector biểu diễn sở thích người dùng (User Tower) với đặc trưng địa điểm (Destination Tower), trả về danh sách top 10 địa điểm phù hợp nhất.
- **RAG-Augmented Itinerary Generator**: Lớp [AiService](file:///D:/DACN2/triphero_api/services/ai_service.py) kết hợp Prompt Engineering với dữ liệu context (địa điểm gợi ý, thời tiết, sự kiện) để Groq LLM sinh ra lịch trình tối ưu.
- **User Segmentation Pipeline**: Tiền xử lý dữ liệu (StandardScaler), chạy thuật toán **K-Means (K=4)** định kỳ để dán nhãn phân khúc người dùng, dán nhãn ngược về Firestore, và dùng PCA giảm chiều xuất ảnh đồ thị phân cụm.
- **Retrain Pipeline**: Tự động hóa tiến trình kéo tương tác mới trong 30 ngày qua trên Firestore, huấn luyện lại Two-Tower model qua 15 epochs, xuất mô hình BruteForce và cập nhật hot-swap mô hình trực tiếp không cần ngắt server.

---

## 🔨 BUILD & DEPLOY

### Triển khai Backend lên Render.com
Server FastAPI đã được thiết kế sẵn sàng cho việc deploy lên Render:
1. **Build Command**: `pip install -r requirements.txt`
2. **Start Command** (sử dụng [Procfile](file:///D:/DACN2/triphero_api/Procfile) với Gunicorn):
   ```text
   web: gunicorn -w 1 -k uvicorn.workers.UvicornWorker main:app --timeout 120
   ```
3. **Environment Variables**: Cấu hình `GROQ_API_KEY` và `UNSPLASH_ACCESS_KEY` trên dashboard của Render.
4. **Health Check Path**: Thiết lập `/health` để Render tự động đánh thức / khởi chạy lại container.

### Build Flutter Mobile App
```bash
cd travel_app

# Build APK Release cho Android
flutter build apk --release
# Tệp xuất ra tại: build/app/outputs/flutter-apk/app-release.apk

# Build Android App Bundle (để tải lên Google Play Console)
flutter build appbundle --release
```

---

## 📡 API ENDPOINTS

### Base URL
- **Local:** `http://localhost:8000`
- **Render Production:** `https://travel-ai-server-14w0.onrender.com`

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/` | Kiểm tra trạng thái hoạt động của server và các kết nối AI |
| GET | `/health` | Endpoint kiểm tra sức khỏe hệ thống (Health Check) |
| GET | `/api/v1/recommend/{user_id}` | Lấy danh sách 10 địa điểm gợi ý cá nhân hóa từ Two-Tower Model |
| POST | `/api/v1/trips/generate` | Sinh lịch trình du lịch thông minh bằng Groq Llama-3 |
| POST | `/api/v1/chat` | Chatbot hỗ trợ du lịch AI |
| GET | `/api/v1/ai/packing-list` | Sinh danh sách đồ dùng cần chuẩn bị |
| POST | `/api/v1/trips/join` | Mời người dùng tham gia chuyến đi thông qua mã chia sẻ |
| POST | `/api/v1/analytics/train` | Kích hoạt huấn luyện phân cụm người dùng K-Means |
| POST | `/admin/retrain` | Kích hoạt huấn luyện lại mô hình Two-Tower gợi ý ngay lập tức |
| GET | `/admin/scheduler/status` | Kiểm tra trạng thái của lịch trình retrain tự động |

---

## 🔧 TROUBLESHOOTING

### Lỗi tràn RAM (Out of Memory) sập server FastAPI
- **Nguyên nhân**: Sử dụng cờ `--reload` của uvicorn khiến server liên tục nạp lại mô hình TensorFlow dung lượng lớn mỗi khi lưu code.
- **Giải pháp**: Tuyệt đối không dùng `--reload` trong môi trường dev có tải mô hình máy học. Hãy chạy server bằng lệnh: `python main.py`.

### Lỗi không kết nối được Firebase
- **Nguyên nhân**: Thiếu file `serviceAccountKey.json` hoặc cấu hình JSON bị hỏng.
- **Giải pháp**: Tải lại Private Key mới từ Firebase Console và đặt đúng tên `serviceAccountKey.json` tại thư mục gốc của `triphero_api/`.

### Lỗi Gradle build trên Flutter
- **Nguyên nhân**: Không tương thích phiên bản Java JDK.
- **Giải pháp**: Dự án sử dụng Kotlin DSL nên bắt buộc JDK phải là **Java 17**. Hãy vào cài đặt Android Studio thiết lập JDK 17 cho Gradle.

---

## 📞 HỖ TRỢ & TÀI LIỆU
- **Tác giả**: Nguyễn Văn Hòa (Lớp 22SE1B) - Trường Đại học Công nghệ Thông tin và Truyền thông Việt - Hàn.
- **Tài liệu học thuật**: Tham khảo file báo cáo chi tiết `BaoCaoDATN.docx` trong thư mục gốc dự án.
- **Bản quyền**: Copyright © 2026 Nguyễn Văn Hòa - TripHero Project.

---
> *Lưu ý: Các API key cấu hình trong file .env là chìa khóa bảo mật cá nhân, vui lòng thay thế bằng key của bạn trước khi đưa lên môi trường sản xuất.*
