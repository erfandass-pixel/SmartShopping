import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../widgets/shopping_list_tile.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<ShoppingItem> _items = [];
  final TextEditingController _controller = TextEditingController();

  void _addItem() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _items.add(ShoppingItem(name: _controller.text.trim()));
      _controller.clear();
    });
  }

  void _toggleItem(int index) {
    setState(() {
      _items[index].isDone = !_items[index].isDone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einkaufsliste'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Neuer Artikel...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addItem,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                // Hier wird das eigene Widget aufgerufen
                return ShoppingListTile(
                  item: _items[index],
                  onTap: () => _toggleItem(index),
                  onChanged: (_) => _toggleItem(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}