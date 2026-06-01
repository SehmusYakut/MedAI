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
    apiKey: 'AIzaSyDDrekgYGQebh1AK2UdK4O8e8DVG66KuAc',
    appId: '1:329755241965:web:0fbc0af8c51ab7ef424be4',
    messagingSenderId: '329755241965',
    projectId: 'medai-5e81e',
    authDomain: 'medai-5e81e.firebaseapp.com',
    storageBucket: 'medai-5e81e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDDrekgYGQebh1AK2UdK4O8e8DVG66KuAc',
    appId: '1:329755241965:android:95c087e04db6efcc424be4',
    messagingSenderId: '329755241965',
    projectId: 'medai-5e81e',
    storageBucket: 'medai-5e81e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDDrekgYGQebh1AK2UdK4O8e8DVG66KuAc',
    appId: '1:329755241965:ios:7dc6b06e3b56258e424be4',
    messagingSenderId: '329755241965',
    projectId: 'medai-5e81e',
    storageBucket: 'medai-5e81e.firebasestorage.app',
    iosBundleId: 'com.example.medway',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDDrekgYGQebh1AK2UdK4O8e8DVG66KuAc',
    appId: '1:329755241965:ios:7dc6b06e3b56258e424be4',
    messagingSenderId: '329755241965',
    projectId: 'medai-5e81e',
    storageBucket: 'medai-5e81e.firebasestorage.app',
    iosBundleId: 'com.example.medway',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDDrekgYGQebh1AK2UdK4O8e8DVG66KuAc',
    appId: '1:329755241965:web:499881efe049f1ce424be4',
    messagingSenderId: '329755241965',
    projectId: 'medai-5e81e',
    authDomain: 'medai-5e81e.firebaseapp.com',
    storageBucket: 'medai-5e81e.firebasestorage.app',
  );
}
