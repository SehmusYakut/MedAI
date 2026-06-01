import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'views/home_screen.dart';
import 'views/entrance_screen.dart';
import 'views/premium_paywall_screen.dart';
import 'views/ask_ai_screen.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/medicine_program_view_model.dart';
import 'viewmodels/ocr_view_model.dart';
import 'services/usage_limit_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env configuration
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('[Developer Warning] Failed to load .env configuration: $e');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  final SharedPreferences? prefs;
  const MyApp({super.key, this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  static void toggleTheme(BuildContext context) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.toggleTheme();
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  bool _isDarkTheme = false;
  SharedPreferences? _prefs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = widget.prefs ?? await SharedPreferences.getInstance();
    setState(() {
      _loading = false;
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => MedicineProgramViewModel()),
        ChangeNotifierProvider(create: (_) => OCRViewModel()),
        ChangeNotifierProvider(create: (_) => UsageLimitService(_prefs!)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MedAI',
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('tr', ''),
        ],
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
        routes: {
          '/': (context) => const EntranceScreen(),
          '/home': (context) => const HomeScreen(),
          '/premium-paywall': (context) => const PremiumPaywallScreen(),
          '/ask-ai': (context) => const AskAIScreen(),
        },
        initialRoute: '/',
      ),
    );
  }

  /// Builds optimized Light Theme with Material 3
  ThemeData _buildLightTheme() {
    const lightSeedColor = Color(0xFF2196F3);
    final lightScheme = ColorScheme.fromSeed(
      seedColor: lightSeedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: lightScheme,
      useMaterial3: true,
      cardTheme: const CardThemeData(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: lightScheme.primary,
        foregroundColor: lightScheme.onPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        smallSizeConstraints: const BoxConstraints.tightFor(
          width: 48,
          height: 48,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: lightScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds optimized Dark Theme with Deep Navy & Electric Teal
  ThemeData _buildDarkTheme() {
    const darkNavy = Color(0xFF0A192F); // Deep Navy background
    const electricTeal = Color(0xFF00D9FF); // Bright Electric Teal accent
    const darkSurfaceColor = Color(0xFF0F1F2E); // Slightly lighter than navy

    const darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: electricTeal,
      onPrimary: Color(0xFF000000),
      primaryContainer: Color(0xFF1A3A4A),
      onPrimaryContainer: electricTeal,
      secondary: Color(0xFF64B5F6), // Bright Light Blue
      onSecondary: Color(0xFF000000),
      error: Color(0xFFFF6B6B),
      onError: Color(0xFF000000),
      surface: darkSurfaceColor,
      onSurface: Color(0xFFFFFFFF),
      outline: Color(0xFF8ECAE6),
      outlineVariant: Color(0xFF4A7C9E),
      scrim: Color(0xFF000000),
    );

    return ThemeData(
      colorScheme: darkScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: darkNavy,
      cardTheme: const CardThemeData(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        elevation: 2,
        color: darkSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: darkNavy,
        foregroundColor: electricTeal,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: electricTeal,
        foregroundColor: darkNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        smallSizeConstraints: BoxConstraints.tightFor(
          width: 48,
          height: 48,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: darkScheme.outline, width: 1.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: electricTeal, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(electricTeal),
          foregroundColor: WidgetStatePropertyAll(Color(0xFF000000)),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(electricTeal),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: darkSurfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}
