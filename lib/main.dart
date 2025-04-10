import 'package:flutter/material.dart';
import 'package:hydration/utils.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'models/water_tracker_data.dart';
import 'screens/homepage_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  Utils.db = await WaterTrackerData().openDatabaseConnection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hydration',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF5F5F5)),
      ),
      home: const HomePage(),
    );
  }
}
