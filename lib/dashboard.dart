import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';

class Dashboard extends StatefulWidget {
  @override
  _Dashboard createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {
  List<Map<String, String>> _dictionaryData = [];
  final ApiService _apiService = ApiService();
  bool _isIndoToMalay = true; // Toggle bahasa
  final ScrollController _scrollController = ScrollController();
  String _currentAlphabet = 'A';
  bool _showAlphabetOverlay = false;

  @override
  void initState() {
    super.initState();
    _fetchDictionaryData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      final index = (offset / 100).clamp(0, _dictionaryData.length - 1).toInt();
      final currentWord = _dictionaryData[index]['word'] ?? '';
      if (currentWord.isNotEmpty) {
        setState(() {
          _currentAlphabet = currentWord[0].toUpperCase();
          _showAlphabetOverlay = true;
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _showAlphabetOverlay = false;
            });
          }
        });
      }
    }
  }

  Future<void> _fetchDictionaryData() async {
    try {
      List<Map<String, String>> dictionaryData =
          await _apiService.fetchDictionaryData();
      setState(() {
        _dictionaryData = dictionaryData;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _fetchDictionaryData();
  }

  void _toggleLanguage(bool? value) {
    setState(() {
      _isIndoToMalay = value ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Kamus'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: _isIndoToMalay,
                        onChanged: _toggleLanguage,
                        activeColor: Colors.yellow,
                      ),
                      Text(
                        'Indonesia-Melayu',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: _isIndoToMalay,
                        onChanged: _toggleLanguage,
                        activeColor: Colors.yellow,
                      ),
                      Text(
                        'Melayu-Indonesia',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ScrollbarTheme(
                      data: ScrollbarThemeData(
                        thumbColor: MaterialStateProperty.all(
                            Colors.grey), // Warna thumb
                        trackColor: MaterialStateProperty.all(
                            Colors.white), // Latar putih hanya di scrollbar
                        trackBorderColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        thickness: 8,
                        radius: Radius.circular(10),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _dictionaryData.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  child: Text(
                                    _dictionaryData[index]['word']![0]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  _isIndoToMalay
                                      ? _dictionaryData[index]['word']!
                                      : _dictionaryData[index]['translation']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  _isIndoToMalay
                                      ? _dictionaryData[index]['translation']!
                                      : _dictionaryData[index]['word']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.copy,
                                      color: Colors.teal),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: _isIndoToMalay
                                            ? _dictionaryData[index]
                                                ['translation']!
                                            : _dictionaryData[index]['word']!,
                                      ),
                                    ).then((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Translation berhasil di copy!',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (_showAlphabetOverlay)
                    Positioned(
                      right: 10,
                      top: MediaQuery.of(context).size.height / 2 - 20,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _currentAlphabet,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
