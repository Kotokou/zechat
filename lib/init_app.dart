import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zechat/firebase_options.dart';

class InitApp {
  Future<void> setup() async {
    _initDependencies();
    await _initFirebase();
  }

  _initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  _initDependencies() {
    WidgetsFlutterBinding.ensureInitialized();
  }
}
