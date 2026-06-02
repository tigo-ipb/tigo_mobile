import 'package:flutter/material.dart';

class OrganizerDashboard extends StatelessWidget {
  const OrganizerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Panitia'),
        backgroundColor: const Color(0xFF00A2FF), // Warna Primary Tigo
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Selamat Datang Panitia!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
