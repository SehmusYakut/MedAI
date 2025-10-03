import 'package:flutter/material.dart';
import 'ocr_screen.dart';
import 'medicine_program_screen.dart';
import 'ask_ai_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medway'),
        actions: [
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
            'Medicine Programs',
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
            'Scan Questions',
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
            'Ask AI',
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
