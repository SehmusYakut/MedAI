import 'package:flutter/material.dart';
import '../../main.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      onSelected: (Locale locale) {
        MyApp.setLocale(context, locale);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        const PopupMenuItem<Locale>(
          value: Locale('en', ''),
          child: Row(
            children: [
              Text('🇬🇧'),
              SizedBox(width: 8),
              Text('English'),
            ],
          ),
        ),
        const PopupMenuItem<Locale>(
          value: Locale('tr', ''),
          child: Row(
            children: [
              Text('🇹🇷'),
              SizedBox(width: 8),
              Text('Türkçe'),
            ],
          ),
        ),
      ],
    );
  }
}
