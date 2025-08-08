import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/firebase_options.dart';
import 'app.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  runZonedGuarded(
    () async {
  await dotenv.load(fileName: ".env");
      WidgetsFlutterBinding.ensureInitialized();

      if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: "vider",
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  debugPrint(' initialized firebase apps: ${Firebase.apps}');


      
  runApp(ProviderScope(child: App()));
  },
    (error, stackTrace) {
      throw error;
    },
  );
}

