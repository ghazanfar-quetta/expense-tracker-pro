import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'utils/app_settings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final AppSettings appSettings = AppSettings();

  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listen to settings changes
    widget.appSettings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    widget.appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {}); // Rebuild when settings change
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor:
              const Color.fromARGB(255, 249, 145, 110), // Orange for light mode
          brightness: Brightness.light,
          primary: const Color.fromARGB(255, 249, 145, 110),
          secondary: const Color(0xFF10B981),
          error: const Color(0xFFEF4444),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 249, 145, 110), // Orange
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(
              255, 249, 145, 110), // Orange for dark mode too
          brightness: Brightness.dark,
          primary: const Color.fromARGB(255, 249, 145, 110), // Orange
          secondary: const Color(0xFF10B981),
          error: const Color(0xFFEF4444),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 249, 145, 110), // Orange
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      themeMode: widget.appSettings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(appSettings: widget.appSettings),
      debugShowCheckedModeBanner: false,
    );
  }
}
