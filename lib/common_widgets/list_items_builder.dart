import 'package:flutter/material.dart';
import 'placeholder_content.dart';

// Three state: Empty, Loading, Normal

typedef Widget ItemWidgetBuilder<T>(BuildContext context, T item);

class ListItemsBuilder<T> extends StatelessWidget {
  final List<T> items;
  final ItemWidgetBuilder<T> itemBuilder;

  ListItemsBuilder({this.items, this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    if (items != null) {
      if (items.length > 0) {
        return _buildList();
      }
      else {
        return PlaceHolderContent();
      }
    }
    else {
      return Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index]);
      }
    );
  }
}