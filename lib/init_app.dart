import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class InitApp {
  Future<void> setup() async {
    _initDependencies();
    _initFirebase();
  }

  _initFirebase() async {
    await Firebase.initializeApp();
  }

  _initDependencies() {
    WidgetsFlutterBinding.ensureInitialized();
  }
}
