# MedAI 🏥

**MedAI** is an intelligent medicine management application powered by AI, designed to help medical students and healthcare professionals organize their study materials, manage medicine programs, and get AI-powered assistance for medical questions.

## ✨ Features

### 📸 OCR Text Recognition
- Extract text from medical documents, prescriptions, and study materials
- Multi-language support (Latin, Chinese, Devanagari, Japanese, Korean scripts)
- Automatic text cleanup and medical term correction
- Save and categorize extracted questions by medical subjects

### 💊 Medicine Program Management
- Create and manage multiple medicine programs
- Track medicine schedules with customizable reminders
- Organize medicines by medical departments (Internal Medicine, Surgery, Pediatrics, etc.)
- Set dosage, frequency, and duration for each medicine
- Pause/resume programs as needed

### 🤖 AI-Powered Medical Assistant
- Integration with multiple AI services (ChatGPT, Mistral AI)
- Ask medical questions and get instant AI-powered responses
- Compare responses from different AI services
- Secure API key management

### 📚 Question Bank
- Automatically categorize questions by medical subjects
- Save OCR-extracted questions for later study
- Track question history and timestamps

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)
- Visual Studio 2022 (for Windows builds)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/SehmusYakut/MedAI.git
   cd MedAI/medway
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase** (Required for ML Kit)
   - Add your `google-services.json` to `android/app/`
   - Add your `GoogleService-Info.plist` to `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Building

### Android APK
```bash
flutter build apk --release
```

### Windows
```bash
flutter build windows --release
```

### iOS
```bash
flutter build ios --release
```

## 🔧 Configuration

### API Keys Setup
On first launch, navigate to Settings to configure your AI service API keys:
- **ChatGPT**: Get your API key from [OpenAI](https://platform.openai.com/api-keys)
- **Mistral AI**: Get your API key from [Mistral AI](https://console.mistral.ai/)

API keys are securely stored locally using shared preferences.

## 📱 Supported Platforms

- ✅ Android (API 24+)
- ✅ iOS (iOS 12.0+)
- ✅ Windows (Windows 10+)
- ✅ macOS
- ✅ Linux
- ✅ Web

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Material Design 3** - Modern UI/UX design system
- **Provider** - State management

### Backend Services
- **Google ML Kit** - Text recognition (OCR)
- **Firebase** - Analytics and services
- **OpenAI GPT** - AI-powered responses
- **Mistral AI** - Alternative AI service

### Key Packages
- `google_mlkit_text_recognition` - OCR functionality
- `image_picker` - Image capture and selection
- `shared_preferences` - Local data storage
- `provider` - State management
- `http` - API communication
- `path_provider` - File system access
- `uuid` - Unique identifier generation

## 📂 Project Structure

```
medway/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── models/                   # Data models
│   │   ├── medicine.dart
│   │   ├── medicine_program.dart
│   │   └── question.dart
│   ├── services/                 # Business logic services
│   │   ├── ai_service.dart
│   │   ├── ocr_service.dart
│   │   └── api_key_service.dart
│   ├── viewmodels/              # State management
│   │   ├── home_view_model.dart
│   │   ├── medicine_program_view_model.dart
│   │   └── ocr_view_model.dart
│   ├── views/                   # UI screens
│   │   ├── entrance_screen.dart
│   │   ├── home_screen.dart
│   │   ├── ocr_screen.dart
│   │   ├── medicine_program_screen.dart
│   │   ├── ask_ai_screen.dart
│   │   └── widgets/            # Reusable widgets
│   └── utils/                   # Utility functions
├── android/                     # Android-specific files
├── ios/                        # iOS-specific files
├── windows/                    # Windows-specific files
├── test/                       # Unit and widget tests
└── pubspec.yaml               # Dependencies configuration
```

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run with coverage:
```bash
flutter test --coverage
```

## 🔒 Security & Privacy

- API keys are stored locally and never transmitted to third parties
- No user data is collected or shared
- All OCR processing happens on-device using Google ML Kit
- AI requests are sent directly to configured services (OpenAI, Mistral)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Sehmus Yakut**
- GitHub: [@SehmusYakut](https://github.com/SehmusYakut)

## 🙏 Acknowledgments

- Google ML Kit for powerful OCR capabilities
- OpenAI and Mistral AI for AI-powered assistance
- Flutter team for the amazing framework
- Medical community for inspiration and feedback

## 📧 Support

For support, questions, or feedback, please open an issue on GitHub.

---

Made with ❤️ for medical students and healthcare professionals
