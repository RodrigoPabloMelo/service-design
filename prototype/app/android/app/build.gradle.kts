import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    ndkVersion = "29.0.13113456"
    namespace = "com.example.flutterMvvmLeap"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        minSdk = 26
        targetSdk = 36
        multiDexEnabled = true
        applicationId = "com.example.flutterMvvmLeap"
        versionCode = flutter.versionCode.toString().toInt()
        versionName = flutter.versionName.toString()
    }

    signingConfigs {
       if (keystorePropertiesFile.exists()) {
           create("release") {
               keyAlias = keystoreProperties["keyAlias"] as String
               keyPassword = keystoreProperties["keyPassword"] as String
               storeFile = file(keystoreProperties["storeFile"] as String)
               storePassword = keystoreProperties["storePassword"] as String
           }
       }
   }

   buildTypes {
       release {
           if (keystorePropertiesFile.exists()) {
               signingConfig = signingConfigs.getByName("release")
           }
       }
   }

    flavorDimensionList += "flavorDimension"
    productFlavors {
        create("dev") {
            dimension = "flavorDimension"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "[DEV] Flutter MVVM Leap")
        }
        create("hml") {
            dimension = "flavorDimension"
            applicationIdSuffix = ".hml"
            versionNameSuffix = "-hml"
            resValue("string", "app_name", "[HML] Flutter MVVM Leap")
        }
        create("prod") {
            dimension = "flavorDimension"
            resValue("string", "app_name", "Flutter MVVM Leap")
        }
    }
}

flutter {
    source = "../.."
}
