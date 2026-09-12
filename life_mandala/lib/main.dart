import 'package:flutter/material.dart';
import 'models/models.dart';
import 'services/storage_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/mandala_screen.dart';

void main() {
  runApp(const MandalaApp());
}

class MandalaApp extends StatefulWidget {
  const MandalaApp({super.key});
  @override
  State<MandalaApp> createState() => _MandalaAppState();
}

class _MandalaAppState extends State<MandalaApp> {
  MandalaData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final data = await StorageService.load();
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  void _onSetupComplete(MandalaData data) {
    setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Mandala',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2D2D2D),
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F7F5),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2D2D2D),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: _loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (_data == null || _data!.mainGoalTitle.trim().isEmpty)
              ? OnboardingScreen(existing: _data, onComplete: _onSetupComplete)
              : MandalaScreen(initialData: _data!),
    );
  }
}
