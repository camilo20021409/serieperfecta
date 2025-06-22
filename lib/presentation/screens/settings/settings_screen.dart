import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serieperfecta/services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 20),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tema de la Aplicación',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  RadioListTile<AppThemeMode>(
                    title: const Text('Modo Claro'),
                    value: AppThemeMode.light,
                    groupValue: themeService.currentThemeMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        themeService.setTheme(mode);
                      }
                    },
                  ),
                  RadioListTile<AppThemeMode>(
                    title: const Text('Modo Oscuro'),
                    value: AppThemeMode.dark,
                    groupValue: themeService.currentThemeMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        themeService.setTheme(mode);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
