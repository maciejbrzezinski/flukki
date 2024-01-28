import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'current_project/controllers/current_project_controller.dart';
import 'home/pages/flukki_page.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.teal,
  // accentColor: Colors.tealAccent,
  cardColor: Color(0xFF1E1E1E),
  backgroundColor: Color(0xFF121212),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.teal,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
    ),
  ),
  colorScheme: ColorScheme.dark(
    primary: Colors.teal,
    secondary: Colors.tealAccent,
    background: Color(0xFFC01B1B),
  ),
  textTheme: TextTheme(
    headline4: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    bodyText2: TextStyle(color: Colors.grey),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Color(0xFF1E1E1E),
  ),
  scaffoldBackgroundColor: Color(0xFF121212),
  iconTheme: IconThemeData(
    color: Colors.white,
  ),
  fontFamily: GoogleFonts.kanit().fontFamily,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dependencies();

  runApp(const MyApp());
}

Future<void> dependencies() async {
  currentProjectController.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: appTheme,
      themeMode: ThemeMode.dark,
      title: 'Flukki',
      home: FlukkiPage(),
    );
  }
}
