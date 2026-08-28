// Default Firebase Options for CampusEats Web & Mobile
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-CampusEats-Web2026',
    appId: '1:1029384756:web:8a9b0c1d2e3f4g',
    messagingSenderId: '1029384756',
    projectId: 'campuseats-smart-dining',
    authDomain: 'campuseats-smart-dining.firebaseapp.com',
    storageBucket: 'campuseats-smart-dining.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-CampusEats-Android',
    appId: '1:1029384756:android:8a9b0c1d2e3f4g',
    messagingSenderId: '1029384756',
    projectId: 'campuseats-smart-dining',
    storageBucket: 'campuseats-smart-dining.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-CampusEats-iOS',
    appId: '1:1029384756:ios:8a9b0c1d2e3f4g',
    messagingSenderId: '1029384756',
    projectId: 'campuseats-smart-dining',
    storageBucket: 'campuseats-smart-dining.appspot.com',
    iosBundleId: 'com.campuseats.smartdining',
  );
}
