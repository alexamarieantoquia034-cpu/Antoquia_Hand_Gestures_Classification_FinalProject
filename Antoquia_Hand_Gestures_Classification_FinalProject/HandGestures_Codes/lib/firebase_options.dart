import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web. Run flutterfire configure.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform. Run flutterfire configure.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRqW3hLtfJPA_KvrJYCegzYVHED9keehA',
    appId: '1:9213939162:android:bf6371a7505c0d5abe84e3',
    messagingSenderId: '9213939162',
    projectId: 'antoquia-handgestures-cb2b5',
    databaseURL: 'https://antoquia-handgestures-cb2b5-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'antoquia-handgestures-cb2b5.firebasestorage.app',
  );
}
