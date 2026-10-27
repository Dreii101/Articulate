import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeys = Properties()
val releaseKeysFile = rootProject.file("../.private/android-signing.properties")
if (releaseKeysFile.exists()) releaseKeysFile.inputStream().use { releaseKeys.load(it) }
if (gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }) {
    check(releaseKeysFile.exists()) { "Private release signing is missing. Run tool/create-signing-key.ps1; never substitute a debug key." }
}

android {
    namespace = "dev.articulate.articulate"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "dev.articulate.articulate"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Keep transitive JNI binaries aligned with Flutter's actual engine targets.
        if (!providers.gradleProperty("split-per-abi").isPresent) {
            ndk {
                val abis = mapOf("android-arm" to "armeabi-v7a", "android-arm64" to "arm64-v8a", "android-x64" to "x86_64")
                abiFilters.clear()
                abiFilters.addAll(providers.gradleProperty("target-platform")
                    .getOrElse("android-arm,android-arm64,android-x64").split(",").map { abis.getValue(it) })
            }
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = releaseKeys.getProperty("keyAlias")
            keyPassword = releaseKeys.getProperty("keyPassword")
            storePassword = releaseKeys.getProperty("storePassword")
            storeFile = releaseKeys.getProperty("storeFile")?.let { rootProject.file(it) }
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
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
