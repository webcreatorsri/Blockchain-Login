plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Google Services plugin
}

android {
    namespace = "com.example.blockchain_login"
    compileSdk = 36 // replace with your flutter.compileSdkVersion if needed
    ndkVersion = "27.0.12077973" // replace with flutter.ndkVersion if needed

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.blockchain_login" // Must match Firebase app
        minSdk = flutter.minSdkVersion // your flutter.minSdkVersion
        targetSdk = 34 // your flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
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

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.7.0"))
}
