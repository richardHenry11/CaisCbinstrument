import 'dart:async';
import 'dart:convert';

import 'package:absence/Regist.dart';
import 'package:absence/dashboard.dart';
// import 'package:absence/pilihdinas.dart';
import 'package:absence/theme.dart';
import 'package:absence/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

final ThemeProvider themeProvider = ThemeProvider();

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await initializeDateFormatting('id_ID', null);
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final savedLang = prefs.getString('language') ?? 'id';

      await themeProvider.loadTheme();

      runApp(MyApp(isLoggedIn: isLoggedIn, locale: Locale(savedLang)));
    },
    (error, stack) {
      debugPrint('Caught error in release: $error');
    },
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final Locale locale;

  const MyApp({super.key, required this.isLoggedIn, required this.locale});

  static void setLocale(BuildContext context, Locale locale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
    themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      supportedLocales: const [Locale('id'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: widget.isLoggedIn ? const Dashboard() : MyHomePage(),
      builder: (context, child) =>
          _ThemeTransitionWrapper(child: child!),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController AccessCodeController = TextEditingController();
  bool _isLoading = false;
  bool rememberMe = false;
  bool _isVisible = false;
  Offset _slideOffset = const Offset(0, 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _slideOffset = Offset.zero);
      }
    });
    _loadRememberMe();
    print(_isLoading);
  }

  Future<void> _loadRememberMe() async {
    final p = await SharedPreferences.getInstance();

    setState(() {
      rememberMe = p.getBool('rememberMe') ?? false;

      if (rememberMe) {
        emailController.text = p.getString('savedEmail') ?? '';
        AccessCodeController.text = p.getString('savedPassword') ?? '';
      }
    });
  }

  void _login() async {
    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('https://cais.cbinstrument.com/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': emailController.text,
              'password': AccessCodeController.text,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final user = data['data']['user_data']['user'];
        final token = data['data']['token'];
        final name = data['data']['nama_karyawan'];
        final id = data['data']['id'];
        final employeesId = data['data']['id_karyawan'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', user);
        await prefs.setString('token', token);
        await prefs.setString('name', name);
        await prefs.setString('id', id);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('employeesId', employeesId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 600),
            content: Text("Login Berhasil ^_^"),
          ),
        );

        if (rememberMe) {
          await prefs.setBool('rememberMe', true);
          await prefs.setString('savedEmail', emailController.text);
          await prefs.setString('savedPassword', AccessCodeController.text);
        } else {
          await prefs.remove('rememberMe');
          await prefs.remove('savedEmail');
          await prefs.remove('savedPassword');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Dashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(255, 183, 131, 127),
            duration: const Duration(milliseconds: 600),
            content: Text(
              data['message'] ?? "Login gagal",
              style: const TextStyle(color: Color.fromARGB(255, 96, 25, 20)),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e", style: const TextStyle(color: Colors.red))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/loginBekgron.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: screenHeight * 0.7,
              width: screenWidth,
              child: AnimatedSlide(
                offset: _slideOffset,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                child: SingleChildScrollView(
                  child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 19, 89, 146),
                      width: 1,
                    ),
                  ),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.asset(
                          'assets/logoBiru.png',
                          width: 220,
                          height: 65,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.85,
                        child: const Divider(thickness: 1, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20, bottom: 20, right: 20,
                        ),
                        child: Text(
                          "CBI Automation & Integrated System CAIS",
                          style: TextStyle(
                            color: const Color.fromARGB(83, 42, 171, 235),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Form(
                        key: _formKey,
                        child: SizedBox(
                          width: 350,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Email",
                                  style: TextStyle(color: Color(0xFF475467)),
                                ),
                              ),
                              SizedBox(
                                width: 350,
                                child: TextFormField(
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 38, 38, 38),
                                  ),
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    hintText: t.translate("username"),
                                    hintStyle: const TextStyle(
                                      color: Color.fromARGB(255, 145, 145, 145),
                                      fontSize: 14,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color.fromARGB(255, 19, 89, 146),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color.fromARGB(255, 19, 89, 146),
                                      ),
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset(
                                        'assets/sms.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Password",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              SizedBox(
                                width: screenWidth * 0.9,
                                child: TextFormField(
                                  style: const TextStyle(color: Color.fromARGB(255, 40, 40, 40)),
                                  controller: AccessCodeController,
                                  obscureText: !_isVisible,
                                  decoration: InputDecoration(
                                    hintText: t.translate("password"),
                                    hintStyle: const TextStyle(
                                      color: Color.fromARGB(255, 133, 133, 133),
                                      fontSize: 14,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color.fromARGB(255, 19, 89, 146),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color.fromARGB(255, 19, 89, 146),
                                      ),
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset(
                                        'assets/finger-scan.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isVisible = !_isVisible;
                                        });
                                      },
                                      icon: Icon(
                                        _isVisible == true
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color(0xFF2AACEB),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: screenWidth * 0.9,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: rememberMe,
                                          activeColor: const Color(0xFF0066FF),
                                          onChanged: (value) {
                                            setState(() {
                                              rememberMe = value ?? false;
                                            });
                                          },
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              rememberMe = !rememberMe;
                                            });
                                          },
                                          child: const Text(
                                            "Remember Me",
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text("Lupa Password"),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 20, bottom: 2,
                                ),
                                child: SizedBox(
                                  width: screenWidth * 0.88,
                                  height: screenHeight * 0.06,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFF186185),
                                          Color(0xFF2598CF),
                                          Color(0xFF2AACEB),
                                        ],
                                      ),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () => _login(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: Text(
                                        t.translate("in"),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: screenWidth * 0.35,
                                      child: const Divider(),
                                    ),
                                    const Text("OR"),
                                    SizedBox(
                                      width: screenWidth * 0.35,
                                      child: const Divider(),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: screenWidth * 0.9,
                                height: screenHeight * 0.06,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF2AACEB),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Regist(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Text(
                                      t.translate("reg"),
                                      style: const TextStyle(
                                        color: Color(0xff2AACEB),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          t.translate("beta"),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 195, 195, 195),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Theme transition: sunrise (→light) / sunset (→dark) radial reveal ───────

class _ThemeTransitionWrapper extends StatefulWidget {
  final Widget child;
  const _ThemeTransitionWrapper({required this.child});

  @override
  State<_ThemeTransitionWrapper> createState() =>
      _ThemeTransitionWrapperState();
}

class _ThemeTransitionWrapperState extends State<_ThemeTransitionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ThemeData _oldTheme;
  late ThemeData _newTheme;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() => setState(() {}));
    _newTheme = _themeFromMode(themeProvider.themeMode);
    _oldTheme = _newTheme;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      themeProvider.addListener(_onThemeChanged);
    });
  }

  ThemeData _themeFromMode(ThemeMode mode) =>
      mode == ThemeMode.light ? AppTheme.light : AppTheme.dark;

  void _onThemeChanged() {
    if (_controller.isAnimating) return;
    _oldTheme = _newTheme;
    _newTheme = _themeFromMode(themeProvider.themeMode);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _controller.value;

    if (!_controller.isAnimating || t >= 1) {
      return widget.child;
    }

    final lerped = ThemeData.lerp(_oldTheme, _newTheme, t);

    return Theme(
      data: lerped,
      child: Stack(
        children: [
          widget.child,
          // decorative radial gradient overlay for sunrise/sunset feel
          Positioned.fill(
            child: IgnorePointer(
              child: _SunOverlay(t: t, isSunrise: _newTheme.brightness == Brightness.light),
            ),
          ),
        ],
      ),
    );
  }
}

class _SunOverlay extends StatelessWidget {
  final double t;
  final bool isSunrise;

  const _SunOverlay({required this.t, required this.isSunrise});

  @override
  Widget build(BuildContext context) {
    final color = isSunrise
        ? Colors.orange.withOpacity(0.12 * (1 - t))
        : Colors.indigo.withOpacity(0.15 * (1 - t));

    return CustomPaint(
      painter: _RadialPainter(t: t, isSunrise: isSunrise, color: color),
    );
  }
}

class _RadialPainter extends CustomPainter {
  final double t;
  final bool isSunrise;
  final Color color;

  _RadialPainter({required this.t, required this.isSunrise, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final maxR = (cx > cy ? cx : size.height) + 100.0;
    final r = maxR * t * 1.2;

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(cx / size.width * 2 - 1, cy / size.height * 2 - 1),
        radius: r / maxR,
        colors: [
          color,
          color.withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _RadialPainter old) =>
      old.t != t || old.isSunrise != isSunrise || old.color != color;
}
