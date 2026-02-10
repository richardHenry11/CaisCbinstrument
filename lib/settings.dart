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
    // TODO: implement initState
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

    // main key funct here !!!
    MyApp.setLocale(context, Locale(lang));

    setState(() {
      _selectedLang = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate("Settings"), style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(t.translate('chooseLang'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            RadioListTile<String>(
              value: 'id', 
              groupValue: _selectedLang, 
              onChanged: (value) => _changeLang(value!),
              title: Text(t.translate('indonesia')),
            ),
            RadioListTile<String>(
              value: 'en',
              groupValue: _selectedLang,
              onChanged: (value) => _changeLang(value!),
              title: Text(t.translate('english')),
            ),
          ],
        ),
      ),
    );
  }
}