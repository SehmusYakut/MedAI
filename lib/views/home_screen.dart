import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'widgets/language_selector.dart';
import 'ocr_screen.dart';
import 'medicine_program_screen.dart';
import 'ask_ai_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'lib/assests/logo.jpeg',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.medical_services, size: 24);
                  },
                ),
              ),
            ),
          ),
        ),
        title: Text(AppLocalizations.of(context).appTitle),
        actions: [
          const LanguageSelector(),
          IconButton(
            icon: const Icon(Icons.key),
            onPressed: () => Navigator.pushNamed(context, '/api-key'),
            tooltip: 'Manage API Key',
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildFeatureCard(
            context,
            AppLocalizations.of(context).medicinePrograms,
            Icons.medication,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MedicineProgramScreen(),
              ),
            ),
          ),
          _buildFeatureCard(
            context,
            AppLocalizations.of(context).ocrScan,
            Icons.document_scanner,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OCRScreen(),
              ),
            ),
          ),
          _buildFeatureCard(
            context,
            AppLocalizations.of(context).askAI,
            Icons.smart_toy_outlined,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AskAIScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
