import 'dart:async';

import 'package:flutter/material.dart';
import 'package:andreab_archs/common_widgets/counter_list_tile.dart';
import 'package:andreab_archs/common_widgets/list_items_builder.dart';
import 'package:andreab_archs/database.dart';

import 'package:scoped_model/scoped_model.dart';

class ScopedModelPage extends StatelessWidget {
  final Database database;

  ScopedModelPage({this.database});

  @override
  build(BuildContext context){
    print("ScopedModelPage.build()");
    return ScopedModel<CountersModel>(
      model: CountersModel(stream: database.readCountersStream()),
      child: ScopedModelWidget(database: database),
      );
  }
}

class CountersModel extends Model {
  List<CounterData> counters;

  CountersModel({Stream<List<CounterData>> stream}) {
    stream.listen((counters) {
      this.counters = counters;
      notifyListeners();
    });
  }
}

class ScopedModelWidget extends StatelessWidget {
  final Database database;

  ScopedModelWidget({this.database});

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Scoped model'),
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
    return ScopedModelDescendant<CountersModel>(
        builder: (context, child, model) {
          return ListItemsBuilder<CounterData>(
              items: model.counters,
              itemBuilder: (context, counter) {
                return CounterListTile(
                  key: Key('counter-${counter.docId}'),
                  counter: counter,
                  onDecrement: _decrement,
                  onIncrement: _increment,
                  onDismissed: _delete,
                  );
              });
        });
  }
}
