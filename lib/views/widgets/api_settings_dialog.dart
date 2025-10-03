import 'package:flutter/material.dart';

class APISettingsDialog extends StatefulWidget {
  final Function(String, String) onSaveKey;

  const APISettingsDialog({super.key, required this.onSaveKey});

  @override
  State<APISettingsDialog> createState() => _APISettingsDialogState();
}

class _APISettingsDialogState extends State<APISettingsDialog> {
  final TextEditingController _chatGPTController = TextEditingController();
  final TextEditingController _mistralController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _chatGPTController.dispose();
    _mistralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI Service Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your API keys for the AI services you want to use.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildAPIKeyField(
              'ChatGPT API Key',
              _chatGPTController,
              'Enter your OpenAI API key',
            ),
            const SizedBox(height: 16),
            _buildAPIKeyField(
              'Mistral API Key',
              _mistralController,
              'Enter your Mistral API key',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_chatGPTController.text.isNotEmpty) {
              widget.onSaveKey('chatgpt', _chatGPTController.text);
            }
            if (_mistralController.text.isNotEmpty) {
              widget.onSaveKey('mistral', _mistralController.text);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildAPIKeyField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
            ),
          ),
          obscureText: _isObscured,
          enableSuggestions: false,
          autocorrect: false,
        ),
      ],
    );
  }
}
