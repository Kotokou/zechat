import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zechat/providers/auth_provider.dart';
import 'package:zechat/init_app.dart';
import 'package:zechat/providers/setting_provider.dart';
import 'package:zechat/screens/splash_screen.dart';

bool isWhite = false;

void main() async {
  await InitApp().setup();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.prefs});
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            firebaseFirestore: firebaseFirestore,
            googleSignIn: GoogleSignIn(),
            prefs: prefs,
          ),
        ),
        Provider(
          create: (_) => SettingProvider(
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
            prefs: prefs,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ZeChat App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
