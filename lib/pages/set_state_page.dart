import 'dart:async';

import 'package:flutter/material.dart';
import 'package:andreab_archs/common_widgets/counter_list_tile.dart';
import 'package:andreab_archs/common_widgets/list_items_builder.dart';
import 'package:andreab_archs/database.dart';

class SetStatePage extends StatefulWidget {
  final Database database;
  final Stream<List<CounterData>> stream;

  SetStatePage({this.database}) : stream = database.readCountersStream();

  @override
  State<StatefulWidget> createState() => SetStatePageState();
}

class SetStatePageState extends State<SetStatePage> {
  List<CounterData> _counters;

  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.stream.listen((counters) {
      setState(() {
        _counters = counters;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  void _createCounter() async {
    await widget.database.createCounter();
  }

  void _increment(CounterData counter) async {
    counter.value++;
    await widget.database.updateCounter(counter);
  }

  void _decrement(CounterData counter) async {
    counter.value--;
    await widget.database.updateCounter(counter);
  }

  void _delete(CounterData counter) async {
    await widget.database.deleteCounter(counter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('setState'),
        elevation: 1.0,
        ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _createCounter,
        ),
      );
  }

  Widget _buildContent() {
    return ListItemsBuilder<CounterData>(
      items: _counters,
      itemBuilder: (context, counter) {
        return CounterListTile(
          key: Key('counter-${counter.id}'),
          counter: counter,
          onDecrement: _decrement,
          onIncrement: _increment,
          onDismissed: _delete,
          );
      },
      );
  }
}
