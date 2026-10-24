import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAdM_hmnciwIN3VnV3zFX3FySQDjgrhx04',
    appId: '1:980821545049:web:35f89dc0ae61a754d22148',
    messagingSenderId: '980821545049',
    projectId: 'crm-inmobiliario-realestate',
    authDomain: 'crm-inmobiliario-realestate.firebaseapp.com',
    storageBucket: 'crm-inmobiliario-realestate.firebasestorage.app',
    measurementId: 'G-ZGHEFW622F',
  );
}