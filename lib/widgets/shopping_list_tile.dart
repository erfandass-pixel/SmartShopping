import 'package:flutter/material.dart';
import '../models/shopping_item.dart';

class ShoppingListTile extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onTap;
  final ValueChanged<bool?> onChanged;

  const ShoppingListTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        item.name,
        style: TextStyle(
          decoration: item.isDone 
              ? TextDecoration.lineThrough 
              : TextDecoration.none,
        ),
      ),
      trailing: Checkbox(
        value: item.isDone,
        onChanged: onChanged,
      ),
      onTap: onTap,
    );
  }
}