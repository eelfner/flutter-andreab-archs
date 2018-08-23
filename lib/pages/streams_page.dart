import 'dart:async';

import 'package:flutter/material.dart';
import 'package:andreab_archs/common_widgets/counter_list_tile.dart';
import 'package:andreab_archs/common_widgets/list_items_builder.dart';
import 'package:andreab_archs/database.dart';

class StreamsPage extends StatelessWidget {
  final Database database;
  final Stream<List<CounterData>> stream;

  StreamsPage({this.database}) : stream = database.readCountersStream();

  void _createCounter() async {
    await database.createCounter();
  }

  void _increment(CounterData counter) async {
    counter.value++;
    await database.updateCounter(counter);
  }

  void _decrement(CounterData counter) async {
    counter.value--;
    await database.updateCounter(counter);
  }

  void _delete(CounterData counter) async {
    await database.deleteCounter(counter);
  }

  @override
  Widget build(BuildContext context) {
    print("StreamsPage.build()");

    return Scaffold(
      appBar: AppBar(
        title: Text('Streams'),
        elevation: 1.0,
        ),
      body: Container(
        child: _buildContent(),
        ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _createCounter,
        ),
      );
  }

  Widget _buildContent() {
    return StreamBuilder<List<CounterData>>(
      stream: stream,
      builder: (context, snapshot) {
        return ListItemsBuilder<CounterData>(
          items: snapshot.hasData ? snapshot.data : null,
          itemBuilder: (context, counter) {
            return CounterListTile(
              key: Key('counter-${counter.docId}'),
              counter: counter,
              onDecrement: _decrement,
              onIncrement: _increment,
              onDismissed: _delete,
              );
          },
          );
      },
      );
  }
}

