import 'package:blackout_track/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final _trackerCollection =
      FirebaseFirestore.instance.collection('trackerInfo');

  Future addOrUpdateInfo() async {
    return await _trackerCollection
        .doc()
        .set({taskInfo.currentTime: taskInfo.info});
  }

  Future deleteAllInfo() async {
    final collection = await _trackerCollection.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in collection.docs) {
      batch.delete(doc.reference);
    }
    return batch.commit();
  }
}
