// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
///
/// SECURITY NOTE: API keys are loaded at runtime from the `.env` file via
/// flutter_dotenv. The `.env` file is gitignored and must never be committed.
/// Distribute it securely to your CI/CD pipeline and team.
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
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
    appId: '1:633590187282:web:b3fe2fdcd4dae618b39fcb',
    messagingSenderId: '633590187282',
    projectId: 'tip-akademi-764ac',
    authDomain: 'tip-akademi-764ac.firebaseapp.com',
    storageBucket: 'tip-akademi-764ac.firebasestorage.app',
    measurementId: 'G-BVXW0S4CXD',
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '',
    appId: '1:633590187282:android:2093b60f276436f5b39fcb',
    messagingSenderId: '633590187282',
    projectId: 'tip-akademi-764ac',
    storageBucket: 'tip-akademi-764ac.firebasestorage.app',
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
    appId: '1:633590187282:ios:3b62c83a4075bc3bb39fcb',
    messagingSenderId: '633590187282',
    projectId: 'tip-akademi-764ac',
    storageBucket: 'tip-akademi-764ac.firebasestorage.app',
    iosBundleId: 'com.kiraathanelabs.tipakademi',
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
    appId: '1:633590187282:ios:3b62c83a4075bc3bb39fcb',
    messagingSenderId: '633590187282',
    projectId: 'tip-akademi-764ac',
    storageBucket: 'tip-akademi-764ac.firebasestorage.app',
    iosBundleId: 'com.kiraathanelabs.tipakademi',
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
    appId: '1:633590187282:web:9c5b6d9d820877f5b39fcb',
    messagingSenderId: '633590187282',
    projectId: 'tip-akademi-764ac',
    authDomain: 'tip-akademi-764ac.firebaseapp.com',
    storageBucket: 'tip-akademi-764ac.firebasestorage.app',
    measurementId: 'G-XJN066MLYB',
  );
}
