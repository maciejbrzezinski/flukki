import 'package:flutter/material.dart';
import 'home/controllers/current_project_controller.dart';
import 'home/pages/flukki_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dependencies();

  runApp(const MyApp());
}

Future<void> dependencies() async {
  await currentProjectController.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: Color(0xff399e5a),
              textStyle: const TextStyle(color: Colors.white),
            ),
          )),
      title: 'Flukki',
      home: FlukkiPage(),
    );
  }
}
