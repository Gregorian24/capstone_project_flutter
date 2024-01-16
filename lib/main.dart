import 'package:capstone_project/firebase_options.dart';
import 'package:capstone_project/pages/add_transaction_page.dart';
import 'package:capstone_project/pages/detail_transaction_page.dart';
import 'package:capstone_project/pages/login_page.dart';
import 'package:capstone_project/pages/register_page.dart';
import 'package:capstone_project/pages/splash_screen_page.dart';
import 'package:capstone_project/pages/transaction_page.dart';
import 'package:capstone_project/pages/update_transaction_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      title: 'Transaction',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/dashboard': (context) => ListTransaction(),
        '/add': (context) => AddTransaction(),
        '/detail': (context) => DetailTransaction(),
        '/update': (context) => UpdateTransaction(),
      },
    ),
  );
}
