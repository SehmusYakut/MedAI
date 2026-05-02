🩺 MedAI: AI Developer Context & Rules
🎯 Project Essence
MedAI (Package: medway) is a Flutter MVVM medicine management app.
Core Tech: OCR (ML Kit), AI (Multi-model: GPT/Gemini/Mistral), Provider (State Mgmt).

🏗️ Architectural Constraints (NON-NEGOTIABLE)
Pattern: Strict MVVM.

Models: Pure data, JSON serializable.

Services: Abstract interfaces + implementations (Business/API logic).

ViewModels: ChangeNotifier only. No UI code.

Views: UI only. Listen to ViewModels via context.watch/select.

State Management: Provider (^6.0.5) with MultiProvider in main.dart.

Navigation: Standard Flutter Navigator (Keep it simple).

📁 Critical File Map
lib/models/: medicine.dart, question.dart, ai_response.dart.

lib/services/: ai_service.dart (Manager pattern), ocr_service.dart.

lib/viewmodels/: home_vm.dart, ocr_vm.dart, med_program_vm.dart.

lib/views/: Screens & widgets/ (Reusable components).

🛠️ Tech Stack & Implementation Rules
OCR: google_mlkit_text_recognition. Max file: 10MB.

AI: google_generative_ai (Gemini), http (ChatGPT/Mistral).

Storage: shared_preferences for keys and lightweight local data.

UI: Material 3, Portrait Only, Markdown support for AI outputs.

Error Handling: Every async call must use try-catch with user-facing SnackBar or Dialog.

📝 Coding Standards for AI
Naming: PascalCase (Classes), camelCase (Variables/Methods), snake_case (Files).

Clean Code:

Methods > 30 lines must be refactored.

No hardcoded strings; use AppLocalizations.

Use final where possible.

Performance: Optimize images (1800x1800 max) before OCR. Use const constructors.

Documentation: /// for public methods explaining "Why", not "What".

🚀 Optimized Development Workflow (AI Guide)
Logic First: Update Service interface -> Implementation -> ViewModel.

UI Second: Create/Update View widget -> Bind to ViewModel.

Test: Write unit test for the new Service/ViewModel logic before UI integration.