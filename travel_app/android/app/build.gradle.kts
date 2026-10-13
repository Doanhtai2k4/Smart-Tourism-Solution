import java.util.Properties

// 1. Logic đọc file .env từ thư mục gốc của dự án Flutter
val dotenvFile = rootProject.file("../../.env")
val env = mutableMapOf<String, String>()

if (dotenvFile.exists()) {
    dotenvFile.forEachLine { lineRaw ->
        val line = lineRaw.trim()
        if (line.isNotEmpty() && !line.startsWith("#") && line.contains("=")) {
            val parts = line.split("=", limit = 2)
            if (parts.size == 2) {
                val key = parts[0].trim()
                val value = parts[1].trim()
                env[key] = value
            }
        }
    }
}

plugins {
    id("com.android.application")
    // Cấu hình Firebase
    id("com.google.gms.google-services")
    id("kotlin-android")
    // Plugin Flutter phải nằm sau cùng
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Tên gói đồng nhất với dự án mới
    namespace = "com.taidev.travel_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.taidev.travel_app"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Đã gỡ bỏ manifestPlaceholders của Google Maps vì chuyển sang dùng OSM
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}