plugins {
  id("com.android.library")
  id("org.jetbrains.kotlin.android")
}

android {
  namespace = "com.wilderbots.wilderlinks"
  compileSdk = 35

  defaultConfig {
    minSdk = 23
    consumerProguardFiles("consumer-rules.pro")
  }
}

kotlin {
  jvmToolchain(21)
}

dependencies {
  api("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
}
