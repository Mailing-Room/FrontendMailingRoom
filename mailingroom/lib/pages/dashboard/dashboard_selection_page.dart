// Path: lib/pages/dashboard_selection_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mailingroom/models/user.dart';
import 'package:mailingroom/pages/home_page.dart';

class DashboardSelectionPage extends StatelessWidget {
  const DashboardSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MyUser> dummyUsers = Provider.of<List<MyUser>>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Dashboard'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: dummyUsers.map((user) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Provider.value(
                          value: user,
                          child: const HomePage(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Masuk sebagai ${user.role.toUpperCase()}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}