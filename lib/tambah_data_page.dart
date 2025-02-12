import 'package:flutter/material.dart';
import 'admin_service.dart';

class TambahDataPage extends StatefulWidget {
  @override
  _TambahDataPageState createState() => _TambahDataPageState();
}

class _TambahDataPageState extends State<TambahDataPage> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  bool _isLoading = false;

  void _addDictionary() async {
    if (_wordController.text.isEmpty || _translationController.text.isEmpty) {
      _showSnackBar('Word dan translation harus diisi', success: false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AdminService.addDictionary(
          _wordController.text, _translationController.text);
      _showSnackBar('Data berhasil ditambahkan!', success: true);
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context, true);
      });
    } catch (e) {
      _showSnackBar('Gagal menambahkan data: $e', success: false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _wordController,
              decoration: InputDecoration(
                labelText: 'Word',
                prefixIcon: Icon(Icons.text_fields, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _translationController,
              decoration: InputDecoration(
                labelText: 'Translation',
                prefixIcon: Icon(Icons.translate, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addDictionary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Tambah Data',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
