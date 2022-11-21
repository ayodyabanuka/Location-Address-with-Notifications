import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locationtracker/Screens/Login.dart';
import 'package:locationtracker/Services/NotificationService.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Login());
  }
}
