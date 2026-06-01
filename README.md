# MedAI 🏥

**MedAI** is an intelligent, production-grade medicine management and clinical assistant application designed for medical students and healthcare professionals. It helps users organize study materials, track medicine programs, scan medical text via OCR, and consult a powerful, environment-configured AI clinical assistant with full chat session persistence.

---

## ✨ Features

### 🗂️ Intent-Driven Smart Hub (Dashboard)
- **Clinical Command Center**: Replaces generic query fields with a responsive, modern portal welcoming the user.
- **Dynamic Quick Action Cards**: Launch new clinical queries, jump to profile/settings, or manage active medicine programs with one tap.
- **Recent Case Preview**: Scroll through recently accessed clinical sessions and resume studies instantly.

### 🤖 AI Clinical Assistant
- **Single-Model Gemini Assistant**: Configured via the secure `.env` pipeline.
- **Persistent Chat History**: Full local persistence of chat sessions. Start new cases, resume old ones, rename sessions (e.g., *"Cardiology Clerkship - Heart Failure"*), or delete inactive records.
- **Multi-Service LLM Engine**: Architecture ready for multiple providers (Gemini, ChatGPT, Mistral) initialized dynamically via environment keys.

### 💊 Medicine Program Management
- **Schedule Planner**: Create and track multiple medication schedules with custom reminders, frequencies, and durations.
- **Performance Optimized**: Filtered and cached views pre-calculated in ViewModels to guarantee 60fps/120fps scrolling with zero main-thread frame drops.
- **Department Categorization**: Group programs by medical specialty (e.g., Internal Medicine, Pediatrics, Surgery).

### 📸 OCR Text Recognition
- **On-Device Text Extraction**: Extract medical terminology from prescriptions, textbooks, and reports using Google ML Kit.
- **Multi-Language Support**: Robust parsing of Latin, Devangari, Chinese, Japanese, and Korean scripts.
- **Question Bank Integration**: Instantly categorize scanned medical questions and save them for clinical exam preparation.

---

## 🏗️ Architecture & Project Structure

The project follows a clean **MVVM (Model-View-ViewModel)** architectural pattern using the `provider` package for state management.

```
lib/
├── main.dart                      # Application entry point & service providers setup
├── models/                        # Structured data models
│   ├── ai_response.dart           # AI payload mapping
│   ├── chat_message.dart          # Chat message model (role, content, timestamp)
│   ├── chat_session.dart          # Chat session model (UUID, title, messages, time)
│   ├── medicine.dart              # Individual medicine definitions
│   ├── medicine_program.dart      # Medicine schedules and configurations
│   └── question.dart              # Saved OCR questions bank
├── services/                      # Business & application services
│   ├── ai_service.dart            # Handles upstream Gemini/OpenAI/Mistral API requests
│   ├── central_config.dart        # Centralized .env loader & RevenueCat initialization
│   ├── chat_storage_service.dart  # Serializes and manages persistent chat history
│   ├── ocr_service.dart           # Wraps Google ML Kit text recognition
│   ├── theme_and_locale_service.dart # Handles dynamic UI themes & languages
│   └── usage_limit_service.dart   # Implements request/usage capping
├── viewmodels/                    # UI state and business logic bindings
│   ├── home_view_model.dart       # Coordinates dashboard stats and actions
│   ├── medicine_program_view_model.dart # Manages schedules with zero-lag pre-filters
│   └── ocr_view_model.dart        # Coordinates camera, image picking, and parsing
└── views/                         # Material Design 3 UI layer
    ├── ask_ai_screen.dart         # Clinical assistant chat (load, rename, resume, delete)
    ├── entrance_screen.dart       # App landing & authentication gate
    ├── home_screen.dart           # Smart Hub portal & quick actions dashboard
    ├── medicine_program_screen.dart # View/manage active medication schedules
    ├── ocr_screen.dart            # Document camera scanner
    ├── premium_paywall_screen.dart # RevenueCat billing and premium feature gateway
    ├── profile_screen.dart        # User profile, statistics, and settings
    ├── program_details_screen.dart # Granular program schedules and tracking info
    └── widgets/                   # Reusable UI widgets & custom dialogs
        ├── add_medicine_dialog.dart
        ├── ai_response_card.dart
        ├── create_program_dialog.dart
        ├── language_selector.dart
        ├── medicine_program_card.dart
        ├── recognized_text_view.dart
        ├── reminder_time_picker.dart
        └── weekly_schedule.dart
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: `>= 3.0.0`
- **Dart SDK**: `>= 3.0.0`
- **Android SDK**: API 24+ (for Android compilation)
- **Xcode**: Latest version (for iOS compilation, macOS only)

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/SehmusYakut/MedAI.git
   cd MedAI
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**
   Create a `.env` file in the root directory. Copy the keys from `.env.example` and set your credentials:
   ```env
   GEMINI_API_KEY="YOUR_GEMINI_KEY"
   OPENAI_API_KEY="YOUR_OPENAI_KEY"
   REVENUECAT_ANDROID_KEY="YOUR_REVENUECAT_ANDROID_KEY"
   REVENUECAT_IOS_KEY="YOUR_REVENUECAT_IOS_KEY"
   ```
   > [!IMPORTANT]
   > The application uses **CentralConfig** to load configuration keys at startup. Incomplete or placeholder keys (e.g. `goog_public_android_api_key`) will trigger developer-friendly assertions in debug builds to prevent misconfigured production releases.

4. **Run the Application**
   ```bash
   flutter run
   ```

---

## 🔒 Security & Optimization

### API Key Safety
- **No Hardcoded Credentials**: All API keys are loaded via `flutter_dotenv` at runtime.
- **Local Storage**: User chat sessions, history, and medicine programs are persisted locally on-device using securely isolated `shared_preferences`.

### Release Hardening & ProGuard
When building for release on Android, code shrinking, obfuscation, and optimization (R8) are enabled.
We resolve potential class verification failures (e.g., dynamic play-services paths) by configuration in `android/app/proguard-rules.pro`:
```proguard
-dontwarn com.google.android.play.core.**
```

### Performance Optimizations
- ViewModels precompute filtered datasets (e.g., `inactivePrograms` computed dynamically once instead of using inline `.where().toList()` filters inside list builders). This resolves frames skip bugs and guarantees smooth transitions on low-end target hardware.

---

## 📦 Building for Release

### Android (APK)
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Windows
```bash
flutter build windows --release
```

---

## 🧪 Testing

Run all unit and widget tests:
```bash
flutter test
```

Generate test coverage data:
```bash
flutter test --coverage
```

---

## 👨‍💻 Author

**Sehmus Yakut**
- GitHub: [@SehmusYakut](https://github.com/SehmusYakut)

---

*Made with ❤️ for medical students and healthcare professionals.*
