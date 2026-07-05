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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDraaBP5gJi7tGuhP33tQI7-P_8Czx4Fck',
    appId: '1:913268485080:web:727fe30d3c02eac70ae0ad',
    messagingSenderId: '913268485080',
    projectId: 'enneagram-8b860',
    authDomain: 'enneagram-8b860.firebaseapp.com',
    storageBucket: 'enneagram-8b860.firebasestorage.app',
    measurementId: 'G-RQQ97P3M8M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHh0Ap4ahO2OKnWIvatBr80AQwI6VduE8',
    appId: '1:913268485080:android:1dded51205fe0ba20ae0ad',
    messagingSenderId: '913268485080',
    projectId: 'enneagram-8b860',
    storageBucket: 'enneagram-8b860.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCwXJ4-LDSqqIloMstrCUZuCfQVTv2-q4Y',
    appId: '1:913268485080:ios:2680f6dddc68de2b0ae0ad',
    messagingSenderId: '913268485080',
    projectId: 'enneagram-8b860',
    storageBucket: 'enneagram-8b860.firebasestorage.app',
    iosBundleId: 'com.kiraathanelabs.enneagram',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCwXJ4-LDSqqIloMstrCUZuCfQVTv2-q4Y',
    appId: '1:913268485080:ios:2680f6dddc68de2b0ae0ad',
    messagingSenderId: '913268485080',
    projectId: 'enneagram-8b860',
    storageBucket: 'enneagram-8b860.firebasestorage.app',
    iosBundleId: 'com.kiraathanelabs.enneagram',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDraaBP5gJi7tGuhP33tQI7-P_8Czx4Fck',
    appId: '1:913268485080:web:95da348290e2d48f0ae0ad',
    messagingSenderId: '913268485080',
    projectId: 'enneagram-8b860',
    authDomain: 'enneagram-8b860.firebaseapp.com',
    storageBucket: 'enneagram-8b860.firebasestorage.app',
    measurementId: 'G-EW1N6CBN9X',
  );
}
