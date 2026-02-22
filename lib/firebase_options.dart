// ملف إعدادات Firebase - يُنشأ تلقائياً عند تشغيل:
// dart run flutterfire_cli:flutterfire configure
//
// لو شغّلت الأمر ده هيتستبدل القيم الافتراضية دي بقيم مشروعك من Firebase Console.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
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
        throw UnsupportedError('لم يتم إعداد Firebase لـ Linux.');
      default:
        throw UnsupportedError('منصة غير مدعومة.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'PLACEHOLDER_WEB_API_KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'tafwela',
    authDomain: 'tafwela.firebaseapp.com',
    storageBucket: 'tafwela.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER_ANDROID_API_KEY',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'tafwela',
    storageBucket: 'tafwela.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER_IOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'tafwela',
    storageBucket: 'tafwela.appspot.com',
    iosBundleId: 'com.example.tafwela',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'PLACEHOLDER_MACOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'tafwela',
    storageBucket: 'tafwela.appspot.com',
    iosBundleId: 'com.example.tafwela',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'PLACEHOLDER_WINDOWS_API_KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'tafwela',
    authDomain: 'tafwela.firebaseapp.com',
    storageBucket: 'tafwela.appspot.com',
  );
}
