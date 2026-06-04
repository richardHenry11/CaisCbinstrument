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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isDark ? "Mode Gelap" : "Mode Terang",
                        style: TextStyle(
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                      Switch.adaptive(
                        value: isDark,
                        activeColor: AppTheme.cyanAccent,
                        onChanged: (_) => themeProvider.toggle(),
                      ),
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

