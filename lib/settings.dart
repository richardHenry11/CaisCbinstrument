import 'package:absence/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLang = 'id';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLang = prefs.getString('language') ?? 'id';
    });
  }

  Future<void> _changeLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    MyApp.setLocale(context, Locale(lang));
    setState(() {
      _selectedLang = lang;
    });
  }

  Widget _themeOption({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? AppTheme.cyanAccent.withOpacity(0.15)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? AppTheme.cyanAccent.withOpacity(0.4)
                : AppTheme.borderColor(context),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.cyanAccent : AppTheme.textSecondary(context),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppTheme.cyanAccent : AppTheme.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate("Settings")),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.cardBackground(context),
                border: Border.all(color: AppTheme.borderColor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: AppTheme.cyanAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Tema",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _themeOption(
                        icon: Icons.brightness_auto_rounded,
                        label: "Sistem",
                        selected: themeProvider.themeMode == ThemeMode.system,
                        onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _themeOption(
                        icon: Icons.light_mode_rounded,
                        label: "Terang",
                        selected: themeProvider.themeMode == ThemeMode.light,
                        onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _themeOption(
                        icon: Icons.dark_mode_rounded,
                        label: "Gelap",
                        selected: themeProvider.themeMode == ThemeMode.dark,
                        onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.cardBackground(context),
                border: Border.all(color: AppTheme.borderColor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.translate('chooseLang'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<String>(
                    value: 'id',
                    groupValue: _selectedLang,
                    onChanged: (value) => _changeLang(value!),
                    title: Text(
                      t.translate('indonesia'),
                      style: TextStyle(color: AppTheme.textPrimary(context)),
                    ),
                    activeColor: AppTheme.cyanAccent,
                  ),
                  RadioListTile<String>(
                    value: 'en',
                    groupValue: _selectedLang,
                    onChanged: (value) => _changeLang(value!),
                    title: Text(
                      t.translate('english'),
                      style: TextStyle(color: AppTheme.textPrimary(context)),
                    ),
                    activeColor: AppTheme.cyanAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

