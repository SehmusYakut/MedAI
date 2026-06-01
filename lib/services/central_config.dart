import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class CentralConfig {
  static String get chatGPTKey {
    final key = dotenv.env['OPENAI_API_KEY'] ?? dotenv.env['CHATGPT_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] OPENAI_API_KEY is missing in environment config.');
    }
    return key;
  }

  static String get mistralKey {
    final key = dotenv.env['MISTRAL_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] MISTRAL_API_KEY is missing in environment config.');
    }
    return key;
  }

  static String get geminiKey {
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] GEMINI_API_KEY is missing in environment config.');
    }
    return key;
  }

  static String get claudeKey {
    final key = dotenv.env['CLAUDE_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] CLAUDE_API_KEY is missing in environment config.');
    }
    return key;
  }

  static String get groqKey {
    final key = dotenv.env['GROQ_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] GROQ_API_KEY is missing in environment config.');
    }
    return key;
  }

  static String get huggingFaceKey {
    final key = dotenv.env['HUGGINGFACE_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] HUGGINGFACE_API_KEY is missing in environment config.');
    }
    return key;
  }

  static String get openRouterKey {
    final key = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] OPENROUTER_API_KEY is missing in environment config.');
    }
    return key;
  }

  static bool get hasAnyConfiguredKey =>
      chatGPTKey.isNotEmpty ||
      mistralKey.isNotEmpty ||
      geminiKey.isNotEmpty ||
      claudeKey.isNotEmpty ||
      groqKey.isNotEmpty ||
      huggingFaceKey.isNotEmpty ||
      openRouterKey.isNotEmpty;

  static String get revenueCatAndroidKey {
    final key = dotenv.env['REVENUECAT_ANDROID_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] REVENUECAT_ANDROID_KEY is missing in environment config.');
    }
    return key;
  }

  static String get revenueCatIOSKey {
    final key = dotenv.env['REVENUECAT_IOS_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] REVENUECAT_IOS_KEY is missing in environment config.');
    }
    return key;
  }

  static Future<void> configurePurchases() async {
    if (await Purchases.isConfigured) return;

    final androidKey = revenueCatAndroidKey;
    final iosKey = revenueCatIOSKey;

    String activeKey = '';
    if (Platform.isAndroid) {
      activeKey = androidKey;
    } else if (Platform.isIOS) {
      activeKey = iosKey;
    }

    final isPlaceholder = activeKey.isEmpty ||
        activeKey.contains('YOUR_') ||
        activeKey.contains('placeholder') ||
        activeKey == 'goog_public_android_api_key' ||
        activeKey == 'appl_public_ios_api_key';

    if (isPlaceholder) {
      throw AssertionError(
        'Invalid RevenueCat API Key: "$activeKey". '
        'Please configure a valid production RevenueCat API key in your .env file '
        'under REVENUECAT_ANDROID_KEY and REVENUECAT_IOS_KEY.'
      );
    }

    await Purchases.configure(PurchasesConfiguration(activeKey));
  }
}

