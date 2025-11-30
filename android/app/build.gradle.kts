plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // FlutterFire plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.finsight"
    compileSdk = 35             // Updated to match plugin requirements
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.finsight"
        minSdk = 23             // Required by firebase_core
        targetSdk = 35          // Updated to match compileSdk
        versionCode = 1
        versionName = "1.0"

        // Prevent manifest merger issues
        manifestPlaceholders["minSdkVersion"] = "23"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false       // Turn off code shrinking
            isShrinkResources = false     // Turn off resource shrinking
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
