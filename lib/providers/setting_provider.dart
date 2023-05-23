import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  final SharedPreferences prefs;

  SettingProvider({
    required this.firebaseFirestore,
    required this.firebaseStorage,
    required this.prefs,
  });

  String? getPref(String key) {
    return prefs.getString(key);
  }

  Future<bool> setPref(String key, String value) async {
    return await prefs.setString(key, value);
  }

  UploadTask uploadTask(File image,String fileName ){
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String path, Map<String, String> dataNeedUpdate)async{
    firebaseFirestore.collection(collectionPath).doc(path).update(dataNeedUpdate);

  }
}
