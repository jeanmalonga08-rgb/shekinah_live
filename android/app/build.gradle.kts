import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val releaseKeyProperties = Properties().apply {
    val propertiesFile = rootProject.file("key.properties")
    if (propertiesFile.isFile) {
        propertiesFile.inputStream().use(::load)
    }
}

fun releaseSetting(property: String, environmentVariable: String): String? =
    System.getenv(environmentVariable)?.takeIf { it.isNotBlank() }
        ?: releaseKeyProperties.getProperty(property)?.takeIf { it.isNotBlank() }

android {
    namespace = "com.shekinah.tabernacle"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.shekinah.tabernacle"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = rootProject.file(
                releaseSetting("storeFile", "ANDROID_RELEASE_KEYSTORE_PATH")
                    ?: "app/release.keystore"
            )
            storePassword = releaseSetting("storePassword", "ANDROID_RELEASE_KEYSTORE_PASSWORD") ?: ""
            keyAlias = releaseSetting("keyAlias", "ANDROID_RELEASE_KEY_ALIAS") ?: ""
            keyPassword = releaseSetting("keyPassword", "ANDROID_RELEASE_KEY_PASSWORD") ?: ""
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}
