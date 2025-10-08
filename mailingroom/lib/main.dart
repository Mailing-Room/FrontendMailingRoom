// Path: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Memberikan data user dummy ke seluruh aplikasi
    return Provider<MyUser?>(
      create: (_) => MyUser(uid: 'user_id_dummy', email: 'pengirim@mailingroom.com', role: 'user'),
      child: MaterialApp(
        title: 'Mailingroom App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}