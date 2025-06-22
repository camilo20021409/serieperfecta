import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:serieperfecta/models/routine.dart';
import 'package:serieperfecta/models/workout_interval.dart';
import 'package:serieperfecta/presentation/screens/home/home_screen.dart';
import 'package:serieperfecta/services/routine_service.dart';
import 'package:serieperfecta/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(RoutineAdapter());
  Hive.registerAdapter(WorkoutIntervalAdapter());

  final themeService = ThemeService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoutineService()),
        ChangeNotifierProvider.value(value: themeService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Serie Perfecta',
          debugShowCheckedModeBanner: false,
          theme: themeService.getAppTheme(themeService.currentThemeMode),
          home: const HomeScreen(),
        );
      },
    );
  }
}
