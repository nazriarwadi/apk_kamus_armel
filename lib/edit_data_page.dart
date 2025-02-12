import 'package:flutter/material.dart';
import 'admin_service.dart';

class EditDataPage extends StatefulWidget {
  final int id;
  final String word;
  final String translation;

  EditDataPage({
    required this.id,
    required this.word,
    required this.translation,
  });

  @override
  _EditDataPageState createState() => _EditDataPageState();
}

class _EditDataPageState extends State<EditDataPage> {
  late TextEditingController _wordController;
  late TextEditingController _translationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.word);
    _translationController = TextEditingController(text: widget.translation);
  }

  void _updateDictionary() async {
    if (_wordController.text.isEmpty || _translationController.text.isEmpty) {
      _showSnackBar('Word dan translation harus diisi', success: false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AdminService.updateDictionary(
          widget.id, _wordController.text, _translationController.text);
      _showSnackBar('Data berhasil diperbarui!', success: true);
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context, true);
      });
    } catch (e) {
      _showSnackBar('Gagal memperbarui data: $e', success: false);
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
          'Edit Data',
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
                onPressed: _isLoading ? null : _updateDictionary,
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
                        'Update Data',
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
