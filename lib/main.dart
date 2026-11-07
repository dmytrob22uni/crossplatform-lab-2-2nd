import 'package:flutter/material.dart';
import 'models/app_models.dart';
import 'services/api_service.dart';
import 'services/database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 2 - Users & Posts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FeedScreen(),
    );
  }
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ApiService _apiService = ApiService();
  List<FeedItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    final items = await DatabaseHelper.instance.getAllFeedItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _refreshFromApi() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _apiService.fetchUsers();
      final posts = await _apiService.fetchPosts();

      await DatabaseHelper.instance.upsertItems(users, posts);
      final updatedItems = await DatabaseHelper.instance.getAllFeedItems();

      setState(() {
        _items = updatedItems;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feed refreshed from API successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network or database error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAllItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseHelper.instance.deleteAllData();
      setState(() {
        _items.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All items removed from database!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteItem(int index, FeedItem item) async {
    if (item is UserItem) {
      await DatabaseHelper.instance.deleteUser(item.id);
    } else if (item is PostItem) {
      await DatabaseHelper.instance.deletePost(item.id);
    }

    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users & Posts Feed'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Feed from API',
            onPressed: _isLoading ? null : _refreshFromApi,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Remove All Items',
            onPressed: _isLoading ? null : _deleteAllItems,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Database is empty.\nTap top-left refresh icon to fetch from API.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  itemCount: _items.length,
                  onReorderItem: (int oldIndex, int newIndex) async {
                    setState(() {
                      final item = _items.removeAt(oldIndex);
                      _items.insert(newIndex, item);
                    });

                    // Persist new order to DB
                    for (int i = 0; i < _items.length; i++) {
                      final item = _items[i];
                      await DatabaseHelper.instance.updateItemOrder(
                        item.id,
                        item is UserItem,
                        i,
                      );
                    }
                  },
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return ListTile(
                      key: ValueKey(item.id.toString() + (item is UserItem ? 'u' : 'p')),
                      leading: CircleAvatar(
                        backgroundColor: item is UserItem ? Colors.deepPurple.shade100 : Colors.blueAccent,
                        child: item is UserItem
                            ? Text(item.name.isNotEmpty ? item.name[0].toUpperCase() : 'U')
                            : const Icon(Icons.article_outlined, color: Colors.white),
                      ),
                      title: Text(
                        item is UserItem ? item.name : (item as PostItem).title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        item is UserItem ? '@${item.username} • ${item.email}' : (item as PostItem).body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteItem(index, item),
                      ),
                    );
                  },
                ),
    );
  }
}
