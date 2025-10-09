// Path: lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'providers/surat_provider.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Theme colors
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color accentOrange = Color(0xFFFB8C00);
  static const Color bg = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MyUser?>.value(
          value: MyUser(uid: 'user_id_dummy', email: 'pengirim@mailingroom.com', role: 'user'),
        ),
        ChangeNotifierProvider(create: (_) => SuratProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mailingroom',
        theme: ThemeData(
          primaryColor: primaryBlue,
          scaffoldBackgroundColor: bg,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
            secondary: accentOrange,
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}
