import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_page.dart'; // Pastikan halaman DashboardPage sudah diimpor

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToDashboard(); // Panggil fungsi untuk navigasi ke DashboardPage
  }

  _navigateToDashboard() async {
    // Tunggu selama 3 detik (durasi splash screen)
    await Future.delayed(Duration(seconds: 3));

    // Navigasi ke DashboardPage tanpa pengecekan login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00E8E8),
      body: Center(
        child: Card(
          color: Color(0xFFD9FFF5), // Warna abu-abu untuk Card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(29), // Border radius untuk Card
          ),
          elevation: 5, // Efek bayangan pada Card
          child: Padding(
            padding: const EdgeInsets.all(20), // Padding dalam Card
            child: Column(
              mainAxisSize: MainAxisSize.min, // Supaya card tidak penuh layar
              children: [
                Text(
                  'KAMUS',
                  style: GoogleFonts.alegreya(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 15),
                Image.asset(
                  'assets/icon/icon.png',
                  height: 140,
                  width: 140,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 15),
                Text(
                  'AKSARA ARAB MELAYU',
                  style: GoogleFonts.alegreya(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
