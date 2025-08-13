// import 'dart:async';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:myapp/firebase_options.dart';
// import 'app.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   runZonedGuarded(
//     () async {
//   await dotenv.load(fileName: ".env");
//       WidgetsFlutterBinding.ensureInitialized();

//       if (Firebase.apps.isEmpty) {
//     await Firebase.initializeApp(
//       name: "vider",
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }
  
//   runApp(ProviderScope(child: App()));
//   },
//     (error, stackTrace) {
//       throw error;
//     },
//   );
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/firebase_options.dart';
import 'app.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // Ensure Flutter is ready before anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    name: "vider",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: App()));
}
