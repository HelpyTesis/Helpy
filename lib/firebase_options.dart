import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyApOUk-ueiiX6qT0c-UAvd04SIBypQJz7M",
    appId: "1:1032081046474:android:130b33967d122f693cad33",
    messagingSenderId: "1032081046474",
    projectId: "helpy-a4492",
    storageBucket: "helpy-a4492.appspot.com",
  );
}
