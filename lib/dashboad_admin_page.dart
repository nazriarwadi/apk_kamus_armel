import 'package:flutter/material.dart';
import 'package:kamus_application/dashboard_page.dart';
import 'admin_service.dart';
import 'tambah_data_page.dart';
import 'edit_data_page.dart';

class DashboardAdminPage extends StatefulWidget {
  @override
  _DashboardAdminPageState createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  List<dynamic> _dictionaryData = [];
  bool _isLoading = false;
  Duration _fetchDuration = Duration.zero;
  Set<int> _selectedItems = {}; // Untuk menyimpan item yang dipilih
  bool _selectMode = false; // Mode pemilihan

  @override
  void initState() {
    super.initState();
    _fetchDictionaryData();
  }

  Future<void> _fetchDictionaryData() async {
    setState(() => _isLoading = true);
    final stopwatch = Stopwatch()..start();
    try {
      final response = await AdminService.getDictionary();
      setState(() {
        _dictionaryData = response['data'];
        _selectedItems.clear(); // Reset setelah refresh
        _selectMode = false;
      });
    } catch (e) {
      _showSnackBar('Gagal mengambil data: $e');
    } finally {
      stopwatch.stop();
      setState(() {
        _isLoading = false;
        _fetchDuration = stopwatch.elapsed;
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Logout"),
        content: Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            },
            child: Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      if (!_selectMode) _selectedItems.clear();
    });
  }

  void _selectItem(int id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
      } else {
        _selectedItems.add(id);
      }
    });
  }

  void _deleteSelectedItems() async {
    if (_selectedItems.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      for (var id in _selectedItems) {
        await AdminService.deleteDictionary(id);
      }
      _fetchDictionaryData();
      _showSnackBar('${_selectedItems.length} data berhasil dihapus',
          success: true);
    } catch (e) {
      _showSnackBar('Gagal menghapus data: $e');
    }
  }

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Dashboard Admin',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          actions: [
            if (_selectMode)
              IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent),
                onPressed: _deleteSelectedItems,
              ),
            IconButton(
              icon: Icon(_selectMode ? Icons.close : Icons.select_all,
                  color: Colors.black),
              onPressed: _toggleSelectMode,
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.black),
              onPressed: _logout,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TambahDataPage()),
            );
            if (result == true) _fetchDictionaryData();
          },
          backgroundColor: Colors.teal,
          child: Icon(Icons.add, size: 30),
        ),
        body: RefreshIndicator(
          onRefresh: _fetchDictionaryData,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _dictionaryData.length,
                  itemBuilder: (ctx, index) {
                    final item = _dictionaryData[index];
                    final isSelected = _selectedItems.contains(item['id']);
                    return GestureDetector(
                      onLongPress: _toggleSelectMode,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.blue.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: _selectMode
                              ? Checkbox(
                                  value: isSelected,
                                  onChanged: (value) => _selectItem(item['id']),
                                )
                              : null,
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text(
                            item['word'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade800,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['translation'],
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Kecepatan fetching: ${_fetchDuration.inMilliseconds} ms',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: !_selectMode
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit,
                                          color: Colors.blueAccent),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditDataPage(
                                              id: item['id'],
                                              word: item['word'],
                                              translation: item['translation'],
                                            ),
                                          ),
                                        );
                                        if (result == true)
                                          _fetchDictionaryData();
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      onPressed: () => _deleteSelectedItems(),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
