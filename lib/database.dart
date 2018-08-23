
// Changes from Andrea
// - CounterData
// Use strings for IDs. Numbers should be used for Math.
// Move/refactor Firebase convenience methods.
// - Database/AppDatabase
// Clean up abstract class for clear CRUD operations and complete implementation.
// Change to use Firestore rather than Realtime DB
// Previously, AppDatabase object was referenced.
// Remove NodeStream and NodeParser which are no longer needed.
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class CounterData {
  final String id;
  int value;

  CounterData({String id, int value}):
        id = id ?? DateTime.now().toUtc().toIso8601String(),
        value = value ?? 0;

  // Firebase convenience methods
  CounterData._fromMap({Map<String, dynamic> map}):
    id = map["id"],
    value = map["value"];

  Map<String, dynamic> _toMap() {
    return {"id" : id, "value" : value};
  }
}

abstract class Database {
  Future<CounterData> createCounter();
  Stream<List<CounterData>> readCountersStream();
  Future<void> updateCounter(CounterData counter);
  Future<void> deleteCounter(CounterData counter);
}

class AppDatabase implements Database {

  static final String rootPath = 'counters';
  static final CollectionReference _counterCollectionRef = Firestore.instance.collection("$rootPath");
  DocumentReference _counterDocumentRef(String id) => Firestore.instance.document('$rootPath/$id');

  @override
  Future<CounterData> createCounter() async {
    CounterData newCounterData = CounterData();
    await _counterCollectionRef.document(newCounterData.id).setData(newCounterData._toMap());
    return newCounterData;
    // Note: Don't actually have to await here. Could just return. Also, if you await here and
    // an auto-generated key is used, it will be available by reading the returned document reference.
  }

  // The Firestore data stream is converted to a more usable Stream of List<Counter> objects.
  @override
  Stream<List<CounterData>> readCountersStream() {
    Stream<QuerySnapshot> firestoreSteam = _counterCollectionRef.snapshots();
    return firestoreSteam.transform(StreamTransformer.fromHandlers(handleData: _handleCounterData));
  }
  // Handler that converts generic Firestore Snapshot to List<CounterData>.
  _handleCounterData(QuerySnapshot snapshot, EventSink<List<CounterData>> eventSink) {
    List<CounterData> counterList = [];
    snapshot.documents.forEach((DocumentSnapshot d) => counterList.add(CounterData._fromMap(map: d.data)));
    eventSink.add(counterList);
  }

  @override
  Future<void> updateCounter(CounterData counter) async {
    await _counterDocumentRef(counter.id).setData(counter._toMap());
  }

  @override
  Future<void> deleteCounter(CounterData counter) async {
    await _counterDocumentRef(counter.id).delete();
  }
}
