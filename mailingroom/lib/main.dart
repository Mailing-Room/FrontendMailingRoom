import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mailingroom/pages/home_pages.dart';
import 'package:provider/provider.dart';
import 'auth/auth_service.dart';
import 'auth/login_page.dart';
import 'models/user.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<MyUser?>(
      create: (_) => AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'Mailingroom',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);

    if (user == null) {
      // Jika user tidak login, tampilkan halaman login
      return const LoginPage();
    } else {
      // Jika user sudah login, tampilkan home page
      return const HomePage();
    }
  }
}