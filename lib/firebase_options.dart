import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'please register an android app in Firebase Console.',
        );
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDriEWtD3FMuUtKceu5hgED5Cm9sS9UuGY',
    appId: '1:1059958542040:web:6bf18c50139d05f66911ad',
    messagingSenderId: '1059958542040',
    projectId: 'botkassa-f4565',
    authDomain: 'botkassa-f4565.firebaseapp.com',
    storageBucket: 'botkassa-f4565.firebasestorage.app',
    measurementId: 'G-B54Y6PD32J',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCUBfXQXOiVo7moOR7yAimQIaeUF6r4c3Y',
    appId: '1:1059958542040:ios:8a46245f5fde57636911ad',
    messagingSenderId: '1059958542040',
    projectId: 'botkassa-f4565',
    storageBucket: 'botkassa-f4565.firebasestorage.app',
    iosBundleId: 'com.botkassa',
  );
}
