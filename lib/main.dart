import 'package:flutter/material.dart';
import 'package:pro/core/constants/app_themes.dart';
import 'package:pro/features/detection/presentation/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FluxFinderApp());
}

class FluxFinderApp extends StatelessWidget {
  const FluxFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FluxFinder',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.darkTheme,
      home: const HomePage(),
    );
  }
}
