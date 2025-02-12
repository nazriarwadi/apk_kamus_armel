import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_admin_page.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar belakang tetap sama
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Isi halaman dalam SingleChildScrollView agar responsif
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Judul Aplikasi
                    Text(
                      'Kamus Aksara \n Arab Melayu',
                      style: GoogleFonts.alegreya(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 15),

                    // Gambar dari assets
                    Image.asset(
                      'assets/icon/icon.png', // Pastikan path sesuai dengan lokasi file di folder assets
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),

                    // Deskripsi Aplikasi
                    Text(
                      'Kamus ini merupakan sebuah aplikasi yang berfungsi untuk mencari kata dari aksara Arab Melayu ke Bahasa Indonesia maupun sebaliknya. '
                      'Aplikasi ini dilengkapi dengan algoritma binary search yang mampu mencari kata dengan cepat.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tombol login admin tersembunyi
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                _showAdminAlert(context);
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 26,
                  color: Colors.teal.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan AlertDialog
  void _showAdminAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Peringatan",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Fitur ini hanya bisa diakses oleh admin.",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Tutup", style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                "Login Admin",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
