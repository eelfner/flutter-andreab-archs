
// Changes from Andrea
// - CounterData
// Use strings for IDs. Numbers should be used for Math.
// Move/refactor Firebase convenience methods.
// - Database/AppDatabase
// Clean up abstract class for clear CRUD operations and complete implementation.
// Change to use Firestore rather than Realtime DB
// Previously, AppDatabase object was referenced.
// Remove NodeStream and NodeParser which are no longer needed.
// Remove Futures. Not really needed because 1) results are handled through async stream updates, and 2) Firestore allows offline

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class CounterData {
  static CounterData newUnsavedCounter = CounterData(id: null, value: 0); // Convenience

  final String docId;
  int value = 0;

  CounterData({String id, int value}):
        docId = id ?? DateTime.now().toUtc().toIso8601String(),
        value = value ?? 0;

  // Firebase convenience methods
  CounterData._fromMap({String id, Map<String, dynamic> map}):
    this.docId = id,
    value = map["value"];

  Map<String, dynamic> _toMap() {
    return {"value" : value};
  }
}

abstract class Database {
  createCounter();
  Stream<List<CounterData>> readCountersStream();
  updateCounter(CounterData counter);
  deleteCounter(CounterData counter);
}

class AppDatabase implements Database {

  static final String rootPath = 'counters';
  static final CollectionReference _counterCollectionRef = Firestore.instance.collection("$rootPath");
  DocumentReference _counterDocumentRef(String id) => Firestore.instance.document('$rootPath/$id');

  @override
  createCounter() {
    _counterCollectionRef.add(CounterData.newUnsavedCounter._toMap());
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
    snapshot.documents.forEach((DocumentSnapshot d) => counterList.add(CounterData._fromMap(id: d.documentID, map: d.data)));
    eventSink.add(counterList);
  }

  @override
  updateCounter(CounterData counter) {
    _counterDocumentRef(counter.docId).setData(counter._toMap());
  }

  @override
  deleteCounter(CounterData counter) {
    _counterDocumentRef(counter.docId).delete();
  }
}
//Below is implementation with Futures
//class AppDatabase implements Database {
//
//  static final String rootPath = 'counters';
//  static final CollectionReference _counterCollectionRef = Firestore.instance.collection("$rootPath");
//  DocumentReference _counterDocumentRef(String id) => Firestore.instance.document('$rootPath/$id');
//
//  @override
//  Future<CounterData> createCounter() async {
//    DocumentReference newDocRef = await _counterCollectionRef.add(CounterData.newUnsavedCounter._toMap());
//    DocumentSnapshot documentSnapshot = await newDocRef.get();
//    CounterData newCounterData = CounterData._fromMap(id: documentSnapshot.documentID, map: documentSnapshot.data);
//    return newCounterData;
//    // Note: Don't actually have to await here. Could just return. Also, if you await here and
//    // an auto-generated key is used, it will be available by reading the returned document reference.
//  }
//
//  // The Firestore data stream is converted to a more usable Stream of List<Counter> objects.
//  @override
//  Stream<List<CounterData>> readCountersStream() {
//    Stream<QuerySnapshot> firestoreSteam = _counterCollectionRef.snapshots();
//    return firestoreSteam.transform(StreamTransformer.fromHandlers(handleData: _handleCounterData));
//  }
//  // Handler that converts generic Firestore Snapshot to List<CounterData>.
//  _handleCounterData(QuerySnapshot snapshot, EventSink<List<CounterData>> eventSink) {
//    List<CounterData> counterList = [];
//    snapshot.documents.forEach((DocumentSnapshot d) => counterList.add(CounterData._fromMap(id: d.documentID, map: d.data)));
//    eventSink.add(counterList);
//    print("handler: List size: ${counterList.length}");
//  }
//
//  @override
//  Future<void> updateCounter(CounterData counter) async {
//    await _counterDocumentRef(counter.docId).setData(counter._toMap());
//  }
//
//  @override
//  Future<void> deleteCounter(CounterData counter) async {
//    await _counterDocumentRef(counter.docId).delete();
//  }
//}
