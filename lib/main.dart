import 'dart:async';
import 'dart:convert';

// import 'package:absence/absence.dart';
import 'package:absence/Regist.dart';
import 'package:absence/pilihdinas.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    runApp(MyApp(isLoggedIn: isLoggedIn));
  }, (error, stack) {
    debugPrint('Caught error in release: $error');
  });
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: isLoggedIn ? const PilihDinas() : MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // const MyHomePage({super.key, required this.title});

  // final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController AccessCodeController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
  setState(() => _isLoading = true);
  print(_isLoading);

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
      print(data);
      final user = data['data']['user_data']['user'];
      final token = data['data']['token'];
      final name = data['data']['nama_karyawan'];
      final id = data['data']['id'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', user);
      await prefs.setString('token', token);
      await prefs.setString('name', name);
      await prefs.setString('id', id);
      await prefs.setBool('isLoggedIn', true);

      print("name prefs: $name");
      print("token: $token");
      print("user: $user");
      print("id: $id");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 600),
          content: Text("Login Berhasil ^_^"),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PilihDinas()),
      );
    } else {
      // ❌ login gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 600),
          content: Text(data['message'] ?? "Login gagal"),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      SizedBox(
        height: MediaQuery.sizeOf(context).height * 1,
        child: 
        Center(
          child: 
          Container(
            width: MediaQuery.sizeOf(context).width * 1,
            decoration: BoxDecoration(
              color: Colors.blue
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.7,
                  child: Card(
                    color: const Color.fromARGB(255, 67, 57, 158),
                    child: 
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.asset('assets/logoBiru.png', width: 220, height: 65),
                        ),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.5,
                          child: 
                          Divider(
                            thickness: 1, 
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
                          child: Text("CBI Automation & Integrated System CAIS", 
                                        style: TextStyle(color: const Color.fromARGB(255, 202, 202, 202), 
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900
                                        ),
                                      ),
                        ),
                        Form(
                          key: _formKey,
                          child:
                            Column(
                              children: [
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.6,
                                  height: MediaQuery.sizeOf(context).height * 0.06,
                                  child: TextFormField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      hintText: "email",
                                      hintStyle: TextStyle(color: const Color.fromARGB(
                                                              255, 195, 195, 195)),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none
                                      ),
                                      filled: true,
                                      fillColor: Colors.white
                                    ),
                                  ),
                                ),
                                SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.6,
                                  height: MediaQuery.sizeOf(context).height * 0.06,
                                  child: TextFormField(
                                    controller: AccessCodeController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: "Access Code",
                                      hintStyle: TextStyle(color: const Color.fromARGB(
                                                              255, 195, 195, 195)),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none
                                      ),
                                      filled: true,
                                      fillColor: Colors.white
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                                  child: 
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      // Regist
                                      SizedBox(
                                        width: MediaQuery.sizeOf(context).width * 0.3,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 73, 197, 254),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15)
                                            )
                                          ),
                                          onPressed: 
                                          // button regist funct
                                          (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => Regist()));
                                          }, 
                                          child: Text('Regist', style: TextStyle(color: Colors.white),)
                                        ),
                                      ),

                                      // login
                                      SizedBox(
                                        width: MediaQuery.sizeOf(context).width * 0.3,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 73, 197, 254),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15)
                                            )
                                          ),
                                          onPressed: 
                                          // button submit funct
                                          (){
                                            _login();
                                          }, 
                                          child: Text('Enter the system', style: TextStyle(color: Colors.white),)
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        // Padding(padding: EdgeInsets.all(5.0)),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text("Beta Version - Protected by advanced security protocols", style: TextStyle(color: const Color.fromARGB(
                                                                255, 195, 195, 195), fontSize: 8, fontWeight: FontWeight.w800),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
