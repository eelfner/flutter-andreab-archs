import 'dart:async';

import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:andreab_archs/common_widgets/counter_list_tile.dart';
import 'package:andreab_archs/common_widgets/list_items_builder.dart';
import 'package:andreab_archs/database.dart';

class ReduxPage extends StatelessWidget {
  final Database database;

  ReduxPage({this.database});

  @override
  build(BuildContext context) {
    print("ReduxPage.build()");
    var middleware = CountersMiddleware(database: database, stream: database.readCountersStream());
    var store = Store<ReduxModel>(
      reducer,
      initialState: ReduxModel(counters: null),
      middleware: [middleware],
    );

    middleware.listen(store);

    return StoreProvider(
      store: store,
      child: ReduxPageWidget(),
    );
  }
}

// Model
class ReduxModel {
  ReduxModel({this.counters});
  List<CounterData> counters;
}

// Actions
class CreateCounterAction {}

class IncrementCounterAction {
  IncrementCounterAction({this.counter});
  CounterData counter;
}

class DecrementCounterAction {
  DecrementCounterAction({this.counter});
  CounterData counter;
}

class DeleteCounterAction {
  DeleteCounterAction({this.counter});
  CounterData counter;
}

class UpdateCountersAction {
  UpdateCountersAction({this.counters});
  List<CounterData> counters;
}

// Middleware
class CountersMiddleware extends MiddlewareClass<ReduxModel> {
  CountersMiddleware({this.database, this.stream});
  final Database database;
  final Stream<List<CounterData>> stream;

  void call(Store<ReduxModel> store, dynamic action, NextDispatcher next) {
    if (action is CreateCounterAction) {
      database.createCounter();
    }
    if (action is IncrementCounterAction) {
      CounterData counter = CounterData(id: action.counter.docId, value: action.counter.value + 1);
      database.updateCounter(counter);
    }
    if (action is DecrementCounterAction) {
      CounterData counter = CounterData(id: action.counter.docId, value: action.counter.value - 1);
      database.updateCounter(counter);
    }
    if (action is DeleteCounterAction) {
      database.deleteCounter(action.counter);
    }
    next(action);
  }

  void listen(Store<ReduxModel> store) {
    stream.listen((counters) {
      store.dispatch(UpdateCountersAction(counters: counters));
    });
  }
}

// Reducer
ReduxModel reducer(ReduxModel model, dynamic action) {
  if (action is UpdateCountersAction) {
    return ReduxModel(counters: action.counters);
  }
  // Special handling to ensure counter is removed immediately after Dismissable is dismissed.
  if (action is DeleteCounterAction) {
    List<CounterData> counters = model.counters;
    counters.remove(action.counter);
    return ReduxModel(counters: counters);
  }
  return model;
}

// Page
class ReduxPageWidget extends StatelessWidget {
  void _createCounter(Store<ReduxModel> store) async {
    store.dispatch(CreateCounterAction());
  }

  void _increment(Store<ReduxModel> store, CounterData counter) async {
    store.dispatch(IncrementCounterAction(counter: counter));
  }

  void _decrement(Store<ReduxModel> store, CounterData counter) async {
    store.dispatch(DecrementCounterAction(counter: counter));
  }

  void _delete(Store<ReduxModel> store, CounterData counter) async {
    store.dispatch(DeleteCounterAction(counter: counter));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Redux'),
        elevation: 1.0,
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _createCounter(StoreProvider.of(context)),
      ),
    );
  }

  Widget _buildContent() {
    return StoreBuilder<ReduxModel>(builder: (context, Store<ReduxModel> store) {
      ReduxModel model = store.state;
      return ListItemsBuilder<CounterData>(
        items: model.counters,
        itemBuilder: (context, counter) {
          return CounterListTile(
            key: Key('counter-${counter.docId}'),
            counter: counter,
            onDecrement: (counter) => _decrement(store, counter),
            onIncrement: (counter) => _increment(store, counter),
            onDismissed: (counter) => _delete(store, counter),
          );
        },
      );
    });
  }
}
