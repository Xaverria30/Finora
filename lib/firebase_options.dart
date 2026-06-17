import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// #
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvyhoYuR8ay3rBINBGC4qimHl9IkRuKpc',
    appId: '1:143570216302:android:d27172ff565be209488d7f',
    messagingSenderId: '143570216302',
    projectId: 'finora-cd8c0',
    storageBucket: 'finora-cd8c0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAl-yq9ebl1bsKPmmr49FyedFKOLN2d3ks',
    appId: '1:143570216302:ios:d54d47c682bda07f488d7f',
    messagingSenderId: '143570216302',
    projectId: 'finora-cd8c0',
    storageBucket: 'finora-cd8c0.firebasestorage.app',
    iosBundleId: 'com.example.finora',
  );

}