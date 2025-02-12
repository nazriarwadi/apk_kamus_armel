import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> _searchHistory = [];
  List<Map<String, String>> _searchResults = [];
  final ApiService _apiService = ApiService();
  TextEditingController _searchController = TextEditingController();
  bool _hasSearched = false;
  bool _isSearching = false;
  bool _isTextFieldActive = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();

    _searchController.addListener(() {
      setState(() {
        _hasSearched = false;
        _isSearching = _searchController.text.isNotEmpty;
      });
    });
  }

  _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  _addSearchHistory(String searchTerm) async {
    if (!_searchHistory.contains(searchTerm)) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _searchHistory.insert(0, searchTerm);
      });
      prefs.setStringList('searchHistory', _searchHistory);
    }
  }

  _searchDictionary(String searchTerm) async {
    setState(() {
      _isSearching = true;
      _hasSearched = false;
      _searchResults.clear();
    });

    try {
      List<Map<String, String>> searchResults =
          await _apiService.fetchSearchResults(searchTerm);
      setState(() {
        _searchResults = searchResults;
        _hasSearched = true;
        _isSearching = false;
      });
      _addSearchHistory(searchTerm);
    } catch (e) {
      setState(() {
        _isSearching = false;
        _hasSearched = true;
      });
      _showError('Pencarian gagal: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  _removeSearchHistory(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.removeAt(index);
    });
    prefs.setStringList('searchHistory', _searchHistory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dictionary Search',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input pencarian
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _isTextFieldActive = hasFocus;
                  });
                },
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search words...',
                    hintStyle: TextStyle(fontSize: 16),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.teal),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.teal),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchResults.clear();
                                _hasSearched = false;
                                _isSearching = false;
                              });
                            },
                          )
                        : null,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  ),
                  onSubmitted: (text) {
                    if (text.isNotEmpty) _searchDictionary(text);
                  },
                ),
              ),
            ),
            SizedBox(height: 10),

            // Menampilkan history pencarian jika ada
            if (_isTextFieldActive &&
                !_hasSearched &&
                _searchHistory.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchHistory.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                _searchHistory[index],
                                style: TextStyle(color: Colors.black),
                              ),
                              leading: Icon(Icons.history, color: Colors.grey),
                              trailing: IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () => _removeSearchHistory(index),
                              ),
                              onTap: () {
                                _searchController.text = _searchHistory[index];
                                _searchDictionary(_searchHistory[index]);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Menampilkan status pencarian
            if (_isSearching)
              Expanded(
                child: Center(
                  child: Text(
                    'Sedang mencari...',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            // Menampilkan hasil pencarian jika ada input
            if (_hasSearched)
              Expanded(
                child: _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          'Kata tidak ditemukan.',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                _searchResults[index]['word']!,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                _searchResults[index]['translation']!,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.copy, color: Colors.blue),
                                onPressed: () {
                                  // Salin teks translation ke clipboard
                                  Clipboard.setData(ClipboardData(
                                      text: _searchResults[index]
                                          ['translation']!));

                                  // Menampilkan snackbar sebagai konfirmasi dengan background hijau
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Teks berhasil disalin',
                                        style: TextStyle(
                                            color: Colors
                                                .white), // Warna teks putih agar kontras
                                      ),
                                      backgroundColor:
                                          Colors.green, // Background hijau
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
